package database

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq"
)

var DB *sql.DB

func ConnectDB() {
	var err error
	dsn := "host=0.0.0.0 user=postgres password=postgres123 dbname=postgres sslmode=disable"
	DB, err = sql.Open("postgres", dsn)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	err = DB.Ping()
	if err != nil {
		log.Fatal("Database not responding:", err)
	}

	fmt.Println("Connected to PostgreSQL!")
}
