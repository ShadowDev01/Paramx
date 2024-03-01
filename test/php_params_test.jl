include("../src/func.jl")
using Test

println("\n")

php1 = ReadFile("zfile_php1.php")

@testset "php_params" verbose = true begin
    ExtractPHPVariables(php1)

    @test EXTRACTED_PHP_VARIABLES |> unique == ["name", "email", "password"]
    @test EXTRACTED_PHP_GET_POST == ["name", "user_id", "info"]
end