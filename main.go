package main

import (
	"fmt"
	"github.com/ShadowDev01/Paramx/internal/config"
	"log"
)

func main() {
	options, err := config.ParseOptions()
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("\n\n\n\n", *options)
}
