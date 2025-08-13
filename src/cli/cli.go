package cli

import (
	"github.com/projectdiscovery/goflags"
	"log"
	"strings"
)

type Options struct {
	// Input Options
	URL      string
	URLFile  string
	HTMLFile string
	JSFile   string
	PHPFile  string
	XMLFile  string

	// Output Options
	OutputFile string

	// Extract Options
	ExtractHrefParams    bool
	ExtractInputTags     bool
	ExtractScriptParams  bool
	ExtractFileNames     bool
	ExtractURLs          bool
	ExtractGenericParams bool
	AllExtractionModes   bool
	ExtensionsToSearch   goflags.StringSlice

	// HTTP Request Options
	Headers goflags.StringSlice
	Method  string
	Proxy   string
	Timeout int
}

func ParseOptions() *Options {
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
		flagSet.IntVar(&opt.Timeout, "timeout", 10, "Timeout seconds"),
		flagSet.StringSliceVar(&opt.Headers, "H", nil, "Custom HTTP header (repeatable)", goflags.NormalizedStringSliceOptions),
	)

	if err := flagSet.Parse(); err != nil {

		log.Fatalf("Error parsing flags: %s\n", err)
	}

	if opt.AllExtractionModes {
		opt.ExtractHrefParams = true
		opt.ExtractInputTags = true
		opt.ExtractScriptParams = true
		opt.ExtractGenericParams = true
		opt.ExtractURLs = true
		opt.ExtractFileNames = true
	}

	// Check Input
	if opt.URL == "" && opt.URLFile == "" && opt.HTMLFile == "" && opt.JSFile == "" && opt.PHPFile == "" && opt.XMLFile == "" {
		log.Fatal("Provide Input Please!")
	}

	// Validate Headers
	for _, header := range opt.Headers {
		parts := strings.SplitN(header, ":", 2)
		if len(parts) != 2 || strings.TrimSpace(parts[0]) == "" || strings.TrimSpace(parts[1]) == "" {
			log.Fatalf("The Header format is Invalid: %s", header)
		}
	}

	return opt
}
