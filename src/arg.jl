using ArgParse

function ARGUMENTS()
    settings = ArgParseSettings(
        prog="Paramx",
        description="""
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n
        help to find [parameter names], [js variables names], [js object keys], [input tag's name & id values], [a tag's href inner parameters], [files names], [urls] \n\n
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

        "-H", "--Header"
        help = "custom headers to send in request"
        group = "source"
        nargs = '*'
        arg_type = String

        "-X", "--method"
        help = "http request method"
        group = "source"
        arg_type = String
        default = "GET"

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
        help = "find parameters in saved js file"
        group = "source"

        "--php"
        help = "find parameters in saved php file"
        group = "source"

        "--xml"
        help = "find parameters in saved xml file"
        group = "source"

        "-a"
        help = "find parmeters inside of <a> tag's href"
        group = "function"
        action = :store_true

        "-i"
        help = "find <input> & <textarea> name, id parameters"
        group = "function"
        action = :store_true

        "-s"
        help = "find <script> tag variables names & objects keys"
        group = "function"
        action = :store_true

        "-p"
        help = "find parameters in request or response or js or php content"
        group = "function"
        action = :store_true

        "-f"
        help = "find file names"
        group = "function"
        action = :store_true

        "-e"
        help = "extension(s) of files to search, must be in space separated; default is js"
        group = "function"
        arg_type = String
        nargs = '+'
        default = ["js"]

        "-w"
        help = "find urls"
        group = "function"
        action = :store_true

        "-A"
        help = "do all -a -i -s -f -p -w"
        group = "function"
        action = :store_true

        "--ft"
        help = "url file type: html - js - php - xml"
        group = "function"
        arg_type = String
        default = "html"

        "-c"
        help = "count and sort descending"
        group = "function"
        action = :store_true

        "--cn"
        help = "count and sort descending with number"
        group = "function"
        action = :store_true

        "-o", "--output"
        help = "save output in file"
        group = "save"
        arg_type = String
    end
    parsed_args = parse_args(ARGS, settings)
    if parsed_args["A"]
        for arg in ["a", "i", "s", "w", "f", "p"]
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