package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"os"
	"os/user"
	"path/filepath"
	"time"

	"github.com/jmoiron/sqlx"
	_ "github.com/mattn/go-sqlite3"
)

const (
	defaultTimeout = 3 * time.Second
	ulAddr         = ":50051"
	dlAddr         = ":50052"
)

func main() {
	create_storage_directory()

	ctx, cancel := context.WithTimeout(context.Background(), defaultTimeout)
	defer cancel()

	db, err := sqlx.ConnectContext(ctx, "sqlite3", "db.sqlite")
	if err != nil {
		panic(err)
	}

	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(25)
	db.SetConnMaxIdleTime(5 * time.Minute)
	db.SetConnMaxLifetime(2 * time.Hour)

	s := &server{
		db:      db,
		buffers: make(map[string][]byte),
	}

	go func() {
		listener, err := net.Listen("tcp", ulAddr)
		if err != nil {
			log.Fatalf("failed to listen: %v\n", ulAddr)
		}
		log.Printf("UploadServer is running on %s", ulAddr)

		for {
			conn, err := listener.Accept()
			if err != nil {
				log.Printf("failed to accept connection: %v\n", err)
				continue
			}

			go s.handleUploadConnection(conn)
		}
	}()

	downloadListener, err := net.Listen("tcp", dlAddr)
	if err != nil {
		log.Fatalf("failed to listen: %v\n", dlAddr)
	}
	log.Printf("DownloadServer is running on %s", dlAddr)

	for {
		conn, err := downloadListener.Accept()
		if err != nil {
			log.Printf("failed to accept connection: %v\n", err)
			continue
		}

		go s.handleDownloadConnection(conn)
	}
}

func create_storage_directory() {
	// Create a directory to store the uploaded files
	usr, err := user.Current()
	if err != nil {
		fmt.Println("Error fetching user:", err)
		return
	}

	testingDir := filepath.Join(usr.HomeDir, ".testing")

	_, err = os.Stat(testingDir)

	if os.IsNotExist(err) {
		fmt.Println("Directory doesn't exist, creating it...")
		err = os.Mkdir(testingDir, 0755)
		if err != nil {
			fmt.Println("Error creating directory:", err)
			return
		}
		fmt.Println("Directory created (files will go here, delete regularly):", testingDir)
	} else if err != nil {
		fmt.Println("Error checking directory:", err)
	} else {
		fmt.Println("Directory already exists:", testingDir)
	}
}
