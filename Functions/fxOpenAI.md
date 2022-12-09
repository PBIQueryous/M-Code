#OpenAi

``` ioke

//Do not trust any math and factual data provided by AI. But it is amazing in understanding human language!

(prompt as text, optional model as text, optional max_tokens as number, optional temperature as number) =>

let
    _model = if model = null then "text-davinci-003" else model,
    _max_tokens = if max_tokens = null then 500 else max_tokens,
    _temperature = if temperature = null then 0.7 else temperature,
    
    //https://beta.openai.com/account/api-keys
    _api_key = "<API_KEY>",
    _url_base = "https://api.openai.com/",
    _url_rel = "v1/completions",

    ContentJSON ="{
        ""prompt"": """ & prompt & """,
        ""model"": """ & _model & """,        
        ""max_tokens"": " & Text.From(_max_tokens) & ",
        ""temperature"": " & Text.From(_temperature) &   
    "}",

    ContentBinary =  Text.ToBinary(ContentJSON),

    Source = Json.Document(
        Web.Contents(
            _url_base, 
            [
                RelativePath=_url_rel,
                Headers=[
                    #"Content-Type"="application/json", 
                    #"Authorization"="Bearer " & _api_key
                ],
                Content=ContentBinary
            ]
        )
    ),

    choices = Source[choices]{0},    
    #"Converted to Table" = Record.ToTable(choices),
    #"Filtered Rows" = Table.SelectRows(#"Converted to Table", each ([Name] = "text")),
    Result = Table.RemoveColumns(#"Filtered Rows",{"Name"})[Value]{0}
in
    Result
    
```
