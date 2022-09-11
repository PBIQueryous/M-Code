# fnGetDigits
## Get digits from string

```C#
let
  Source = let
      func =  // fnPowerDigits                                       

        let
          Source = (Source as text) =>
            let
              ExtractNums = Text.Select(Source, {"0" .. "9"})
            in
              ExtractNums
        in
          Source,
      documentation = [
        Documentation.Name = " Function.PowerDigits ",
        Documentation.Description = " Extracts numbers from string ",
        Documentation.LongDescription
          = " Add Column, Invoke Custom Function, Choose Column to Extract numbers. ",
        Documentation.Category = " Trim Function ",
        Documentation.Source = "  TVCA PowerBI Team  ",
        Documentation.Version = " 02 / 09 / 2022 ",
        Documentation.Author = " Imran Haq ",
        Documentation.Examples = {
          [
            Description = "  Text.Select(Source, {''0''..''9''})   ",
            Code        = " AB12C3DEF4GH5   ",
            Result      = " 12345 "
          ]
        }
      ]
    in
      Value.ReplaceType(func, Value.ReplaceMetadata(Value.Type(func), documentation))
in
  Source
```
