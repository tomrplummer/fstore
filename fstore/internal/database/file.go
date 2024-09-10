package database

import (
	"context"
	"io"
	"log"
	"os"

	"github.com/jmoiron/sqlx"
	// _ "github.com/mattn/go-sqlite3"
)

const CHUNK_SIZE = 32 * 1024 * 1024

type FileReader struct {
	DB *sqlx.DB
}

type ChunkMetaData struct {
	FullPath string
	Index    int64
}

type FileMetaData struct {
	FileSize  int64 `db:"file_size"`
	ChunkSize int64 `db:"chunk_size"`
}

func (f FileReader) Save(fileId string, fileSize int64) error {
	query := `
		INSERT INTO files (id, file_size, chunk_size) VALUES(?, ?, ?)
	`

	ctx, cancel := context.WithTimeout(context.Background(), defaultTimeout)
	defer cancel()

	_, err := f.DB.ExecContext(ctx, query, fileId, fileSize, CHUNK_SIZE)
	if err != nil {
		log.Fatalln(err)
		return err
	}

	return nil
}

func (f FileReader) Read(fileId string) ([]byte, error) {
	fileQuery := `
		SELECT file_size, chunk_size FROM files WHERE id = ?
	`

	var fileMetaData FileMetaData
	err := f.DB.Get(&fileMetaData, fileQuery, fileId)
	if err != nil {
		return nil, err
	}

	chunkQuery := `
		SELECT full_path, "index" FROM chunks WHERE file_id = ?
	`
	rows, err := f.DB.Queryx(chunkQuery, fileId)
	if err != nil {
		return nil, err
	}

	var chunks []ChunkMetaData
	for rows.Next() {
		var chunk ChunkMetaData

		err := rows.Scan(&chunk.FullPath, &chunk.Index)
		if err != nil {
			return nil, err
		}

		chunks = append(chunks, chunk)
	}

	bytesRead := make([]byte, fileMetaData.FileSize)

	for _, chunk := range chunks {
		file, err := os.Open(chunk.FullPath)
		if err != nil {
			return nil, err
		}

		buffer := make([]byte, 64*1024)
		var offset int64 = 0
		for {
			n, err := file.Read(buffer)
			if err != nil && err != io.EOF {
				return nil, err
			}
			if n == 0 {
				break
			}
			calc := chunk.Index*fileMetaData.ChunkSize + offset
			copy(bytesRead[calc:calc+int64(n)], buffer[:n])
			offset += int64(n)
		}
	}

	return bytesRead, nil
}
