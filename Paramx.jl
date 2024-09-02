include("src/package.jl")
include("src/arg.jl")
include("src/banner.jl")
include("src/func.jl")
include("src/logger.jl")


# user passed cli arguments
const args = ARGUMENTS()


function ParseHttpResponse(url::String)
	response::String = SendHttpRequest(url, args["method"], args["Header"])

	if args["ft"] == "html"
		HtmlSource(response)
	elseif args["ft"] == "js"
		JSSource(response)
	elseif args["ft"] == "xml"
		XMLSource(response)
	elseif args["ft"] == "php"
		PHPSource(response)
	end
end

# Extract Data From HTML Source
function HtmlSource(source::String)
	args["w"] && extract_url(source)
	args["a"] && extract_a_tags(source)
	args["i"] && extract_input_tags(source)
	args["s"] && extract_script_tags(source)
	args["f"] && extract_file_name(source, args["e"])
end

# Extract Data From Given JS Source
function JSSource(source::String)
	source = "<body>\n<script>\n$source\n</script>\n</body>"
	args["p"] && extract_script_tags(source)
	args["w"] && extract_url(source)
	args["f"] && extract_file_name(source, args["e"])
end

# Extract Data From Given PHP Source
function PHPSource(source::String)
	args["p"] && extract_php_params(source)
	args["w"] && extract_url(source)
	args["f"] && extract_file_name(source, args["e"])
end

# Extract Data From Given XML Source
function XMLSource(source::String)
	args["p"] && extract_xml_elemnts(source)
	args["w"] && extract_url(source)
	args["f"] && extract_file_name(source, args["e"])
end

function HtmlRequestText(source::String)
	if args["p"]
		extract_script_tags(source)
		extract_input_tags(source)
	end
	args["w"] && extract_url(source)
	args["f"] && extract_file_name(source, args["e"])
end

function HtmlResponseText(source::String)
	if args["p"]
		extract_script_tags(source)
		extract_input_tags(source)
	end
	args["w"] && extract_url(source)
	args["f"] && extract_file_name(source, args["e"])
end


function main()

	args["silent"] || banner()
	args["silent"] || log_message()

	# Call Functions
	if !isnothing(args["url"])
		ParseHttpResponse(args["url"])
	end

	if !isnothing(args["urls"])
		Threads.@threads for url in readlines(args["urls"])
			try
				ParseHttpResponse(url)
			catch e
				@error """something wrong with $(args["urls"])"""
				exit(0)
			end
		end
	end

	if !isnothing(args["source"])
		HtmlFile = ReadFile(args["source"])
		HtmlSource(HtmlFile)
	end

	if !isnothing(args["js"])
		JSFile = ReadFile(args["js"])
		JSSource(JSFile)
	end

	if !isnothing(args["php"])
		PHPFile = ReadFile(args["php"])
		PHPSource(PHPFile)
	end

	if !isnothing(args["xml"])
		XMLFile = ReadFile(args["xml"])
		XMLSource(XMLFile)
	end

	if !isnothing(args["request"])
		HtmlRequestFile = ReadFile(args["request"])
		HtmlRequestText(HtmlRequestFile)
	end

	if !isnothing(args["response"])
		HtmlResponseFile = ReadFile(args["response"])
		HtmlResponseText(HtmlResponseFile)
	end

	# Check work switch be enabled
	check_work_switches::Bool = any([
		args["A"], args["a"], args["i"],
		args["s"], args["p"], args["f"],
		args["w"],
	])

	if !check_work_switches
		@warn "please select work switch: -a / -i / ..."
		exit(0)
	end

	Data = union(
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
	)

	if args["c"]
		CountItems(false)
		exit(0)
	elseif args["cn"]
		CountItems(true)
		exit(0)
	elseif args["T"]
		TagParameters(Data)
		!isnothing(args["output"]) && @goto save
		exit(0)
	end

	args["silent"] || @info "\033[33m$(length(Data)) Items Found\033[0m"

	@label save
	if !isnothing(args["output"])
		WriteFile(args["output"], "w+", join(Data, "\n"))
		args["silent"] || @info "data saved in file: $colorGreen$(args["output"])$colorReset"
	else
		print(join(Data, "\n"))
	end

	write("src/body", "")
end

main()
