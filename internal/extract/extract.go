package extract

import (
	"github.com/ShadowDev01/Paramx/internal/cli"
	"github.com/ShadowDev01/Paramx/internal/types"
)

type Extractor struct {
	content *types.Content
}

func NewExtractor(content *types.Content) *Extractor {
	return &Extractor{content}
}

func (extractor *Extractor) Extract(opt *cli.Options, result chan<- string) {
	source := string(extractor.content.Body)

	switch extractor.content.Type {
	case "html":
		if opt.ExtractHrefParams {
			extractHrefParams(source, result)
		}
		if opt.ExtractScriptParams {
			extractJSParams(source, result)
		}
		if opt.ExtractInputTags {
			extractInputParams(source, result)
		}

	case "js":
		extractJSVariable(source, result)
		extractJSObjectKeys(source, result)
		extractJSParams(source, result)

	case "xml":
		extractXMLElements(source, result)
	}

	if opt.ExtractURLs {
		extractURL(source, result)
	}

	if opt.ExtractFileNames {
		extractFileName(source, opt.FilenameRegex, result)
	}
}
