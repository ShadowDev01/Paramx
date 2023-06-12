using Pkg

reg::IO = open("./src/reg", "r+")
n::String = read(reg, String)
if n == "0"
    @info "Installing the packages..."
    Pkg.add("HTTP")
    Pkg.add("Gumbo")
    Pkg.add("Cascadia")
    write(reg, "1")
    close(reg)
end
