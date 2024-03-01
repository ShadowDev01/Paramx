include("../src/func.jl")
using Test


html1 = ReadFile("zfile_html1.html")
js1 = """<body>\n<script>\n$(ReadFile("zfile_js1.js"))\n</script>\n</body>"""

println("\n")

@testset "script_tags" verbose = true begin
    tags = [t.match for t in eachmatch(r"<script.*?>[\s\S]*?<\/script.*>", html1)]
    @test tags == ["<script>\r\n        alert('Executing JavaScript 1');\r\n    </script>", "<script>\r\n        alert('Executing JavaScript 2');\r\n    </script>", "<script>\r\n        console.log('Third script executed');\r\n    </script>", "<script>alert(\"hi\");</script>"]
end

println("\n")

@testset "js_params" verbose = true begin
    ExtractScriptTags(js1)

    @testset "js_variables" verbose = true begin
        @test EXTRACTED_JS_VARIABLES == ["myVariable", "anotherVariable", "apiBaseUrl", "apiKey", "options", "myDictionary", "result", "fullname", "age", "multiply"]
    end

    @testset "js_object_keys" verbose = true begin
        @test EXTRACTED_JS_OBJECTS == ["Authorization", "key1", "key2", "key3", "innerKey"]
    end

    @testset "js_funcArgs" verbose = true begin
        @test EXTRACTED_JS_FUNC_ARGS == ["x", "y", "url", "query", "object", "myVariable", "anotherVariable", "x", "y", "3", "4"]
    end

    @testset "js_query_keys" verbose = true begin
        @test EXTRACTED_QUERY_KEYS == ["id", "price", "filter"]
    end
end