using OrderedCollections

parameters = AbstractString[]
Urls = AbstractString[]
file_names = AbstractString[]

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

function a_tag(source::String)
    for a in eachmatch(r"<a(.*?)>[\s\S]*?<\/a.*>", source)
        for param in eachmatch(r"[\?\&\;]([\w\-\~\+]+)", a.match)
            append!(parameters, param.captures)
        end
    end
end

function input_tag(source::String)
    for input in eachmatch(r"<(?:input|textarea).*?>", source)
        for param in eachmatch(r"(?:name|id)\s?=\s?[\'\"](.+?)[\'\"]", input.match)
            append!(parameters, param.captures)
        end
    end
end

function script_tag(source::String)
    for script in eachmatch(r"<script.*?>[\s\S]*?<\/script.*>", source)
        variables = eachmatch(r"(?:let|var|const)\s(\w+)\s?=", script.match)
        objects = eachmatch(r"(?:let|var|const)?\s?[\"\']?([\w\-\@\#\.]+)[\"\']?\s?:", script.match)
        params = eachmatch(r"[\?,\&,\;]([\w\-]+)[\=,\&,\;]?", script.match)
        foreach(variable -> append!(parameters, variable.captures), variables)
        foreach(object -> append!(parameters, object.captures), objects)
        foreach(param -> append!(parameters, param.captures), params)
    end
end

function files(source::AbstractString, extensions::Vector{String})
    ext = join(extensions, '|')
    regex = Regex("\\/?([\\w\\.\\-]+\\.(?:$ext))")
    files = eachmatch(regex, source)
    foreach(file -> append!(file_names, file.captures), files)
end

function _urls(source::AbstractString)
    tags = readlines("./src/html_tags.txt")
    regex = r"""(\w+:/)?(/[^\s\(\)\"\'\`\<\>\*\\]+)"""
    urls = eachmatch(regex, source)
    for url in urls
        if url.match ∉ tags
            push!(Urls, url.match)
        end
    end
end

function php(source::AbstractString)
    variables = eachmatch(r"\$(\w+)\s?=", source)
    GET_POST = eachmatch(r"\$_(?:GET|POST)\[[\",\'](.*)[\",\']\]", source)
    foreach(var -> append!(parameters, var.captures), variables)
    foreach(g_p -> append!(parameters, g_p.captures), GET_POST)
end

function xml(source::String)
    elements = eachmatch(r"<(\w+)[\s\>]", source)
    foreach(element -> append!(parameters, element.captures), elements)
end

function Headers(H::Vector{String})
    headers_file = open("src/headers.txt", "w+") do f
        write(f, join(H, "\n"))
    end
end

function CALL(; source::String, J::Bool=false, P::Bool=false, X::Bool=false, RQ::Bool=false, RS::Bool=false, a::Bool=false, i::Bool=false, s::Bool=false, p::Bool=false, w::Bool=false, f::Bool=false, e::Vector{String}=["js"])
    @sync begin
        @async begin
            P && php(source)
            X && xml(source)
            (RQ || RS) && (script_tag(source); input_tag(source))
            a && a_tag(source)
            i && input_tag(source)
            w && _urls(source)
            (s || J) && script_tag(source)
            (f && !isempty(e)) && files(source, e)
        end
    end
end

function Open(file::String)
    try
        File::String = open(file) do f
            read(f, String)
        end
        return File
    catch e
        @error "there is no file: $file"
        exit(0)
    end

end

function Write(filename::String, mode::String, data::String)
    open(filename, mode) do file
        write(file, data)
    end
end

function COUNT(number::Bool)
    data = Dict{String,Int32}()
    for i in Iterators.flatten([parameters, Urls, file_names])
        haskey(data, i) ? (data[i] += 1) : (data[i] = 1)
    end
    for (k, v) in sort(data, byvalue=true, rev=true)
        println(number ? "$k: $v" : k)
    end
end

function OUT(o)
    data = join(union(parameters, Urls, file_names), "\n")
    !isnothing(o) ? Write(o, "w+", data) : println(data)
end