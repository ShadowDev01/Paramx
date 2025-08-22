package extract

import (
	"regexp"

	"github.com/dlclark/regexp2"
)

var (
	hrefAttr      = regexp2.MustCompile(`(?<=href=\")([^\"]+)`, 0)
	hrefAttrParam = regexp.MustCompile(`[\?\&\;]([\w\-\~\+]+)`)
	inputTag      = regexp.MustCompile(`<(?:input|textarea).*?>`)
	inputTagAttr  = regexp.MustCompile(`(?:name|id)\s?=\s?[\'\"](.+?)[\'\"]`)
)

func extractInputParams(source string, result chan<- string) {
	inpTag := inputTag.FindAllString(source, -1)
	for _, tag := range inpTag {
		res := inputTagAttr.FindAllStringSubmatch(tag, -1)
		for _, match := range res {
			result <- match[1]
		}
	}

}

func extractHrefParams(source string, result chan<- string) {
	href, _ := hrefAttr.FindStringMatch(source)
	for href != nil {
		res := href.GroupByNumber(1).String()

		subs := hrefAttrParam.FindAllStringSubmatch(res, -1)
		for _, s := range subs {
			result <- s[1]
		}

		href, _ = hrefAttr.FindNextMatch(href)
	}

}
