package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"net"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"

	"fstore/internal/database"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

const (
	chunkSize  = 32 * 1024 * 1024
	directory  = "/Users/plumm/.testing"
	bufferSize = 64 * 1024
)

type server struct {
	db          *sqlx.DB
	buffers     map[string][]byte
	fileHandles map[string]*os.File
	mu          sync.Mutex
}

func (s *server) handleDownloadConnection(conn net.Conn) {
	defer conn.Close()

	var fileBytes []byte

	reader := bufio.NewReader(conn)
	fileId, err := reader.ReadString('\n')

	if err != nil {
		if err != io.EOF {
			log.Printf("failed to read message: %v\n", err)
		}
		return
	}

	fileId = strings.TrimSuffix(fileId, "\n")

	fileReader := &database.FileReader{DB: s.db}
	fileBytes, err = fileReader.Read(fileId)

	if err != nil {
		log.Printf("unable to read file: %v\n", err)
		return
	}

	conn.Write(fileBytes[:])
}

func (s *server) handleUploadConnection(conn net.Conn) error {
	defer conn.Close()

	chunkWriter := &database.ChunkWriter{DB: s.db}
	fileWriter := &database.FileReader{DB: s.db}
	reader := bufio.NewReader(conn)

	for {
		fileId, err := reader.ReadString('\n')
		if err != nil {
			if err != io.EOF {
				log.Printf("failed to read main file ID: %v\n", err)
			}
			return err
		}

		fileId = strings.TrimSpace(fileId)

		fileSize := intFromStringChunk(reader, "file size")

		index := intFromStringChunk(reader, "index")
		fmt.Printf("%v\t%v\t%v\n", fileId, fileSize, index)
		chunkData := make([]byte, chunkSize)
		n, reader_err := io.ReadFull(reader, chunkData)
		if reader_err != nil && reader_err != io.EOF && reader_err != io.ErrUnexpectedEOF {
			log.Printf("failed to read chunk data: %v\n", reader_err)
			return reader_err
		} else {
			log.Printf("Reader_err: %v\n", reader_err)
		}

		chunkData = chunkData[:n]

		s.mu.Lock()
		if _, ok := s.buffers[fileId]; !ok {
			s.buffers[fileId] = []byte{}
			err = fileWriter.Save(fileId, fileSize)
			if err != nil {
				s.mu.Unlock()
				return err
			}
		}

		s.buffers[fileId] = append(s.buffers[fileId], chunkData...)

		if len(s.buffers[fileId]) >= chunkSize || reader_err == io.ErrUnexpectedEOF || reader_err == io.EOF {
			name := uuid.New().String()
			fullPath := filepath.Join(directory, name)

			err = chunkWriter.Save(chunkData, fullPath, name, fileId, index)
			if err != nil {
				s.mu.Unlock()
				log.Printf("failed to save chunk data: %v\n", err)
				return err
			}
			s.buffers[fileId] = []byte{}
		}
		s.mu.Unlock()
	}
}

func intFromStringChunk(reader *bufio.Reader, chunkName string) int64 {
	numStr, err := reader.ReadString('\n')
	if err != nil {
		log.Printf("failed to read %v: %v\n", chunkName, err)
	}
	numStr = strings.TrimSpace(numStr)
	num, err := strconv.Atoi(numStr)
	if err != nil {
		log.Printf("invalid %v: %v\n", chunkName, err)
	}

	return int64(num)
}
