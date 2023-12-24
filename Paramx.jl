include("src/banner.jl")
include("src/arg.jl")
include("src/func.jl")


function ParseHttpResponse(url::String; Method::String, FileType::String, Parameters::Bool, ATag::Bool, InputTag::Bool, ScriptTag::Bool, Urls::Bool, FileNames::Bool, Extensions::Vector{String})
    response::String = HttpRequest(url, Method)

    if FileType == "html"
        HtmlSource(response, ATag=ATag, InputTag=InputTag, ScriptTag=ScriptTag, Urls=Urls, FileNames=FileNames, Extensions=Extensions)
    elseif FileType == "js"
        JSSource(response, Parameters=Parameters, Urls=Urls, FileNames=FileNames, Extensions=Extensions)
    elseif FileType == "xml"
        XMLSource(response, Parameters=Parameters, Urls=Urls, FileNames=FileNames, Extensions=Extensions)
    elseif FileType == "php"
        PHPSource(response, Parameters=Parameters, Urls=Urls, FileNames=FileNames, Extensions=Extensions)
    end
end

# Extract Data From HTML Source
function HtmlSource(source::String; ATag::Bool, InputTag::Bool, ScriptTag::Bool, Urls::Bool, FileNames::Bool, Extensions::Vector{String})
    Urls && ExtractUrls(source)
    ATag && ExtractATags(source)
    InputTag && ExtractInputTags(source)
    ScriptTag && ExtractScriptTags(source)
    FileNames && ExtractFileNames(source, Extensions)
end

# Extract Data From Given JS Source
function JSSource(source::String; Parameters::Bool, Urls::Bool, FileNames::Bool, Extensions::Vector{String})
    source = "<body>\n<script>\n$source\n</script>\n</body>"
    Parameters && ExtractScriptTags(source)
    Urls && ExtractUrls(source)
    FileNames && ExtractFileNames(source, Extensions)
end

# Extract Data From Given PHP Source
function PHPSource(source::String; Parameters::Bool, Urls::Bool, FileNames::Bool, Extensions::Vector{String})
    Parameters && ExtractPHPVariables(source)
    Urls && ExtractUrls(source)
    FileNames && ExtractFileNames(source, Extensions)
end

# Extract Data From Given XML Source
function XMLSource(source::String; Parameters::Bool, Urls::Bool, FileNames::Bool, Extensions::Vector{String})
    Parameters && ExtractXMLElemnts(source)
    Urls && ExtractUrls(source)
    FileNames && ExtractFileNames(source, Extensions)
end


function HtmlRequestText(source::String; Parameters::Bool, Urls::Bool, FileNames::Bool, Extensions::Vector{String})
    if Parameters
        ExtractScriptTags(source)
        ExtractInputTags(source)
    end
    Urls && ExtractUrls(source)
    FileNames && ExtractFileNames(source, Extensions)
end

function HtmlResponseText(source::String; Parameters::Bool, Urls::Bool, FileNames::Bool, Extensions::Vector{String})
    if Parameters
        ExtractScriptTags(source)
        ExtractInputTags(source)
    end
    Urls && ExtractUrls(source)
    FileNames && ExtractFileNames(source, Extensions)
end


function main()
    check_arguments()

    # CLI Arguments Passed By User
    arguments = ARGUMENTS()

    # Extract Passed Arguments
    ATags = arguments["a"]
    InputTags = arguments["i"]
    ScriptTags = arguments["script"]
    Urls = arguments["w"]
    Parameters = arguments["p"]
    FileNames = arguments["file-names"]
    Extensions = arguments["extension"]
    FileType = arguments["ft"]
    Method = arguments["method"]
    Output = arguments["output"]
    CountItemNumber = arguments["cn"]
    CountItem = arguments["count"]

    # Manage Passed Headers
    Header = arguments["Header"]
    WriteFile("src/headers.txt", "w+", join(Header, "\n"))

    # Extract Passed source_args
    HtmlFile = arguments["source"]
    JSFile = arguments["js"]
    PHPFile = arguments["php"]
    XMLFile = arguments["xml"]
    URL = arguments["url"]
    URLS = arguments["urls"]
    HtmlRequestFile = arguments["request"]
    HtmlResponseFile = arguments["response"]

    # Call Functions
    if !isnothing(URL)
        ParseHttpResponse(URL, Method=Method, Parameters=Parameters, FileType=FileType, ATag=ATags, InputTag=InputTags, ScriptTag=ScriptTags, Urls=Urls, FileNames=FileNames, Extensions=Extensions)
    end

    if !isnothing(URLS)
        Threads.@threads for url in URLS
            ParseHttpResponse(url, Method=Method, FileType=FileType, ATag=ATags, InputTag=InputTags, ScriptTag=ScriptTags, Urls=Urls, FileNames=FileNames, Extensions=Extensions)
        end
    end

    if !isnothing(HtmlFile)
        HtmlFile = ReadFile(HtmlFile)
        HtmlSource(HtmlFile, ATag=ATags, InputTag=InputTags, ScriptTag=ScriptTags, Urls=Urls, FileNames=FileNames, Extensions=Extensions)
    end

    if !isnothing(JSFile)
        JSFile = ReadFile(JSFile)
        JSSource(JSFile, Parameters=Parameters, Urls=Urls, FileNames=FileNames, Extensions=Extensions)
    end

    if !isnothing(PHPFile)
        PHPFile = ReadFile(PHPFile)
        PHPSource(PHPFile, Parameters=Parameters, Urls=Urls, FileNames=FileNames, Extensions=Extensions)
    end

    if !isnothing(XMLFile)
        XMLFile = ReadFile(XMLFile)
        XMLSource(XMLFile, Parameters=Parameters, Urls=Urls, FileNames=FileNames, Extensions=Extensions)
    end

    if !isnothing(HtmlRequestFile)
        HtmlRequestFile = ReadFile(HtmlRequestFile)
        HtmlRequestText(HtmlRequestFile, Parameters=Parameters, Urls=Urls, FileNames=FileNames, Extensions=Extensions)
    end

    if !isnothing(HtmlResponseFile)
        HtmlResponseFile = ReadFile(HtmlResponseFile)
        HtmlResponseText(HtmlResponseFile, Parameters=Parameters, Urls=Urls, FileNames=FileNames, Extensions=Extensions)
    end

    if CountItem
        CountItems(false)
        exit(0)
    elseif CountItemNumber
        CountItems(true)
        exit(0)
    end

    Data = union(
        Extracted_Parameters,
        Extracted_JS_Objects,
        Extracted_Variables,
        Extracted_URLS,
        Extracted_FILE_NAMES
    )

    if !isnothing(Output)
        Write(Output, join(Data, "\n"))
    else
        print(join(Data, "\n"))
    end
end

main()