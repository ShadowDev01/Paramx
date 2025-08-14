package utils

import "strings"

func TrimIfNotEmpty(s string) string {
	if s != "" {
		return strings.TrimSpace(s)
	}
	return s
}

func Unique(slice []string) []string {
	seen := make(map[string]struct{}, len(slice))
	out := make([]string, 0, len(slice))
	for _, s := range slice {
		if _, exists := seen[s]; !exists {
			seen[s] = struct{}{}
			out = append(out, s)
		}
	}
	return out
}
