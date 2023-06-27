using Cascadia
using Gumbo

parameter = Set{AbstractString}()
Urls = Set{AbstractString}()
file_names = Set{AbstractString}()

function input_tag(html::HTMLDocument)
    inputs = eachmatch(Selector("input"), html.root)
    textareas = eachmatch(Selector("textarea"), html.root)
    append!(inputs, textareas)
    for input in inputs
        push!(parameter, get(input.attributes, "name", ""))
        push!(parameter, get(input.attributes, "id", ""))
    end
end

function a_tag(html::HTMLDocument)
    as = eachmatch(Selector("a"), html.root)
    for a in as
        href = get(a.attributes, "href", "")
        for match in eachmatch(r"[\?,\&,\;]([\w\-]+)[\=,\&,\;]?", href)
            push!(parameter, match.captures...)
        end
    end
end

function script_tag(html::HTMLDocument)
    scripts = eachmatch(Selector("script"), html.root)
    for script in scripts
        variables = eachmatch(r"(let|var|const)\s(\w+)\s?=", string(script))
        objects = eachmatch(r"(let|var|const)?\s?[\",\']?([\w\.]+)[\",\']?\s?:", string(script))
        params = eachmatch(r"[\?,\&,\;]([\w\-]+)[\=,\&,\;]?", string(script))
        foreach(variable -> push!(parameter, variable.captures[2]), variables)
        foreach(object -> push!(parameter, object.captures[2]), objects)
        foreach(param -> push!(parameter, param.captures...), params)
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
    foreach(var -> push!(parameter, var.captures[1]), variables)
    foreach(g_p -> push!(parameter, g_p.captures[2]), GET_POST)
end

function xml(source::String)
    elements = eachmatch(r"<(\w+)[\s\>]", source)
    foreach(element -> push!(parameter, element.captures[1]), elements)
end

function content(source::String)
    forms = eachmatch(r"<(input|textarea).*>", source)
    variables = eachmatch(r"(let|var|const)\s(\w+)\s?=", source)
    objects = eachmatch(r"(let|var|const)?\s?[\",\']?([\w\.]+)[\",\']?\s?:", source)
    params = eachmatch(r"[\?,&,;](\w+)=", source)
    foreach(variable -> push!(parameter, variable.captures[2]), variables)
    foreach(object -> push!(parameter, object.captures[2]), objects)
    foreach(param -> push!(parameter, param.captures[1]), params)
    for form in forms
        for item in eachmatch(r"(name|id)\s?=\s?[\'\"](.+?)[\'\"]", form.match)
            push!(parameter, item.captures[2])
        end
    end
end

function CALL(source::String, html::HTMLDocument=""; a::Bool=false, i::Bool=false, s::Bool=false, w::Bool=false, f::Bool=false, e::Vector{String}=["js"])
    @sync begin
        @async begin
            a && a_tag(html)
            i && input_tag(html)
            s && script_tag(html)
            w && _urls(source)
            (f && !isempty(e)) && files(source, e)
        end
    end
end

function CALL2(source; m::Bool=false, p::Bool=false, x::Bool=false, w::Bool=false, f::Bool=false, e::Vector{String}=["js"])
    @sync begin
        @async begin
            m && content(source)
            p && php(source)
            x && xml(source)
            w && _urls(source)
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
    data = join(union(parameter, Urls, file_names), "\n")
    !isnothing(o) ? Write(o, "w+", data) : println(data)
end