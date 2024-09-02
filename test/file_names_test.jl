include("../src/func.jl")
using Test


println("\n")

html1 = ReadFile("zfile_html1.html")

@testset "file_names 1" verbose = true begin
    extract_file_name(html1, ["js", "php", "py", "json", "html"])

    @test EXTRACTED_FILE_NAMES == ["admin.js", "login.php", "users.py", "auth-log.js", "pages72.html"]
end


