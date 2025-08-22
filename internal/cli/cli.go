package cli

import (
	"errors"
	"fmt"
	"github.com/ShadowDev01/Paramx/internal/utils"
	"github.com/projectdiscovery/goflags"
	"net/url"
	"os"
	"regexp"
	"strings"
	"time"
	"unicode"
)

type Options struct {
	// Input
	URL      string
	URLFile  string
	HTMLFile string
	JSFile   string
	XMLFile  string

	// Output
	OutputFile string

	// Extract
	ExtractHrefParams   bool
	ExtractInputTags    bool
	ExtractScriptParams bool
	ExtractFileNames    bool
	ExtractURLs         bool
	AllExtractionModes  bool
	ExtensionsToSearch  goflags.StringSlice

	// HTTP
	Headers goflags.StringSlice
	Method  string
	Proxy   string
	Timeout time.Duration

	//reg
	FilenameRegex *regexp.Regexp
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
		flagSet.StringVar(&opt.XMLFile, "xml", "", "Use saved XML file"),
	)

	flagSet.CreateGroup("Output", "Output Options",
		flagSet.StringVar(&opt.OutputFile, "o", "", "Save output to file"),
	)

	flagSet.CreateGroup("extractor", "Extract Options",
		flagSet.BoolVar(&opt.ExtractHrefParams, "a", false, "Extract parameters from <a> tags (href query strings)"),
		flagSet.BoolVar(&opt.ExtractInputTags, "i", false, "Extract name & id from <input> and <textarea> tags"),
		flagSet.BoolVar(&opt.ExtractScriptParams, "s", false, "Extract JS variables, object keys"),
		flagSet.BoolVar(&opt.ExtractURLs, "w", false, "Extract URLs and file paths"),
		flagSet.BoolVar(&opt.ExtractFileNames, "f", false, "Extract file names with specified extensions"),
		flagSet.StringSliceVar(&opt.ExtensionsToSearch, "e", nil, "Define file extensions to search", goflags.NormalizedStringSliceOptions),
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
		opt.ExtractURLs = true
		opt.ExtractFileNames = true
	}
}

func (opt *Options) normalize() error {
	opt.URL = utils.TrimIfNotEmpty(opt.URL)
	opt.URLFile = utils.TrimIfNotEmpty(opt.URLFile)
	opt.HTMLFile = utils.TrimIfNotEmpty(opt.HTMLFile)
	opt.JSFile = utils.TrimIfNotEmpty(opt.JSFile)
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
		opt.Headers[i] = fmt.Sprintf("%s:%s", key, value)
	}

	return nil
}

func (opt *Options) validate() error {
	// Check Input Provided
	if !opt.hasInput() {
		return errors.New("no input provided (use -u, -ul, -html, -js, -xml")
	}

	//Check File Exists
	if err := opt.isExistsInputFile(); err != nil {
		return err
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

	if opt.ExtractFileNames && len(opt.ExtensionsToSearch) == 0 {
		return errors.New("provide at least one file extension to search")
	}

	if err := opt.checkExtensions(); err != nil {
		return err
	}

	opt.setReg()

	return nil
}

func (opt *Options) hasInput() bool {
	return opt.URL != "" || opt.URLFile != "" || opt.HTMLFile != "" ||
		opt.JSFile != "" || opt.XMLFile != ""
}

func (opt *Options) isExistsInputFile() error {
	for _, file := range []string{opt.URLFile, opt.HTMLFile, opt.JSFile, opt.XMLFile} {
		if file != "" {
			if _, err := os.Stat(file); os.IsNotExist(err) {
				return fmt.Errorf("no such file: %q", file)
			}
		}

	}
	return nil
}

func (opt *Options) checkExtensions() error {
	if opt.ExtensionsToSearch != nil {
		for _, ext := range opt.ExtensionsToSearch {
			for _, ch := range ext {
				if !unicode.IsLetter(ch) {
					if !unicode.IsDigit(ch) {
						return fmt.Errorf("invalid extension: %q", ext)
					}
				}
			}
		}
	}
	return nil
}

func (opt *Options) setReg() {
	if opt.ExtractFileNames && opt.ExtensionsToSearch != nil {
		pattern := fmt.Sprintf(`\/?([\w\.\-]+\.(?:%s))`, strings.Join(opt.ExtensionsToSearch, "|"))
		opt.FilenameRegex = regexp.MustCompile(pattern)
	}
}
