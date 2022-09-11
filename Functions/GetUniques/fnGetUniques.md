# fnGetUniques
## get unique values

```C#
let
  // Author: Imran Haq - PBI QUERYOUS
  // --- Function segment ---
  output = (input as list) as table =>
    let
        step1 = Table.TransformColumnTypes(Table.Sort(Table.Distinct(Table.FromList(input)), {{"Column1", Order.Ascending}}), {{"Column1", type text}})
    in
        step1,
  // Output from inner steps
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
    Documentation.Examples = {[Description = " Stay Queryous ", Code = " Stay Queryous ", Result = " Stay Queryous "]}
  ],
  functionDocs = Value.ReplaceType(                                   // Replace type of the value           
        output,                                                       // Function caller
        Value.ReplaceMetadata(                                        // Replace metadata of the function
            Value.Type(output),                                       // Return output type of function               
            documentation                                             // Documentation assigment
        )
    )
in
  functionDocs
```
