parameters = Set{AbstractString}()
Urls = Set{AbstractString}()
file_names = Set{AbstractString}()


function a_tag(source::String)
    for a in eachmatch(r"<a(.*?)>[\s\S]*?<\/a.*>", source)
        for param in eachmatch(r"[\?\&\;]([\w\-\~\+]+)", a.match)
            push!(parameters, param.captures...)
        end
    end
end

function input_tag(source::String)
    for input in eachmatch(r"<(?=input|textarea).*?>", source)
        for param in eachmatch(r"(name|id)\s?=\s?[\'\"](.+?)[\'\"]", input.match)
            push!(parameters, param.captures[2])
        end
    end
end

function script_tag(source::String)
    for script in eachmatch(r"<script.*?>[\s\S]*?<\/script.*>", source)
        variables = eachmatch(r"(let|var|const)\s(\w+)\s?=", script.match)
        objects = eachmatch(r"(let|var|const)?\s?[\",\']?([\w\.]+)[\",\']?\s?:", script.match)
        params = eachmatch(r"[\?,\&,\;]([\w\-]+)[\=,\&,\;]?", script.match)
        foreach(variable -> push!(parameters, variable.captures[2]), variables)
        foreach(object -> push!(parameters, object.captures[2]), objects)
        foreach(param -> push!(parameters, param.captures...), params)
    end
end

function files(source::AbstractString, extensions::Vector{String})
    ext = join(extensions, '|')
    regex = Regex("\\/?([\\w,\\.,\\-]+\\.($ext))")
    files = eachmatch(regex, source)
    foreach(file -> push!(file_names, file.captures[1]), files)
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
    GET_POST = eachmatch(r"\$_(GET|POST)\[[\",\'](.*)[\",\']\]", source)
    foreach(var -> push!(parameters, var.captures[1]), variables)
    foreach(g_p -> push!(parameters, g_p.captures[2]), GET_POST)
end

function xml(source::String)
    elements = eachmatch(r"<(\w+)[\s\>]", source)
    foreach(element -> push!(parameters, element.captures[1]), elements)
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

function OUT(o)
    data = join(union(parameters, Urls, file_names), "\n")
    !isnothing(o) ? Write(o, "w+", data) : println(data)
end