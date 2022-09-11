# fnSelectText
## Get text characters from string

```C#
let
  Source = let
      func =  // fnPowerDigits                                       

        let
          Source = (Source as text) =>
            let
              ExtractText = Text.Select(Source, {"a" .. "z"})
            in
              ExtractText
        in
          Source,
      documentation = [
        Documentation.Name = " Function.PowerText ",
        Documentation.Description = " Extracts text from string ",
        Documentation.LongDescription
          = " Add Column, Invoke Custom Function, Choose Column to Extract text. ",
        Documentation.Category = " Trim Function ",
        Documentation.Source = "  TVCA PowerBI Team  ",
        Documentation.Version = " 02 / 09 / 2022 ",
        Documentation.Author = " Imran Haq ",
        Documentation.Examples = {
          [
            Description = "  Text.Select(Source, {''a''..''z''})   ",
            Code        = " AB12C3DEF4GH5   ",
            Result      = " ABCDEFGH "
          ]
        }
      ]
    in
      Value.ReplaceType(func, Value.ReplaceMetadata(Value.Type(func), documentation))
in
  Source
```
