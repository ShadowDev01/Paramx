import requests
import logging
from bs4 import BeautifulSoup
from src.func import CALL, OUT, Open
from src.args import ARGUMENTS

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

def URL(url, a, i, s, w, f, e, o):
    req = requests.get(url).content
    html = BeautifulSoup(req, 'html.parser')
    CALL(source=str(req), html=html, a=a, i=i, s=s, w=w, f=f, e=e)
    OUT(o)

def URLS(file, a, i, s, w, f, e, o):
    urls = Open(file).split("\n")
    for url in urls:
        URL(url, a, i, s, w, f, e, o)

def SOURCE(file, a, i, s, w, f, e, o):
    source = Open(file)
    html = BeautifulSoup(source, 'html.parser')
    CALL(source=source, html=html, a=a, i=i, s=s, w=w, f=f, e=e)
    OUT(o)

def REQUEST(file, p, w, f, e, o):
    source = Open(file)
    try:
        header, body = source.split("\r\n\r\n")
    except:
        logging.warning("can't split header and body")
        exit(0)
    if body.lower().startswith("<!doctype html>"):
        html = BeautifulSoup(body, 'html.parser')
    else:
        html = BeautifulSoup(f"<body><script>{body}</script></body>", 'html.parser')
    CALL(source=source, html=html, header=header, p=p, w=w, f=f, e=e)
    OUT(o)

def RESPONSE(file, i, p, w, f, e, o):
    source = Open(file)
    try:
        header, body = source.split("\n\n")
    except:
        logging.warning("can't split header and body")
        exit(0)
    if body.lower().startswith("<!doctype html>"):
        html = BeautifulSoup(body, 'html.parser')
    else:
        html = BeautifulSoup(f"<body><script>{body}</script></body>", 'html.parser')
    CALL(source=source, html=html, header=header, i=i, p=p, w=w, f=f, e=e)
    OUT(o)

def JS(file, p, w, f, e, o):
    source = Open(file)
    html = BeautifulSoup(f"<body><script>{source}</script></body>", 'html.parser')
    CALL(source=source, html=html, s=p, w=w, f=f, e=e)
    OUT(o)

def PHP(file, p, w, f, e, o):
    source = Open(file)
    CALL(source=source, P=p, w=w, f=f, e=e)
    OUT(o)

def XML(file, p, w, f, e, o):
    source = Open(file)
    CALL(source=source, x=p, w=w, f=f, e=e)
    OUT(o)

def main():
    arguments = ARGUMENTS()
    a = arguments.a
    i = arguments.i
    s = arguments.script
    w = arguments.w
    p = arguments.p
    f = arguments.file_names
    e = arguments.extension
    o = arguments.output
    if arguments.url:
        URL(url=arguments.url, a=a, i=i, s=s, w=w, f=f, e=e, o=o)
    elif arguments.urls:
        URLS(file=arguments.urls, a=a, i=i, s=s, w=w, f=f, e=e, o=o)
    elif arguments.source:
        SOURCE(file=arguments.source, a=a, i=i, s=s, w=w, f=f, e=e, o=o)
    elif arguments.request:
        REQUEST(file=arguments.request, p=p, w=w, f=f, e=e, o=o)
    elif arguments.response:
        RESPONSE(file=arguments.response, i=i, p=p, w=w, f=f, e=e, o=o)
    elif arguments.js:
        JS(file=arguments.js, p=p, w=w, f=f, e=e, o=o)
    elif arguments.php:
        PHP(file=arguments.php, p=p, w=w, f=f, e=e, o=o)
    elif arguments.xml:
        XML(file=arguments.xml, p=p, w=w, f=f, e=e, o=o)

main()