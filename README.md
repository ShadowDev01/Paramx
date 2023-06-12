# for help menu: julia Paramx -h

usage: Paramx [-u URL] [-U URLS] [-S SOURCE] [-R REQUEST]
              [-P RESPONSE] [--js JS] [--php PHP] [-a] [-i] [-s] [-p]
              [-f] [-e EXTENSION [EXTENSION...]] [-w] [-A] [-v]
              [-o OUTPUT] [-h]

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# help to find:

* Parameter names
* <input> tag's name & id values
* <a> tags href inner parameters
* js variables names
* js object keys
* php variables names
* php $_GET, $_POST valuse
* Files names with given extensions
* Urls

# read from:

* Url(s)
* File(s)

***Please install HTTP, Gumbo, Cascadia packages before run the Program***
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# optional arguments:
*  -h, --help            show this help message and exit

# source switches:
*  -u, --url             single target url to crawl
*  -U, --urls            multiple targets urls in file to crawl
*  -S, --source          saved html source code
*  -R, --request         sent http request in file
*  -P, --response        received http response in file
*  --js                  find parameters in js files
*  --php                 find parameters in js files

# work switches:
*  -a                    find <a> tag parameters
*  -i, --input           find <input> tag parameters
*  -s, --script          find <script> tag variables names & objects keys
*  -p                    find parameters in request or response or js or php content
*  -f, --file-names      find file names
*  -e, --extension       extension(s) of files to search, must be in space seprated
*  -w                    find urls
*  -A                    do all -a -i -s -f -u -w

# save switches:
*  -o, --output OUTPUT   save output in file