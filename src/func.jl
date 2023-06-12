using Cascadia
using Gumbo


function input_tag(html::HTMLDocument)
    inputs = eachmatch(Selector("input"), html.root)
    for input in inputs
        push!(parameter, get(input.attributes, "name", ""))
        push!(parameter, get(input.attributes, "id", ""))
    end
end

function a_tag(html::HTMLDocument)
    as = eachmatch(Selector("a"), html.root)
    for a in as
        href = get(a.attributes, "href", "")
        for match in eachmatch(r"[\?,&,;](\w+)=", href)
            push!(parameter, match.captures...)
        end
    end
end

function script_tag(html::HTMLDocument)
    scripts = eachmatch(Selector("script"), html.root)
    for script in scripts
        variables = eachmatch(r"(let|var|const)\s(\w+)\s?=", string(script))
        objects = eachmatch(r"(let|var|const)?\s?[\",\']?(\w+)[\",\']?\s?:", string(script))
        foreach(variable -> push!(parameter, variable.captures[2]), variables)
        foreach(object -> push!(parameter, object.captures[2]), objects)
    end
end

function files(source::String, extensions::Vector{String})
    ext = join(extensions, '|')
    regex = Regex("\\/?([\\w,\\.,\\-]+\\.($ext))")
    files = eachmatch(regex, source)
    foreach(file -> push!(file_names, file.captures[1]), files)
end

function _urls(source::String)
    urls = eachmatch(r"https?://[^\s]+/", source)
    foreach(url -> push!(Urls, url.match), urls)
end

function js(source::String)
    variables = eachmatch(r"(let|var|const)\s(\w+)\s?=", source)
    objects = eachmatch(r"(let|var|const)?\s?[\",\']?(\w+)[\",\']?\s?:", source)
    params = eachmatch(r"[\?,&,;](\w+)=", source)
    foreach(var -> push!(parameter, var.captures[2]), variables)
    foreach(obj -> push!(parameter, obj.captures[2]), objects)
    foreach(param -> push!(parameter, param.captures[1]), params)
end

function php(source::String)
    variables = eachmatch(r"\$(\w+)\s?=", source)
    GET_POST = eachmatch(r"\$_(GET|POST)\[[\",\'](.*)[\",\']\]", source)
    foreach(var -> push!(parameter, var.captures[1]), variables)
    foreach(g_p -> push!(parameter, g_p.captures[2]), GET_POST)
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

