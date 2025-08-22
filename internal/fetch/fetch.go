package fetch

import (
	"context"
	"fmt"
	"io"
	"mime"
	"net/http"
	"net/url"
	"os"
	"path"
	"strings"

	"github.com/ShadowDev01/Paramx/internal/cli"
	"github.com/ShadowDev01/Paramx/internal/types"
)

const maxBodyBytes = 20 << 20 // 20 MiB

// simple HTTP request and returns content types (html/js/xml) and body bytes.
func FetchURL(ctx context.Context, urlStr string, opt *cli.Options) (*types.Content, error) {
	req, err := http.NewRequestWithContext(ctx, opt.Method, urlStr, nil)
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}

	// add headers
	for _, h := range opt.Headers {
		parts := strings.SplitN(h, ":", 2)
		if len(parts) != 2 {
			continue
		}
		req.Header.Add(http.CanonicalHeaderKey(parts[0]), parts[1])
	}

	// use default client proxy
	var client http.Client
	if opt.Proxy != "" {
		pURL, err := url.Parse(opt.Proxy)
		if err != nil {
			return nil, fmt.Errorf("invalid proxy: %w", err)
		}
		client = http.Client{
			Transport: &http.Transport{Proxy: http.ProxyURL(pURL)},
			Timeout:   opt.Timeout,
		}
	} else {
		client = http.Client{Timeout: opt.Timeout}
	}

	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	limited := io.LimitReader(resp.Body, maxBodyBytes+1)
	body, err := io.ReadAll(limited)
	if err != nil {
		return nil, fmt.Errorf("read body: %w", err)
	}
	if int64(len(body)) > maxBodyBytes {
		return nil, fmt.Errorf("body too large (>%d bytes)", maxBodyBytes)
	}

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		sn := string(body)
		if len(sn) > 200 {
			sn = sn[:200] + "..."
		}
		return nil, fmt.Errorf("non-2xx status %d: %s", resp.StatusCode, sn)
	}

	ctype := detectType(resp.Header.Get("Content-Type"), urlStr)
	if ctype == "unknown" {
		return nil, fmt.Errorf("unknown content types for %s", urlStr)
	}

	return &types.Content{Type: ctype, Body: body}, nil
}

func detectType(contentTypeHeader, targetURL string) string {
	ct := strings.TrimSpace(contentTypeHeader)
	if ct != "" {
		if mt, _, err := mime.ParseMediaType(ct); err == nil {
			mt = strings.ToLower(mt)
			switch {
			case strings.Contains(mt, "text/html"), strings.Contains(mt, "application/xhtml+xml"):
				return "html"
			case strings.Contains(mt, "javascript"), strings.Contains(mt, "ecmascript"), mt == "application/javascript", mt == "text/javascript":
				return "js"
			case strings.Contains(mt, "xml"), strings.HasSuffix(mt, "+xml"), mt == "text/xml":
				return "xml"
			}
		}
		l := strings.ToLower(ct)
		if strings.Contains(l, "text/html") {
			return "html"
		}
		if strings.Contains(l, "javascript") {
			return "js"
		}
		if strings.Contains(l, "xml") {
			return "xml"
		}
	}

	if u, err := url.Parse(targetURL); err == nil {
		switch strings.ToLower(path.Ext(u.Path)) {
		case ".html", ".htm", ".xhtml":
			return "html"
		case ".js":
			return "js"
		case ".xml", ".rss", ".svg":
			return "xml"
		}
	}
	return "unknown"
}

func FetchFile(filePath string) (*types.Content, error) {
	file, err := os.Open(filePath)
	if err != nil {
		return nil, fmt.Errorf("open file failed: %s: %w", filePath, err)
	}
	defer file.Close()

	limited := io.LimitReader(file, maxBodyBytes+1)
	body, err := io.ReadAll(limited)
	if err != nil {
		return nil, fmt.Errorf("read file failed: %s: %w", filePath, err)
	}
	if int64(len(body)) > maxBodyBytes {
		return nil, fmt.Errorf("file too large (>%d bytes): %s", maxBodyBytes, filePath)
	}

	ctype := detectType("", filePath)

	return &types.Content{Type: ctype, Body: body}, nil
}
