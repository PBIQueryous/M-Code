# Remove all Null Columns
### Scans previous step (as table) and dynamically removes all completely null columns

```c#
= Table.SelectColumns(Source, 
  List.Select(Table.ColumnNames(Source), 
  each List.NonNullCount(Table.Column(Source,_)) <> 0))
```
