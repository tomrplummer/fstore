package main

import (
	"C"
	"bytes"
	"fmt"
	"io"
	"net"
)
import "unsafe"

const CHUNK_SIZE = 32 * 1024 * 1024

//export UploadFile
func UploadFile(fileID *C.char, fileContent *C.char, fileSize C.int, host *C.char, port *C.char) *C.char {
	goFileID := C.GoString(fileID)
	goFileContent := C.GoBytes(unsafe.Pointer(fileContent), fileSize)
	goHost := C.GoString(host)
	goPort := C.GoString(port)

	err := uploadFile(goFileID, goFileContent, goHost, goPort, int(fileSize))
	if err != nil {
		return C.CString(fmt.Sprintf("Error uploading file: %v", err))
	}
	return C.CString("Upload successful")
}

func uploadFile(fileID string, fileContent []byte, host, port string, fileSize int) error {
	conn, err := net.Dial("tcp", net.JoinHostPort(host, port))
	if err != nil {
		return fmt.Errorf("failed to connect to server: %v", err)
	}
	defer conn.Close()

	buffer := bytes.NewReader(fileContent)
	chunk := make([]byte, CHUNK_SIZE)
	index := 0

	for {
		n, err := buffer.Read(chunk)
		if err != nil && err != io.EOF {
			return fmt.Errorf("failed to read chunk: %v", err)
		}
		if n == 0 {
			break
		}

		chunkData := chunk[:n]

		_, err = conn.Write([]byte(fmt.Sprintf("%v\n%v\n%v\n", fileID, fileSize, index)))
		if err != nil {
			return fmt.Errorf("failed to send chunk header: %v", err)
		}
		_, err = conn.Write(chunkData)
		if err != nil {
			return fmt.Errorf("failed to send chunk data: %v", err)
		}

		index++
	}

	return nil
}

func main() {}
