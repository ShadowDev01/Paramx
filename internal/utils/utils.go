package utils

import (
	"bufio"
	"fmt"
	"os"
	"strings"

	"github.com/projectdiscovery/gologger"
)

func TrimIfNotEmpty(s string) string {
	if s != "" {
		return strings.TrimSpace(s)
	}
	return s
}

func PrintUnique(resultChan <-chan string) {
	seen := make(map[string]struct{})
	for item := range resultChan {
		if _, exists := seen[item]; !exists {
			seen[item] = struct{}{}
			fmt.Println(item)
		}
	}
}

func SaveUnique(filename string, resultChan <-chan string) {
	seen := make(map[string]struct{})
	file, err := os.Create(filename)
	if err != nil {
		gologger.Fatal().Msgf("failed to create file: %s", err)
	}
	defer file.Close()

	writer := bufio.NewWriter(file)
	defer writer.Flush()

	for item := range resultChan {
		if _, exists := seen[item]; !exists {
			seen[item] = struct{}{}
			_, err := writer.WriteString(item + "\n")
			if err != nil {
				gologger.Fatal().Msgf("Failed to write to file: %s", err)
			}
		}
	}
}
