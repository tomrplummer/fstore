package database

import (
	"bufio"
	"context"
	"os"

	"github.com/jmoiron/sqlx"
	//_ "github.com/mattn/go-sqlite3"
)

type ChunkWriter struct {
	DB *sqlx.DB
}

func (c ChunkWriter) writeToDisk(fullPath string, bytes []byte) error {
	file, err := os.Create(fullPath)
	if err != nil {
		return err
	}
	defer file.Close()

	writer := bufio.NewWriter(file)

	_, err = writer.Write(bytes)
	if err != nil {
		return err
	}

	if err := writer.Flush(); err != nil {
		return err
	}

	return nil
}

func (c ChunkWriter) writeToDB(name, fileId, fullPath string, index int64) error {
	query := `
		INSERT INTO chunks (name, "index", file_id, full_path) VALUES (?, ?, ? , ?)
	`

	ctx, cancel := context.WithTimeout(context.Background(), defaultTimeout)
	defer cancel()

	_, err := c.DB.ExecContext(ctx, query, name, index, fileId, fullPath)
	if err != nil {
		return err
	}

	return nil
}

func (c ChunkWriter) Save(bytes []byte, fullPath, name, fileId string, index int64) error {
	err := c.writeToDisk(fullPath, bytes)
	if err != nil {
		return err
	}

	err = c.writeToDB(name, fileId, fullPath, index)
	if err != nil {
		return err
	}

	return nil
}
