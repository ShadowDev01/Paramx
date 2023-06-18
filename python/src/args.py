import argparse

def ARGUMENTS():
    settings = argparse.ArgumentParser(
        prog="Paramx",
        description="""
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n
        help to find [parameter names], [js variables names], [js object keys], [input tag's name & id values], [a tag's href inner parameters], [files names], [urls] \n\n***please install HTTP, Gumbo, Cascadia packages before run the program***
        \n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        """
    )
    Source = settings.add_argument_group("INPUT")
    Work = settings.add_argument_group("Work")
    Save = settings.add_argument_group("Save")
    Source.add_argument("-u", "--url", help="single target url to crawl")
    Source.add_argument("-U", "--urls", help="multiple targets urls in file to crawl")
    Source.add_argument("-S", "--source", help="saved html source code")
    Source.add_argument("-R", "--request", help="sent http request in file")
    Source.add_argument("-P", "--response", help="received http response in file")
    Source.add_argument("--js", help="find parameters in js file")
    Source.add_argument("--php", help="find parameters in php file")
    Source.add_argument("--xml", help="find parameters in xml file")
    Work.add_argument("-a", help="find parmeters inside of <a> tag's href", action="store_true")
    Work.add_argument("-i", help="find <input> & <textarea> name, id parameters", action="store_true")
    Work.add_argument("-s", "--script", help="find <script> tag variables names & objects keys", action="store_true")
    Work.add_argument("-p", help="find parameters in request or response or js or php content", action="store_true")
    Work.add_argument("-f", "--file-names", help="find file names", action="store_true")
    Work.add_argument("-e", "--extension", help="extension(s) of files to search, must be in space separated; default is js", nargs='+', default=["js"])
    Work.add_argument("-w", help="find urls", action="store_true")
    Work.add_argument("-A", help="do all -a -i -s -f -u -w", action="store_true")
    Save.add_argument("-o", "--output", help="save output in file", type=str)

    args = settings.parse_args()
    
    if args.A:
        args.a=True
        args.i=True
        args.w=True
        args.p=True
        args.script=True
        args.file_names=True

    return args