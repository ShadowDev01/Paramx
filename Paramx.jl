include("src/banner.jl")
include("src/arg.jl")
include("src/func.jl")


function URL(; url::String, ft::String, a::Bool, i::Bool, s::Bool, w::Bool, f::Bool, e::Vector{String})
    try
        header::String, source::String = split(read(`curl -s -i -k $url -H @src/headers.txt`, String), "\r\n\r\n")
        if ft == "html"
            SOURCE(source=source, a=a, i=i, s=s, w=w, f=f, e=e)
        elseif ft == "js"
            JS(source=source, p=true, w=w, f=f, e=e)
        elseif ft == "php"
            PHP(s=source, p=true, w=w, f=f, e=e)
        elseif ft == "xml"
            XML(s=source, p=true, w=w, f=f, e=e)
        end
    catch e
        @error "something wrong" url
        exit(0)
    end
end

function URLS(; file::String, ft::String, a::Bool, i::Bool, s::Bool, w::Bool, f::Bool, e::Vector{String})
    Threads.@threads for url in readlines(file)
        URL(url=url, ft=ft, a=a, i=i, s=s, w=w, f=f, e=e)
    end
end

function SOURCE(; file::String="", source::String="", a::Bool, i::Bool, s::Bool, w::Bool, f::Bool, e::Vector{String})
    if !isempty(source)
        CALL(source=source, a=a, i=i, s=s, w=w, f=f, e=e)
    else
        source = Open(file)
        CALL(source=source, a=a, i=i, s=s, w=w, f=f, e=e)
    end
end

function REQUEST(; file::String, p::Bool, w::Bool, f::Bool, e::Vector{String})
    source::String = Open(file)
    CALL(source=source, RQ=p, w=w, f=f, e=e)
end

function RESPONSE(; file::String, p::Bool, w::Bool, f::Bool, e::Vector{String})
    source::String = Open(file)
    CALL(source=source, RS=p, w=w, f=f, e=e)
end

function JS(; file::String="", source::String="", p::Bool, w::Bool, f::Bool, e::Vector{String})
    if !isempty(source)
        source = "<body>\n<script>\n$source\n</script>\n</body>"
        CALL(source=source, J=p, w=w, f=f, e=e)
    else
        File::String = Open(file)
        source = "<body>\n<script>\n$File\n</script>\n</body>"
        CALL(source=source, J=p, w=w, f=f, e=e)
    end
end

function PHP(; file::String="", s::String="", p::Bool, w::Bool, f::Bool, e::Vector{String})
    if !isempty(s)
        source = s
        CALL(source=source, p=p, w=w, f=f, e=e)
    else
        source = Open(file)
        CALL(source=source, P=p, w=w, f=f, e=e)
    end
end

function XML(; file::String="", s::String="", p::Bool, w::Bool, f::Bool, e::Vector{String})
    if !isempty(s)
        source = s
        CALL(source=source, x=p, w=w, f=f, e=e)
    else
        source = Open(file)
        CALL(source=source, X=p, w=w, f=f, e=e)
    end
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
    ft = arguments["ft"]
    header = arguments["Header"]
    o = arguments["output"]
    count = arguments["count"]

    !isempty(header) && Headers(header)
    !isnothing(arguments["url"]) && URL(url=arguments["url"], ft=ft, a=a, i=i, s=s, w=w, f=f, e=e)
    !isnothing(arguments["urls"]) && URLS(file=arguments["urls"], ft=ft, a=a, i=i, s=s, w=w, f=f, e=e)
    !isnothing(arguments["source"]) && SOURCE(file=arguments["source"], a=a, i=i, s=s, w=w, f=f, e=e)
    !isnothing(arguments["request"]) && REQUEST(file=arguments["request"], p=p, w=w, f=f, e=e)
    !isnothing(arguments["response"]) && RESPONSE(file=arguments["response"], p=p, w=w, f=f, e=e)
    !isnothing(arguments["js"]) && JS(file=arguments["js"], p=p, w=w, f=f, e=e)
    !isnothing(arguments["php"]) && PHP(file=arguments["php"], p=p, w=w, f=f, e=e)
    !isnothing(arguments["xml"]) && XML(file=arguments["xml"], p=p, w=w, f=f, e=e)

    count ? COUNT() : OUT(o)

    Write("src/headers.txt", "w+", "")
end

main()