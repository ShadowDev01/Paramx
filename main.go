package main

import (
	"fmt"
	"github.com/ShadowDev01/Paramx/internal/cli"
	"log"
	"os"
)

func main() {
	options, err := cli.ParseOptions()
	if err != nil {
		log.Fatal(err)
	}

	me, _ := os.ReadFile("   go.mod    ")
	fmt.Println(string(me))
	fmt.Println("\n\n\n\n", *options)
}
