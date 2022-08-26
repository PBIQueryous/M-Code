```C#
// Filter by Max number
Table.SelectRows(EXPANDinvokedColumn, let latest = List.Max(EXPANDinvokedColumn[FileDate]) in each [FileDate] = latest)
```
