package models

import "time"

type Log struct {
	ID       int       `json:"id"`
	ClientID int       `json:"client_id"`
	Endpoint string    `json:"endpoint"`
	Method   string    `json:"method"`
	Time     time.Time `json:"timestamp"`
}
