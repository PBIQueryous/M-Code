# fnFilterMaxDate
## filter table by max date available (for latest records)

```C#
let
input = Source
fnFilterMax = Table.SelectRows(input, each ([Field] = List.Max(input[Field]))) )
in
fnFilterMax
```
