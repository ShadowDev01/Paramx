package extract

import (
	"regexp"
)

var (
	pathURL = regexp.MustCompile(`(?:href|src|data|cite|action|srcset|poster|longdesc|manifest|xmlns)\s*=\s*[\"']([^\"']+?)[\"']`)
)

func extractURL(source string, result chan<- string) {
	match := pathURL.FindAllStringSubmatch(source, -1)
	for _, match := range match {
		result <- match[1]
	}
}

func extractFileName(source string, reg *regexp.Regexp, result chan<- string) {
	matches := reg.FindAllStringSubmatch(source, -1)
	for _, match := range matches {
		result <- match[1]
	}
}
