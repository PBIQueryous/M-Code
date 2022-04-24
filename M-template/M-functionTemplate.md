# M-code Template without annotation

```C#
let
    // --- Function segment ---
    // Author: Imran Haq (PBI Queryous)
    output = //fnFunctionName
        (input as list) as table =>
    let
        step1 = "PowerQueryFunctionsHere"
    in
        step1
        ,                                                                
    // --- Documentation segment ---
    documentation = [
    Documentation.Name = " fnGetUniques ", 
    Documentation.Description = " Extract column of unique values ", 
    Documentation.LongDescription
      = " Select Table, Select Column and Invoke. Extracts a column of unique values ", 
    Documentation.Category = " Data Extraction ", 
    Documentation.Source = "  https://github.com/PBIQueryous - PBI Queryous - Stay Queryous  ", 
    Documentation.Version = " 1.0 (21/04/2022) ", 
    Documentation.Author = " Imran Haq (Newcastle upon Tyne) ", 
    Documentation.Examples = {[Description = "  ", Code = "  ", Result = "  "]}
  ]
    // --- Output ---
in
    Value.ReplaceType(                                                           
        output,                                                       
        Value.ReplaceMetadata(                                        
            Value.Type(output),                                                   
            documentation                                             
        )
    )
```
