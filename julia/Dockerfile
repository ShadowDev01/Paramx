FROM julia:1.9.1
RUN julia -e 'using Pkg; Pkg.add("HTTP"); Pkg.add("Gumbo"); Pkg.add("Cascadia"); Pkg.add("ArgParse"); Pkg.add("JSON")'
RUN mkdir /Paramx
WORKDIR /Paramx/
COPY . /Paramx/
CMD [ "julia" ]