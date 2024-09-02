using OrderedCollections
using Downloads

const colorReset = "\033[0m"
const colorRed = "\033[31m"
const colorLightRed = "\033[91m"
const colorGreen = "\033[32m"
const colorYellow = "\033[33m"
const colorLightYellow = "\033[93m"
const colorBlue = "\033[34m"
const colorLightBlue = "\033[94m"
const colorCyan = "\033[96m"
const colorMagenta = "\033[35m"
const colorLightMagenta = "\033[95m"
const colorWhite = "\033[97m"
const colorBlack = "\033[30m"
const textItalic = "\033[3m"
const textBold = "\033[1m"
const textBox = "\033[7m"
const textBlink = "\033[5m"
const textUnderline = "\033[4m"

# JS Extracted Parameters
EXTRACTED_JS_VARIABLES = AbstractString[]
EXTRACTED_JS_OBJECTS = AbstractString[]
EXTRACTED_JS_FUNC_ARGS = AbstractString[]

# Form Tag's Extracted Parameters
EXTRACTED_INPUT_TEXTAREA_ID_NAME = AbstractString[]

# URLS/PATHS Extracted With Parameters
EXTRACTED_URLS_OR_PATHS = AbstractString[]
EXTRACTED_QUERY_KEYS = AbstractString[]

# PHP Extracted Parameters 
EXTRACTED_PHP_VARIABLES = AbstractString[]
EXTRACTED_PHP_GET_POST = AbstractString[]

# XML Extracted Parameters
EXTRACTED_XML_ELEMENTS = AbstractString[]

# Extracted File Names With Given Extensions
EXTRACTED_FILE_NAMES = AbstractString[]


# Find Script Tags & Extract Parameters
function extract_script_tags(source::String)
	for script in eachmatch(r"<script.*?>[\s\S]*?<\/script.*>", source)
		script_match::String = script.match

		extract_js_variables(script_match)
		extract_js_objects_keys(script_match)
		extract_js_func_args(script_match)
		extract_js_url_params(script_match)
	end
end

# extract defined js variables name
function extract_js_variables(script::String)
	variables = eachmatch(r"(?:let|var|const)\s(\$?\w+)\s?=", script)
	foreach(variable -> append!(EXTRACTED_JS_VARIABLES, variable.captures), variables)
end

# extract js objects keys
function extract_js_objects_keys(script::String)
	objects = eachmatch(r"(?:let|var|const)?\s?(?<=[\"\'])([\w\@\#\\$-\.]+)(?=[\"\']\s?:)", script)
	foreach(object -> append!(EXTRACTED_JS_OBJECTS, object.captures), objects)
end

# extract js url parameters
function extract_js_url_params(script::String)
	params = eachmatch(r"[\?,\&,\;]([\w\-]+)[\=,\&,\;]?", script)
	foreach(param -> append!(EXTRACTED_QUERY_KEYS, param.captures), params)
end

# extract js Functions arguments name
function extract_js_func_args(script::String)
	funcArgs = eachmatch(
		Regex(
			".*\\(\\s*[\"']?([\\w\\-]+)[\"']?\\s*(,\\s*[\"']?([\\w\\-]+)[\"']?\\s*)?(,\\s*[\"']?([\\w\\-]+)[\"']?\\s*)?(,\\s*[\"']?([\\w\\-]+)[\"']?\\s*)?(,\\s*[\"']?([\\w\\-]+)[\"']?\\s*)?(,\\s*[\"']?([\\w\\-]+)[\"']?\\s*)?(,\\s*[\"']?([\\w\\-]+)[\"']?\\s*)?(,\\s*[\"']?([\\w\\-]+)[\"']?\\s*)?(,\\s*[\"']?([\\w\\-]+)[\"']?\\s*)?\\)",
		),
		script,
	)

	for args in funcArgs
		for arg in keepat!(args.captures, [1, 3, 5, 7, 9, 11, 13, 15, 17])
			isnothing(arg) || push!(EXTRACTED_JS_FUNC_ARGS, arg)
		end
	end
end


# Find A Tags
# Extract Parameters of A Tags
function extract_a_tags(source::String)
	for a in eachmatch(r"<a(.*?)>[\s\S]*?<\/a.*>", source)
		for param in eachmatch(r"[\?\&\;]([\w\-\~\+]+)", a.match)
			append!(EXTRACTED_QUERY_KEYS, param.captures)
		end
	end
end

# Find Input/Textarea Tags
# Extract values of id, name Attributes
function extract_input_tags(source::String)
	for input in eachmatch(r"<(?:input|textarea).*?>", source)
		for param in eachmatch(r"(?:name|id)\s?=\s?[\'\"](.+?)[\'\"]", input.match)
			append!(EXTRACTED_INPUT_TEXTAREA_ID_NAME, param.captures)
		end
	end
end

# Extract Files Name With Given Extensions
function extract_file_name(source::AbstractString, extensions::Vector{String})
	ext = join(extensions, '|')
	regex = Regex("\\/?([\\w\\.\\-]+\\.(?:$ext))")
	files = eachmatch(regex, source)
	foreach(file -> append!(EXTRACTED_FILE_NAMES, file.captures), files)
end

# Extract URLs
function extract_url(source::AbstractString)
	regex = r"""[\w\/\:\\]+?(/+[^\s\(\)\"\'\`\<\>\*\\]+)"""
	urls = eachmatch(regex, source)
	for url in urls
		push!(EXTRACTED_URLS_OR_PATHS, url.match)
	end
end

# Extract PHP variables & Parameters
function extract_php_params(source::AbstractString)
	variables = eachmatch(r"\$(\w+)\s?=", source)
	GET_POST = eachmatch(r"\$_(?:GET|POST)\[[\",\'](.*)[\",\']\]", source)

	foreach(var -> append!(EXTRACTED_PHP_VARIABLES, var.captures), variables)
	foreach(g_p -> append!(EXTRACTED_PHP_GET_POST, g_p.captures), GET_POST)
end

# Extract XML Elements Name
function extract_xml_elemnts(source::String)
	elements = eachmatch(r"(?<=\<)(\w+)", source)
	foreach(element -> append!(EXTRACTED_XML_ELEMENTS, element.captures), elements)
end

function ParseHttpHeaders(headers::Vector{String})
	parsed_headers = []
	for header in headers
		if occursin(":", header)
			key, val = split(header, ":", limit = 2)
			push!(parsed_headers, strip(key) => strip(val))
		else
			@warn "$colorLightRed`$header`$colorReset is missing ':' in custom headers"
		end
	end
	return parsed_headers
end

# Send Http Request 
function SendHttpRequest(url::String, method::String = "GET", headers::Vector{String} = [])
	user_method = uppercase(method)
	valid_methods = (
		"GET", "POST", "PUT",
		"HEAD", "DELETE", "CONNECT",
		"OPTIONS", "TRACE", "PATCH",
	)
	if method ∉ valid_methods
		@warn "Http methods: $colorGreen $(join(valid_methods, " "))$colorReset\nyour method: $colorLightRed$(method)$colorReset 🤔"
	end

	try
		Downloads.request(
			url,
			method = user_method,
			headers = ParseHttpHeaders(headers),
			output = "src/body",
		)
		return ReadFile("src/body")
	catch err
		isa(err, RequestError) && @warn sprint(showerror, err.message)
		exit(0)
	end
end

function ReadFile(FilePath::String)
	if !isfile(FilePath)
		@error "No Such File or Directory: $FilePath"
		exit(0)
	end
	File = open(FilePath, "r") do file
		read(file, String)
	end
	return File
end

function WriteFile(FilePath::String, Mode::String, Data::String)
	open(FilePath, Mode) do file
		write(file, Data)
	end
end

function CountItems(number::Bool)
	data = Dict{String, Int32}()
	for item in Iterators.flatten([
		EXTRACTED_JS_VARIABLES,
		EXTRACTED_JS_OBJECTS,
		EXTRACTED_JS_FUNC_ARGS,
		EXTRACTED_INPUT_TEXTAREA_ID_NAME,
		EXTRACTED_URLS_OR_PATHS,
		EXTRACTED_QUERY_KEYS,
		EXTRACTED_PHP_VARIABLES,
		EXTRACTED_PHP_GET_POST,
		EXTRACTED_XML_ELEMENTS,
		EXTRACTED_FILE_NAMES,
	])
		haskey(data, item) ? (data[item] += 1) : (data[item] = 1)
	end
	for (key, value) in sort(data, byvalue = true, rev = true)
		println(number ? "$key $colorYellow$value$colorReset" : key)
	end
end

function TagParameters(Data::Vector{AbstractString})
	for param in Data
		print(param, "\t")
		param ∈ EXTRACTED_JS_VARIABLES && (printstyled("js_var", color = :yellow, bold = true, reverse = true, italic = true); print("  "))
		param ∈ EXTRACTED_JS_OBJECTS && (printstyled("js_obj", color = :light_yellow, bold = true, reverse = true, italic = true); print("  "))
		param ∈ EXTRACTED_JS_FUNC_ARGS && (printstyled("js_arg", color = :yellow, bold = true, reverse = true, italic = true); print("  "))
		param ∈ EXTRACTED_INPUT_TEXTAREA_ID_NAME && (printstyled("form_id_name", color = :red, bold = true, reverse = true, italic = true); print("  "))
		param ∈ EXTRACTED_URLS_OR_PATHS && (printstyled("url/path", color = :blue, bold = true, reverse = true, italic = true); print("  "))
		param ∈ EXTRACTED_QUERY_KEYS && (printstyled("query_key", color = :magenta, bold = true, reverse = true, italic = true); print("  "))
		param ∈ EXTRACTED_PHP_VARIABLES && (printstyled("php_var", color = :magenta, bold = true, reverse = true, italic = true); print("  "))
		param ∈ EXTRACTED_PHP_GET_POST && (printstyled("php_key", color = :light_magenta, bold = true, reverse = true, italic = true); print("  "))
		param ∈ EXTRACTED_XML_ELEMENTS && (printstyled("xml", color = :cyan, bold = true, reverse = true, italic = true); print("  "))
		param ∈ EXTRACTED_FILE_NAMES && (printstyled("file", color = :green, bold = true, reverse = true, italic = true); print("  "))
		println()
	end
end

#=
# Send Http Request 
function HttpRequest(url::String, method::String="GET")
	method = uppercase(method)
	if method ∉ ("GET", "POST", "PUT", "HEAD", "DELETE", "CONNECT", "OPTIONS", "TRACE", "PATCH")
		@warn "Http methods: \033[32mGET POST PUT HEAD DELETE CONNECT OPTIONS TRACE PATCH\033[0m\nyour method: \033[31m$(method)\033[0m 🤔"
	end

	response = read(`curl -s -k -X $method $url -H @src/headers.txt`, String)

	# Make Empty Headers
	WriteFile("src/headers.txt", "w+", "")

	return response
end
=#
