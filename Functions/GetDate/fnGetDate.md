# fnGetDate
## Get date from text string

```C#
let
  Source = let
      func
        =  // fnPowerDate                                                                                                                                                                                              
      
        let
          Source = (Source as text) =>
            let
              ExtractDate = Date.FromText(Text.Select(Source, {"0" .. "9"}))
            in
              ExtractDate
        in
          Source, 
      documentation = [
        Documentation.Name = " Function.PowerDate ", 
        Documentation.Description = " Extracts numbers and converts to date ", 
        Documentation.LongDescription = " Extracts date in number format yyyymmdd and coverts to short date format ", 
        Documentation.Category = " Function Dates Category ", 
        Documentation.Source = "  TVCA BI Team  ", 
        Documentation.Version = " Date / Number (02/09/2021 or 20210902) ", 
        Documentation.Author = " Imran Haq ", 
        Documentation.Examples = {
          [
          Description = "  Date.FromText(Text.Select(Source, {''0'' .. ''9''}))   ", 
          Code = " ABC_2021_09_02_Final ", 
          Result = " 02 / 09 / 2021 "
          ]
        }
      ]
    in
      Value.ReplaceType(func, Value.ReplaceMetadata(Value.Type(func), documentation))
in
  Source
```
