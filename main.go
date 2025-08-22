package main

import (
	"bufio"
	"context"
	"os"
	"sync"

	"github.com/ShadowDev01/Paramx/internal/cli"
	"github.com/ShadowDev01/Paramx/internal/extract"
	"github.com/ShadowDev01/Paramx/internal/fetch"
	"github.com/ShadowDev01/Paramx/internal/types"
	"github.com/ShadowDev01/Paramx/internal/utils"
	"github.com/projectdiscovery/gologger"
)

const NumWorkers = 8

func main() {
	opt, err := cli.ParseOptions()
	if err != nil {
		gologger.Fatal().Msgf("Error parsing command line options: %v", err)
	}

	resultChan := make(chan string)
	var wg sync.WaitGroup
	ctx := context.Background()

	if opt.URLFile != "" {
		jobsChan := make(chan string)

		for i := 0; i < NumWorkers; i++ {
			wg.Add(1)
			go worker(ctx, &wg, opt, jobsChan, resultChan)
		}

		go func() {
			file, err := os.Open(opt.URLFile)
			if err != nil {
				gologger.Fatal().Msgf("failed to open urls: %v", err)
			}
			defer file.Close()

			scanner := bufio.NewScanner(file)
			for scanner.Scan() {
				url := scanner.Text()
				if url != "" {
					jobsChan <- url
				}
			}
			close(jobsChan)
		}()

		go func() {
			wg.Wait()
			close(resultChan)
		}()

		if opt.OutputFile != "" {
			utils.SaveUnique(opt.OutputFile, resultChan)
		} else {
			utils.PrintUnique(resultChan)
		}
		return
	}

	var content *types.Content

	switch {
	case opt.HTMLFile != "":
		content, err = fetch.FetchFile(opt.HTMLFile)
	case opt.JSFile != "":
		content, err = fetch.FetchFile(opt.JSFile)
	case opt.XMLFile != "":
		content, err = fetch.FetchFile(opt.XMLFile)
	case opt.URL != "":
		content, err = fetch.FetchURL(ctx, opt.URL, opt)
	}

	if err != nil {
		gologger.Fatal().Msgf("%s", err)
	}
	if content == nil {
		gologger.Fatal().Msgf("no content provided")
	}

	wg.Add(1)
	go func() {
		defer wg.Done()
		extractor := extract.NewExtractor(content)
		extractor.Extract(opt, resultChan)
	}()

	go func() {
		wg.Wait()
		close(resultChan)
	}()

	if opt.OutputFile != "" {
		utils.SaveUnique(opt.OutputFile, resultChan)
	} else {
		utils.PrintUnique(resultChan)
	}

}

func worker(ctx context.Context, wg *sync.WaitGroup, opt *cli.Options, jobs <-chan string, results chan<- string) {
	defer wg.Done()
	for url := range jobs {
		content, err := fetch.FetchURL(ctx, url, opt)
		if err != nil {
			gologger.Print().Msgf("error in fetch %s: %v", url, err)
			continue
		}

		extractor := extract.NewExtractor(content)
		extractor.Extract(opt, results)
	}
}
