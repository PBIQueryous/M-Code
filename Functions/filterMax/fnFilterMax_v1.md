```C#
Table.SelectRows(
  inputTable, 
  let
    latest = List.Max(inputTable[Value]), 
    filter = each [Value] = latest
  in
    filter
)
```
