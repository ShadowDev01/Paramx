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

    if Bool(args["url"])
        message.http_source = """
        🔗 url     => \033[94m$(args["url"])\033[0m
        📌 method  => \033[93m$(args["method"])\033[0m
        📝 headers => \033[93m$(args["Header"])\033[0m
        💾 type    => \033[93m$(args["ft"])\033[0m
        """
    elseif Bool(args["urls"])
        message.http_source = """
        🔗 urls    => $(args["urls"])
        📌 method  => $(args["method"])
        📝 headers => $(args["Header"])
        💾 type    => $(args["ft"])
        """
    elseif Bool(args["source"])
        message.file_source = """
        📄 file    => $(args["source"])
        💾 type    => "html"
        """
    elseif Bool(args["request"])
        message.file_source = """
        📄 file    => $(args["request"])
        💾 type    => "Any"
        """
    elseif Bool(args["response"])
        message.file_source = """
        📄 file    => $(args["source"])
        💾 type    => "Any"
        """
    elseif Bool(args["php"])
        message.file_source = """
        📄 file    => $(args["php"])
        💾 type    => "php"
        """
    elseif Bool(args["xml"])
        message.file_source = """
        📄 file    => $(args["xml"])
        💾 type    => "xml"
        """
    elseif Bool(args["js"])
        message.file_source = """
        📄 file    => $(args["js"])
        💾 type    => "js"
        """
    end


    if args["a"]
        message.option_message *= """
        ✅ find <a> tags href parameters
        """
    end
    if args["s"]
        message.option_message *= """
        ✅ find javascript parameters
        """
    end
    if args["p"]
        message.option_message *= """
        ✅ find parameters
        """
    end
    if args["i"]
        message.option_message *= """
        ✅ find Input/Textarea [name - id]
        """
    end
    if args["w"]
        message.option_message *= """
        ✅ find url/path
        """
    end
    if args["f"]
        message.option_message *= """
        ✅ find file names
        ✅ exts $(args["e"])
        """
    end
    if args["cn"]
        message.option_message *= """
        ✅ sort & count items descently
        """
    elseif args["c"]
        message.option_message *= """
        ✅ sort items descently
        """
    elseif args["T"]
        message.option_message *= """
        ✅ tag params type
        """
    end

    @info "~~~ Paramx ~~~\n\n" * message.http_source * message.file_source * "\n" * message.option_message
end