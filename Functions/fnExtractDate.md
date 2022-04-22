# Extract Date Integers and format as Data
## transform yyyymmdd to dd/mm/yyyy

```c#
let
  // Imran Haq - PBI QUERYOUS
  // transform digits yyyymmdd to Date format dd/mm/yyyy
  output = 
    let
      fn
        =  // fnExtractDate
        let
          invokeFunction = (input as text, optional separator as text) =>
            let
              extractDate = Text.Start(Text.Select(input, {"0".."9"}),2) 
              & separator & Text.Middle(Text.Select(input, {"0".."9"}), 2, 2) 
              & separator & Text.End(Text.Middle(Text.Select(input, {"0".."9"}), 4, 4), 2)
            in
              extractDate
        in
          invokeFunction, 
      documentation = [
        Documentation.Name = " fnExtractDate ", 
        Documentation.Description = " Extracts numbers and converts to date ", 
        Documentation.LongDescription
          = " Extracts date in number format yyyymmdd and coverts to short date format ", 
        Documentation.Category = " Function Dates Category ", 
        Documentation.Source = "  PBI QUERYOUS  ", 
        Documentation.Version = " 1.0 ", 
        Documentation.Author = " Imran Haq ", 
        Documentation.Examples = {
          [
            Description = "  Date.FromText(Text.Select(Source, {''0'' .. ''9''}))   ", 
            Code        = " 23032022_Final ", 
            Result      = " 02 - 09 - 2021 "
          ]
        }
      ]
    in
      Value.ReplaceType(fn, Value.ReplaceMetadata(Value.Type(fn), documentation))
in
  output
  ```
