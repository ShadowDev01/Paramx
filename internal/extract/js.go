package extract

import (
	"github.com/dlclark/regexp2"
	"regexp"
)

var (
	jsScript    = regexp.MustCompile(`(?i)<script.*?>[\s\S]*?<\/script.*>`)
	jsVars      = regexp.MustCompile(`(?:let|var|const)\s(\$?\w+)\s?=`)
	jsObjKeys   = regexp2.MustCompile(`(?:let|var|const)?\s?(?<=[\"\'])(?<objname>[\w\@\#\\$-\.]+)(?=[\"\']\s?:)`, 0)
	jsURLParams = regexp.MustCompile(`[\?,\&,\;]([\w\-]+)[\=,\&,\;]?`)
)

func extractJSParams(source string, result chan<- string) {
	matches := jsScript.FindAllString(source, -1)
	for _, match := range matches {
		extractJSVariable(match, result)
		extractJSObjectKeys(match, result)
		extractJSurlParams(match, result)
	}
}

func extractJSVariable(source string, result chan<- string) {
	matches := jsVars.FindAllStringSubmatch(source, -1)
	for _, match := range matches {
		result <- match[1]
	}
}

func extractJSObjectKeys(source string, result chan<- string) {
	match, _ := jsObjKeys.FindStringMatch(source)
	for match != nil {
		objname := match.GroupByName("objname").String()
		result <- objname
		match, _ = jsObjKeys.FindNextMatch(match)
	}

}
func extractJSurlParams(source string, result chan<- string) {
	matches := jsURLParams.FindAllStringSubmatch(source, -1)
	for _, match := range matches {
		result <- match[1]
	}
}
