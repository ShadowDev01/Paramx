package extract

import (
	"github.com/dlclark/regexp2"
)

var xmlElement = regexp2.MustCompile(`(?<=\<)(?<ename>\w+)`, 0)

func extractXMLElements(source string, result chan<- string) {
	match, _ := xmlElement.FindStringMatch(source)
	for match != nil {
		ename := match.GroupByName("ename").String()
		result <- ename
		match, _ = xmlElement.FindNextMatch(match)
	}

}
