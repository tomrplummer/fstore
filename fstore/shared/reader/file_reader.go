package main

import (
	"io"
	"os"
	"unsafe"
)

/*
#include <stdlib.h>
#include <string.h>
*/
import "C"

//export ReadFile
func ReadFile(filePath *C.char, size *C.int) *C.char {
	goFilePath := C.GoString(filePath)

	// Open the file
	file, err := os.Open(goFilePath)
	if err != nil {
		*size = C.int(0)
		return nil
	}
	defer file.Close()

	// Read the file content
	content, err := io.ReadAll(file)
	if err != nil {
		*size = C.int(0)
		return nil
	}

	*size = C.int(len(content))

	// Allocate C memory for the content
	cContent := C.malloc(C.size_t(len(content)))
	if cContent == nil {
		*size = C.int(0)
		return nil
	}

	// Copy the content to the C memory
	C.memcpy(cContent, unsafe.Pointer(&content[0]), C.size_t(len(content)))

	return (*C.char)(cContent)
}

func main() {}
