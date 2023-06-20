import re
from bs4 import BeautifulSoup
import logging

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')


parameter = set()
Urls = set()
file_names = set()

def a_tag(html):
    AS = html.find_all('a', href=True)
    for a in AS:
        params = re.findall(r"[\?,\&,\;]([\w\-]+)[\=,\&,\;]?", a['href'])
        parameter.update(params)

def input_tag(html):
    inputs = html.find_all('input', attrs={"id": True}) + html.find_all('input', attrs={"name": True})
    textareas = html.find_all('textarea', attrs={"id": True}) + html.find_all('textarea', attrs={"name": True})
    for input in inputs + textareas:
        parameter.add(input.get('id', ''))
        parameter.add(input.get('name', ''))

def script_tag(html):
    scripts = html.find_all('script')
    for script in scripts:
        variables = re.findall(r"(let|var|const)\s(\w+)\s?=", script.text)
        objects = re.findall(r"(let|var|const)?\s?[\",\']?([\w\.]+)[\",\']?\s?:", script.text)
        params = re.findall(r"[\?,&,;](\w+)=", str(script))
        for item in variables + objects:
            parameter.add(item[1])
        for param in params:
            parameter.add(param)

def files(source, extensions):
    ext = "|".join(extensions)
    regex = f"\/?([\w,\.,\-]+\.({ext}))"
    file = re.findall(regex, source)
    for name in file:
        file_names.add(name[0])

def _urls(source):
    regex = r"""(?:"|'|\\n|\\r|\n|\r)(((?:[a-zA-Z]{1,10}:\/\/|\/\/)[^"'\/]{1,}\.[a-zA-Z]{2,}[^"']{0,})|((?:\/|\.\.\/|\.\/)[^"'><,;| *()(%%$^\/\\\[\]][^"'><,;|()]{1,})|([a-zA-Z0-9_\-\/]{1,}\/[a-zA-Z0-9_\-\/]{1,}\.(?:[a-zA-Z]{1,4}|action)(?:[\?|\/][^"|']{0,}|))|([a-zA-Z0-9_\-]{1,}\.(?:php|asp|aspx|cfm|pl|jsp|json|js|action|html|htm|bak|do|txt|xml|xls|xlsx)(?:\?[^"|^']{0,}|)))(?:"|'|\\n|\\r|\n|\r)"""
    urls = re.findall(regex, source)
    Urls.update(*urls)

def php(source):
    variables = re.findall(r"\$(\w+)\s?=", source)
    GET_POST = re.findall(r"\$_(GET|POST)\[[\",\'](.*)[\",\']\]", source)
    parameter.update(variables)
    for item in GET_POST:
        parameter.add(item[1])

def xml(source):
    elements = re.findall(r"<(\w+)[\s\>]", source)
    parameter.update(elements)

def headers(H):
    params = re.findall(r"[\?,&,;](\w+)=", H)
    parameter.update(params)

def CALL(source="", html="", header="", a=False, i=False, s=False, p=False, w=False, x=False, P=False, f=False, e=["js"]):
    if a:
        a_tag(html=html)
    if i:
        input_tag(html=html)
    if s:
        script_tag(html)
    if p:
        script_tag(html=html)
        headers(header=header)
    if w:
        _urls(source=source)
    if f:
        files(source=source, extensions=e)
    if x:
        xml(source=source)
    if P:
        php(source=source)

def Open(file):
    try:
        with open(file, "r", encoding="utf-8") as File:
            return File.read()
    except:
        logging.info(f"there is no file: {file}")
        exit(0)

def Write(file_name, mode, data):
    with open(file_name, mode=mode) as File:
        File.write(data)

def OUT(o):
    data =  "\n".join(parameter | Urls | file_names)
    if o:
        Write(o, "w+", data)
    else:
        print(data)