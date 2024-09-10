PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS files (
  id TEXT PRIMARY KEY,
  chunk_size INTEGER,
  file_size INTEGER
);

CREATE TABLE IF NOT EXISTS chunks (
  name TEXT,
  "index" INTEGER,  
  file_id TEXT,
  full_path TEXT,
  FOREIGN KEY (file_id) REFERENCES files(id)
);
