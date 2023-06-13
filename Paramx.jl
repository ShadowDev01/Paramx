include("./src/arg.jl")
include("./src/func.jl")
using HTTP
using Gumbo

parameter = Set{AbstractString}()
Urls = Set{AbstractString}()
file_names = Set{AbstractString}()

function URL(url::String, a::Bool, i::Bool, s::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    req::HTTP.Messages.Response = HTTP.get(url)
    source::String = req |> String
    html::HTMLDocument = parsehtml(String(req.body))
    a && a_tag(html)
    i && input_tag(html)
    s && script_tag(html)
    w && _urls(source)
    (f && !isempty(e)) && files(source, e)
    data = join(union(parameter, Urls, file_names), "\n")
    !isnothing(o) ? Write(o, "w+", data) : println(data)
end

function URLS(file::String, a::Bool, i::Bool, s::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    for url in eachline(file)
        req::HTTP.Messages.Response = HTTP.get(url)
        source::String = req |> String
        html::HTMLDocument = parsehtml(String(req.body))
        a && a_tag(html)
        i && input_tag(html)
        s && script_tag(html)
        w && _urls(source)
        (f && !isempty(e)) && files(source, e)
        data = join(union(parameter, Urls, file_names), "\n")
        !isnothing(o) ? Write(o, "w+", data) : println(data)
    end
end

function SOURCE(file::String, a::Bool, i::Bool, s::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    source::String = Open(file)
    html::HTMLDocument = parsehtml(String(source))
    a && a_tag(html)
    i && input_tag(html)
    s && script_tag(html)
    w && _urls(source)
    (f && !isempty(e)) && files(source, e)
    data = join(union(parameter, Urls, file_names), "\n")
    !isnothing(o) ? Write(o, "w+", data) : println(data)
end

function REQUEST(file::String, p::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    source::String = Open(file)
    header, body = split(source, "\r\n\r\n")
    if startswith(lowercase(body), "<!doctype html>")
        html = parsehtml(body)
    else
        html = parsehtml("<body><script>$body</script></body>")
    end
    p && (script_tag(html); headers(header))
    w && _urls(source)
    (f && !isempty(e)) && files(source, e)
    data = join(union(parameter, Urls, file_names), "\n")
    !isnothing(o) ? Write(o, "w+", data) : println(data)
end

function RESPONSE(file::String, i::Bool, p::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    source::String = Open(file)
    header, body = split(source, "\n\n")
    if startswith(lowercase(body), "<!doctype html>")
        html = parsehtml(body)
    else
        html = parsehtml("<body><script>$body</script></body>")
    end
    i && input_tag(html)
    p && (script_tag(html); headers(header))
    w && _urls(source)
    (f && !isempty(e)) && files(source, e)
    data = join(union(parameter, Urls, file_names), "\n")
    !isnothing(o) ? Write(o, "w+", data) : println(data)
end

function JS(file::String, w::Bool, f::Bool, e::Vector{String}, o)
    source::String = Open(file)
    html::HTMLDocument = parsehtml("<body><script>$source</script></body>")
    script_tag(html)
    w && _urls(source)
    (f && !isempty(e)) && files(source, e)
    data = join(union(parameter, Urls, file_names), "\n")
    !isnothing(o) ? Write(o, "w+", data) : println(data)
end

function PHP(file::String, p::Bool, f::Bool, e::Vector{String}, o)
    source::String = Open(file)
    p && php(source)
    (f && !isempty(e)) && files(source, e)
    data = join(union(parameter, Urls, file_names), "\n")
    !isnothing(o) ? Write(o, "w+", data) : println(data)
end

function main()
    check_arguments()
    arguments = ARGUMENTS()

    a = arguments["a"]
    i = arguments["input"]
    s = arguments["script"]
    w = arguments["w"]
    p = arguments["p"]
    f = arguments["file-names"]
    e = arguments["extension"]
    o = arguments["output"]

    !isnothing(arguments["url"]) && URL(arguments["url"], a, i, s, w, f, e, o)
    !isnothing(arguments["urls"]) && URLS(arguments["urls"], a, i, s, w, f, e, o)
    !isnothing(arguments["source"]) && SOURCE(arguments["source"], a, i, s, w, f, e, o)
    !isnothing(arguments["request"]) && REQUEST(arguments["request"], p, w, f, e, o)
    !isnothing(arguments["response"]) && RESPONSE(arguments["response"], i, p, w, f, e, o)
    !isnothing(arguments["js"]) && JS(arguments["js"], w, f, e, o)
    !isnothing(arguments["php"]) && PHP(arguments["php"], p, f, e, o)
end

main()