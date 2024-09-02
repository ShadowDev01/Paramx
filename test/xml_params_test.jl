include("../src/func.jl")
using Test

println("\n")

xml1 = ReadFile("zfile_xml1.xml")

@testset "xml_params" verbose = true begin
    extract_xml_elemnts(xml1)

    @test EXTRACTED_XML_ELEMENTS |> unique == ["breakfast_menu", "link", "style", "food", "name", "price", "description", "calories"]
end