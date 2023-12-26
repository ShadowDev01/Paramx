using OrderedCollections

Extracted_Parameters = AbstractString[]
Extracted_JS_Objects = AbstractString[]
Extracted_Variables = AbstractString[]
Extracted_URLS = AbstractString[]
Extracted_FILE_NAMES = AbstractString[]


# Find Script Tags
# Extract Variable Names, Object Keys & Parameters
function ExtractScriptTags(source::String)
    for script in eachmatch(r"<script.*?>[\s\S]*?<\/script.*>", source)

        variables = eachmatch(r"(?:let|var|const)\s(\$?\w+)\s?=", script.match)
        objects = eachmatch(r"(?:let|var|const)?\s?[\"\']?([\w\-\@\#\.]+)[\"\']?\s?:", script.match)
        params = eachmatch(r"[\?,\&,\;]([\w\-]+)[\=,\&,\;]?", script.match)

        foreach(variable -> append!(Extracted_Variables, variable.captures), variables)
        foreach(object -> append!(Extracted_JS_Objects, object.captures), objects)
        foreach(param -> append!(Extracted_Parameters, param.captures), params)
    end
end

# Find Script Tags
# Extract Parameters of A Tags
function ExtractATags(source::String)
    for a in eachmatch(r"<a(.*?)>[\s\S]*?<\/a.*>", source)
        for param in eachmatch(r"[\?\&\;]([\w\-\~\+]+)", a.match)
            append!(Extracted_Parameters, param.captures)
        end
    end
end

# Find Script Tags
# Extract values of id, name Attributes
function ExtractInputTags(source::String)
    for input in eachmatch(r"<(?:input|textarea).*?>", source)
        for param in eachmatch(r"(?:name|id)\s?=\s?[\'\"](.+?)[\'\"]", input.match)
            append!(Extracted_Parameters, param.captures)
        end
    end
end

function ExtractFileNames(source::AbstractString, extensions::Vector{String})
    ext = join(extensions, '|')
    regex = Regex("\\/?([\\w\\.\\-]+\\.(?:$ext))")
    files = eachmatch(regex, source)
    foreach(file -> append!(Extracted_FILE_NAMES, file.captures), files)
end

function ExtractUrls(source::AbstractString)
    tags = readlines("src/html_tags.txt")
    regex = r"""(\w+:/)?(/[^\s\(\)\"\'\`\<\>\*\\]+)"""
    urls = eachmatch(regex, source)
    for url in urls
        if url.match ∉ tags
            push!(Extracted_URLS, url.match)
        end
    end
end

function ExtractPHPVariables(source::AbstractString)
    variables = eachmatch(r"\$(\w+)\s?=", source)
    GET_POST = eachmatch(r"\$_(?:GET|POST)\[[\",\'](.*)[\",\']\]", source)

    foreach(var -> append!(Extracted_Variables, var.captures), variables)
    foreach(g_p -> append!(Extracted_Parameters, g_p.captures), GET_POST)
end

function ExtractXMLElemnts(source::String)
    elements = eachmatch(r"<(\w+)[\s\>]", source)
    foreach(element -> append!(Extracted_Parameters, element.captures), elements)
end

# Send Http Request 
function HttpRequest(url::String, method::String="GET")
    response = read(`curl -s -k -X $method $url -H @src/headers.txt`, String)

    # Make Empty Headers
    WriteFile("src/headers.txt", "w+", "")

    return response
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
    data = Dict{String,Int32}()
    for item in Iterators.flatten([
        Extracted_Parameters,
        Extracted_JS_Objects,
        Extracted_Variables,
        Extracted_URLS,
        Extracted_FILE_NAMES
    ])
        haskey(data, item) ? (data[item] += 1) : (data[item] = 1)
    end
    for (key, value) in sort(data, byvalue=true, rev=true)
        println(number ? "$key: $value" : key)
    end
end

#=
function HEADER(H::String)
    res = OrderedDict{String,String}()
    start::String, headers... = split(st, "\n", keepempty=false)
    start2 = split(start, limit=3, keepempty=true)

    get!(res, "protocol", start2[1])
    get!(res, "status_code", start2[2])
    get!(res, "status_text", isassigned(start2, 3) ? start2[3] : "")

    for line in headers
        for m in eachmatch(r"^(?<key>[\w\-]+)\:(?<val>.*)$", line)
            get!(res, m["key"], m["val"])
        end
    end
    return res
end
=#