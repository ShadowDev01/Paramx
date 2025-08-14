package cli

import (
	"errors"
	"fmt"
	"github.com/ShadowDev01/Paramx/internal/utils"
	"github.com/projectdiscovery/goflags"
	"net/url"
	"strings"
	"time"
)

type Options struct {
	// Input
	URL      string
	URLFile  string
	HTMLFile string
	JSFile   string
	PHPFile  string
	XMLFile  string
	Stdin    bool

	// Output
	OutputFile string

	// Extract
	ExtractHrefParams    bool
	ExtractInputTags     bool
	ExtractScriptParams  bool
	ExtractFileNames     bool
	ExtractURLs          bool
	ExtractGenericParams bool
	AllExtractionModes   bool
	ExtensionsToSearch   goflags.StringSlice

	// HTTP
	Headers goflags.StringSlice
	Method  string
	Proxy   string
	Timeout time.Duration
}

func ParseOptions() (*Options, error) {
	opt := &Options{}

	flagSet := goflags.NewFlagSet()

	flagSet.SetDescription("\n██████╗  █████╗ ██████╗  █████╗ ███╗   ███╗██╗  ██╗\n██╔══██╗██╔══██╗██╔══██╗██╔══██╗████╗ ████║╚██╗██╔╝\n██████╔╝███████║██████╔╝███████║██╔████╔██║ ╚███╔╝ \n██╔═══╝ ██╔══██║██╔══██╗██╔══██║██║╚██╔╝██║ ██╔██╗ \n██║     ██║  ██║██║  ██║██║  ██║██║ ╚═╝ ██║██╔╝ ██╗\n╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝\n                                                   \n")

	flagSet.CreateGroup("Input", "Input Options",
		flagSet.StringVar(&opt.URL, "u", "", "Single URL to crawl"),
		flagSet.StringVar(&opt.URLFile, "ul", "", "File of URLs (one per line)"),
		flagSet.StringVar(&opt.HTMLFile, "html", "", "Use saved HTML file"),
		flagSet.StringVar(&opt.JSFile, "js", "", "Use saved JS file"),
		flagSet.StringVar(&opt.PHPFile, "php", "", "Use saved PHP file"),
		flagSet.StringVar(&opt.XMLFile, "xml", "", "Use saved XML file"),
		flagSet.BoolVar(&opt.Stdin, "stdin", false, "Use stdin"),
	)

	flagSet.CreateGroup("Output", "Output Options",
		flagSet.StringVar(&opt.OutputFile, "o", "", "Save output to file"),
	)

	flagSet.CreateGroup("extractor", "Extract Options",
		flagSet.BoolVar(&opt.ExtractHrefParams, "a", false, "Extract parameters from <a> tags (href query strings)"),
		flagSet.BoolVar(&opt.ExtractInputTags, "i", false, "Extract name & id from <input> and <textarea> tags"),
		flagSet.BoolVar(&opt.ExtractScriptParams, "s", false, "Extract JS variables, object keys"),
		flagSet.BoolVar(&opt.ExtractGenericParams, "p", false, "Extract parameters from HTTP messages, JS, PHP, or XML content"),
		flagSet.BoolVar(&opt.ExtractURLs, "w", false, "Extract URLs and file paths"),
		flagSet.BoolVar(&opt.ExtractFileNames, "f", false, "Extract file names with specified extensions"),
		flagSet.StringSliceVar(&opt.ExtensionsToSearch, "e", []string{"js"}, "Define file extensions to search (default js)", goflags.NormalizedStringSliceOptions),
		flagSet.BoolVar(&opt.AllExtractionModes, "A", false, "Enable All extraction modes (-a -i -s -p -f -w)"),
	)

	flagSet.CreateGroup("HTTP", "HTTP Options",
		flagSet.StringVar(&opt.Method, "method", "GET", "HTTP method"),
		flagSet.StringVar(&opt.Proxy, "proxy", "", "Proxy"),
		flagSet.DurationVar(&opt.Timeout, "timeout", time.Second*10, "Timeout seconds"),
		flagSet.StringSliceVar(&opt.Headers, "H", nil, "Custom HTTP header (repeatable)", goflags.NormalizedStringSliceOptions),
	)

	if err := flagSet.Parse(); err != nil {
		return nil, fmt.Errorf("parse flags: %w", err)
	}

	opt.setDefaults()

	if err := opt.normalize(); err != nil {
		return nil, err
	}

	if err := opt.validate(); err != nil {
		return nil, err
	}

	return opt, nil
}

func (opt *Options) setDefaults() {
	if opt.AllExtractionModes {
		opt.ExtractHrefParams = true
		opt.ExtractInputTags = true
		opt.ExtractScriptParams = true
		opt.ExtractGenericParams = true
		opt.ExtractURLs = true
		opt.ExtractFileNames = true
	}
}

func (opt *Options) normalize() error {
	opt.URL = utils.TrimIfNotEmpty(opt.URL)
	opt.URLFile = utils.TrimIfNotEmpty(opt.URLFile)
	opt.HTMLFile = utils.TrimIfNotEmpty(opt.HTMLFile)
	opt.JSFile = utils.TrimIfNotEmpty(opt.JSFile)
	opt.PHPFile = utils.TrimIfNotEmpty(opt.PHPFile)
	opt.XMLFile = utils.TrimIfNotEmpty(opt.XMLFile)

	for i, header := range opt.Headers {
		parts := strings.SplitN(header, ":", 2)
		if len(parts) != 2 {
			return fmt.Errorf("invalid header: %q", header)
		}
		key := strings.TrimSpace(parts[0])
		value := strings.TrimSpace(parts[1])
		if key == "" || value == "" {
			return fmt.Errorf("invalid header: %q", header)
		}
		opt.Headers[i] = fmt.Sprintf("%s: %s", key, value)
	}

	return nil
}

func (opt *Options) hasInput() bool {
	return opt.URL != "" || opt.URLFile != "" || opt.HTMLFile != "" ||
		opt.JSFile != "" || opt.PHPFile != "" || opt.XMLFile != "" || opt.Stdin
}

func (opt *Options) validate() error {
	// Check Input Provided
	if !opt.hasInput() {
		return errors.New("no input provided (use -u, -ul, -html, -js, -php, -xml, or --stdin)")
	}

	// Check Proxy
	if opt.Proxy != "" {
		if u, err := url.Parse(opt.Proxy); err != nil || u.Scheme == "" || u.Host == "" {
			return fmt.Errorf("invalid proxy: %s", opt.Proxy)
		}
	}

	// Check HTTP Method
	switch opt.Method {
	case "GET", "POST", "HEAD", "OPTIONS", "PUT", "PATCH", "DELETE":
	default:
		return fmt.Errorf("invalid HTTP method %q. Allowed: GET, POST, HEAD, OPTIONS, PUT, PATCH, DELETE", opt.Method)
	}

	return nil
}
