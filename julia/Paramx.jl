include("./src/banner.jl")
include("./src/arg.jl")
include("./src/func.jl")


function URL(; url::String, ft::String, a::Bool, i::Bool, s::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    try
        source::String = read(`curl -s $url`, String)
        if ft == "html"
            SOURCE(source=source, a=a, i=i, s=s, w=w, f=f, e=e, o=o)
        elseif ft == "js"
            JS(source=source, p=true, w=w, f=f, e=e, o=o)
        elseif ft == "php"
            PHP(s=source, p=true, w=w, f=f, e=e, o=o)
        elseif ft == "xml"
            XML(s=source, p=true, w=w, f=f, e=e, o=o)
        end
    catch e
        @error "invalid url" url
        exit(0)
    end
end

function URLS(; file::String, ft::String, a::Bool, i::Bool, s::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    Threads.@threads for url in readlines(file)
        URL(url=url, ft=ft, a=a, i=i, s=s, w=w, f=f, e=e, o=o)
    end
end

function SOURCE(; file::String="", source::String="", a::Bool, i::Bool, s::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    if !isempty(source)
        CALL(source=source, a=a, i=i, s=s, w=w, f=f, e=e)
    else
        source = Open(file)
        CALL(source=source, a=a, i=i, s=s, w=w, f=f, e=e)
    end
    OUT(o)
end

function REQUEST(; file::String, p::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    source::String = Open(file)
    CALL(source=source, RQ=p, w=w, f=f, e=e)
    OUT(o)
end

function RESPONSE(; file::String, p::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    source::String = Open(file)
    CALL(source=source, RS=p, w=w, f=f, e=e)
    OUT(o)
end

function JS(; file::String="", source::String="", p::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    if !isempty(source)
        source = "<body>\n<script>\n$source\n</script>\n</body>"
        CALL(source=source, J=p, w=w, f=f, e=e)
    else
        File::String = Open(file)
        source = "<body>\n<script>\n$File\n</script>\n</body>"
        CALL(source=source, J=p, w=w, f=f, e=e)
    end
    OUT(o)
end

function PHP(; file::String="", s::String="", p::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    if !isempty(s)
        source = s
        CALL(source=source, p=p, w=w, f=f, e=e)
    else
        source = Open(file)
        CALL(source=source, P=p, w=w, f=f, e=e)
    end
    OUT(o)
end

function XML(; file::String="", s::String="", p::Bool, w::Bool, f::Bool, e::Vector{String}, o)
    if !isempty(s)
        source = s
        CALL(source, x=p, w=w, f=f, e=e)
    else
        source = Open(file)
        CALL(source, X=p, w=w, f=f, e=e)
    end
    OUT(o)
end

function main()
    check_arguments()
    arguments = ARGUMENTS()

    a = arguments["a"]
    i = arguments["i"]
    s = arguments["script"]
    w = arguments["w"]
    p = arguments["p"]
    f = arguments["file-names"]
    e = arguments["extension"]
    o = arguments["output"]
    ft = arguments["ft"]

    !isnothing(arguments["url"]) && URL(url=arguments["url"], ft=ft, a=a, i=i, s=s, w=w, f=f, e=e, o=o)
    !isnothing(arguments["urls"]) && URLS(file=arguments["urls"], ft=ft, a=a, i=i, s=s, w=w, f=f, e=e, o=o)
    !isnothing(arguments["source"]) && SOURCE(file=arguments["source"], a=a, i=i, s=s, w=w, f=f, e=e, o=o)
    !isnothing(arguments["request"]) && REQUEST(file=arguments["request"], p=p, w=w, f=f, e=e, o=o)
    !isnothing(arguments["response"]) && RESPONSE(file=arguments["response"], p=p, w=w, f=f, e=e, o=o)
    !isnothing(arguments["js"]) && JS(file=arguments["js"], p=p, w=w, f=f, e=e, o=o)
    !isnothing(arguments["php"]) && PHP(file=arguments["php"], p=p, w=w, f=f, e=e, o=o)
    !isnothing(arguments["xml"]) && XML(file=arguments["xml"], p=p, w=w, f=f, e=e, o=o)
end

main()