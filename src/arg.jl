using ArgParse

function ARGUMENTS()
    settings = ArgParseSettings(
        prog="Paramx",
        description="""
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n
        help to find [parameter names], [js variables names], [js object keys], [input tag's name & id values], [a tag's href inner parameters], [files names], [urls] \n\n***please install HTTP, Gumbo, Cascadia packages before run the program***
        \n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        """
    )
    add_arg_group!(settings, "source switches", "source")
    add_arg_group!(settings, "work switches", "function")
    add_arg_group!(settings, "save switches", "save")

    @add_arg_table settings begin
        "-u", "--url"
            help = "single target url to crawl"
            group = "source"

        "-U", "--urls"
            help = "multiple targets urls in file to crawl"
            group = "source"

        "-S", "--source"
            help = "saved html source code"
            group = "source"

        "-R", "--request"
            help = "sent http request in file"
            group = "source"

        "-P", "--response"
            help = "received http response in file"
            group = "source"

        "--js"
            help = "find parameters in js files"
            group = "source"

        "--php"
            help = "find parameters in js files"
            group = "source"

        "-a"
            help = "find <a> tag parameters"
            group = "function"
            action = :store_true

        "-i", "--input"
            help = "find <input> tag parameters"
            group = "function"
            action = :store_true

        "-s", "--script"
            help = "find <script> tag variables names & objects keys"
            group = "function"
            action = :store_true

        "-p"
            help = "find parameters in request or response or js or php content"
            group = "function"
            action = :store_true

        "-f", "--file-names"
            help = "find file names"
            group = "function"
            action = :store_true

        "-e", "--extension"
            help = "extension(s) of files to search, must be in space seprated; default is js"
            group = "function"
            arg_type = String
            nargs = '+'
            default = ["js"]

        "-w"
            help = "find urls"
            group = "function"
            action = :store_true

        "-A"
            help = "do all -a -i -s -f -u -w"
            group = "function"
            action = :store_true

        "-v", "--verbose"
            help = "progress of processing"
            action = :store_true

        "-o", "--output"
            help = "save output in file"
            group = "save"
            arg_type = String
    end
    parsed_args = parse_args(ARGS, settings)
    if parsed_args["A"]
        for arg in ["a", "input", "script", "w", "file-names"]
            parsed_args[arg] = true
        end
    end
    return parsed_args
end

function check_arguments()
    arguments = ARGUMENTS()
    source_args = [arguments[arg] for arg in ["url", "urls", "source", "request", "response"]]
    if count(arg -> !isnothing(arg), source_args) > 1
        @warn "you can't use -u\\-U\\-S\\-r\\-p at same time"
        exit(0)
    end
end