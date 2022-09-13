# fnReplaceNullsAndBlanks
## Replaces blanks with nulls, then removes null Rows and Columns

```C#
let
  fn = (inputTable as table) =>
    let
      source = inputTable, 
      headers = Table.ColumnNames(source), 
      replacer = Table.ReplaceValue(source, "", null, Replacer.ReplaceValue, headers), 
      cleanser = Table.SelectColumns(
        Table.SelectRows(
          replacer, 
          each not List.IsEmpty(List.RemoveMatchingItems(Record.FieldValues(_), {"", null}))
        ), 
        List.Select(
          Table.ColumnNames(replacer), 
          each List.NonNullCount(Table.Column(replacer, _)) <> 0
        )
      )
    in
      cleanser
in
  fn
```
