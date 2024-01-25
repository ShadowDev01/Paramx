import Base.Bool

Bool(input::Vector) = !isempty(input)
Bool(input::Union{Nothing,String}) = !isnothing(input)

mutable struct Message
    http_source::String
    file_source::String
    option_message::String
end

function log_message()
    message = Message("", "", "")

    if Bool(arguments["url"])
        message.http_source = """
        🔗 url     => $(arguments["url"])
        📌 method  => $(arguments["method"])
        📝 headers => $(arguments["Header"])
        💾 type    => $(arguments["ft"])
        """
    elseif Bool(arguments["urls"])
        message.http_source = """
        🔗 urls    => $(arguments["urls"])
        📌 method  => $(arguments["method"])
        📝 headers => $(arguments["Header"])
        💾 type    => $(arguments["ft"])
        """
    elseif Bool(arguments["source"])
        message.file_source = """
        📄 file    => $(arguments["source"])
        💾 type    => "html"
        """
    elseif Bool(arguments["request"])
        message.file_source = """
        📄 file    => $(arguments["request"])
        💾 type    => "Any"
        """
    elseif Bool(arguments["response"])
        message.file_source = """
        📄 file    => $(arguments["source"])
        💾 type    => "Any"
        """
    elseif Bool(arguments["php"])
        message.file_source = """
        📄 file    => $(arguments["php"])
        💾 type    => "php"
        """
    elseif Bool(arguments["xml"])
        message.file_source = """
        📄 file    => $(arguments["xml"])
        💾 type    => "xml"
        """
    elseif Bool(arguments["js"])
        message.file_source = """
        📄 file    => $(arguments["js"])
        💾 type    => "js"
        """
    end


    if arguments["a"]
        message.option_message *= """
        ✅ find a tags id
        """
    end
    if arguments["script"]
        message.option_message *= """
        ✅ find javascript parameters
        """
    end
    if arguments["p"]
        message.option_message *= """
        ✅ find parameters
        """
    end
    if arguments["i"]
        message.option_message *= """
        ✅ find Input/Textarea id-clss
        """
    end
    if arguments["w"]
        message.option_message *= """
        ✅ find url/path
        """
    end
    if arguments["file-names"]
        message.option_message *= """
        ✅ find file names
        ✅ exts $(arguments["extension"])
        """
    end
    if arguments["cn"]
        message.option_message *= """
        ✅ sort & count items descently
        """
    elseif arguments["count"]
        message.option_message *= """
        ✅ sort items descently
        """
    end

    @info "~~~ Paramx ~~~\n\n" * message.http_source * message.file_source * "\n" * message.option_message
end