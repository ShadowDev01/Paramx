package main

import (
	"fmt"
	"github.com/ShadowDev01/Paramx/src/cli"
)

func main() {
	options := cli.ParseOptions()
	fmt.Println("\n\n\n\n", *options)
}
