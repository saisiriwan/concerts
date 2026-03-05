package handler

import (
	"concerts/database"
	"concerts/internal/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetData(c *gin.Context) {
	rows, err := database.DB.Query("SELECT id, content FROM data")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not fetch data"})
		return
	}
	defer rows.Close()

	// Initialize เป็น slice ว่างแทนที่จะเป็น nil
	results := make([]models.Data, 0)
	for rows.Next() {
		var data models.Data
		if err := rows.Scan(&data.ID, &data.Content); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Data scan error"})
			return
		}
		results = append(results, data)
	}

	c.JSON(http.StatusOK, results)
}
