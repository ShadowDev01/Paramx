FROM ubuntu:latest
RUN apt update
RUN apt install wget
RUN wget "https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.1-linux-x86_64.tar.gz"
RUN tar xfz julia-1.9.1-linux-x86_64.tar.gz
RUN mv julia-1.9.1 /opt/
RUN ln -s /opt/julia-1.9.1/bin/julia /usr/local/bin/julia
RUN rm -rf julia-1.9.1-linux-x86_64.tar.gz
RUN julia -e 'using Pkg; Pkg.add("HTTP"); Pkg.add("Gumbo"); Pkg.add("Cascadia"); Pkg.add("ArgParse")'
RUN mkdir /Paramx
WORKDIR /Paramx/
COPY . /Paramx/