FROM julia:1.10.4
RUN julia -e 'using Pkg; Pkg.add(["JSON", "ArgParse", "OrderedCollections", "Cascadia", "Gumbo", "HTTP"])'
RUN mkdir /Paramx
WORKDIR /Paramx/
COPY . /Paramx/
ENTRYPOINT [ "julia", "/Paramx/Paramx.jl" ]
CMD [ "-h" ]