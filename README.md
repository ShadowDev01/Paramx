# Paramx

<p align="center">
  <img src="src/paramx.png" alt="Paramx Logo" width="600" />
</p>

---

> **Paramx** is a versatile command-line utility written in Go, designed to extract parameters, identifiers, and resources from various web and source file formats.

[![Go Version](https://img.shields.io/badge/Go-1.20%2B-blue.svg)](https://go.dev/)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](#)

---

## 🚀 Features

* **Parameter Discovery**: Extract names of form fields (`<input>`, `<textarea>`), query parameters in `<a>` tags, and more.
* **Code Analysis**: Identify JavaScript variable names, object keys.
* **Structured Data Parsing**: Read XML element names and attributes.
* **Resource Enumeration**: Locate referenced file names with specified extensions and URLs/paths.
* **Flexible Inputs**: Crawl live URLs or analyze local files (HTML, JS, XML).
* **Customizable**: Support for custom HTTP headers, methods, timeouts, and multi-threaded operation.
* **Batch Mode**: Process multiple URLs from a file in one go.
* **Extensible Switches**: Combine multiple extraction modes for comprehensive analysis.

---

## ⚙️ Installation

```bash
# Clone the repository
git clone https://github.com/ShadowDev01/Paramx.git
cd Paramx/

# Build
go build -o paramx ./internal/cmd/Paramx.go

# Show help and verify installation
paramx -h
```

---

## 🛠️ Usage

Run the tool with a combination of input sources and extraction switches.

```bash
# Crawl a single URL and extract JS variables
paramx -u https://example.com -s

# Analyze local HTML file for input fields
paramx -html page.html -i

# Batch process URLs from a file and save output
paramx -ul urls.txt -A -e "js" "php" -o results.txt
```

### Input Options

| Switch     | Description                     | Examples                      |
|------------|---------------------------------|-------------------------------|
| `-u`       | Single URL to crawl             | `-u https://example.com`      |
| `-ul`      | File of URLs (one per line)     | `-ul urls.txt`                |
| `-H`       | Custom HTTP header (repeatable) | `-H "Auth: Bearer TOKEN"`     |
| `-method`  | HTTP method (GET, POST, etc.)   | `-method POST`                |
| `-proxy`   | Given proxy                     | `-proxty https://example.com` |
| `-timeout` | Disconnect after given timeout  | `-timeout 10s`                |


### Content Sources

| Switch  | Description                                     |
| ------- | ----------------------------------------------- |
| `-html` | Use saved HTML file                             |
| `-js`   | Parse JavaScript file                           |
| `-xml`  | Parse XML file                                  |

### Extraction Modes

| Switch | Action                                                  |
| ------ |---------------------------------------------------------|
| `-a`   | Extract parameters from `<a>` tags (href query strings) |
| `-i`   | Extract `name` & `id` from `<input>` and `<textarea>` tags |
| `-s`   | Extract JS variables, object keys                       |
| `-f`   | Extract file names with specified extensions            |
| `-e`   | Define file extensions to search (default: `js`)        |
| `-w`   | Extract URLs and file paths                             |
| `-A`   | Enable **All** extraction modes (`-a -i -s -f -w`)      |               |
| `-o`   | Save output to a file                                   |

---

## 💡 Examples

```bash
# 1. Extract all parameters and save to output.txt
paramx -u https://example.com -A -e "js" "html" "xml" -o output.txt

# 2. Parse XML file for Elements names
paramx -xml content.xml
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Please open an issue or submit a pull request on the [GitHub repository](https://github.com/mrmeeseeks01/Paramx).