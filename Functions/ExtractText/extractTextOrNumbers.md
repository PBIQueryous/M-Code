Extract numeric characters from a text string

example code
```js
Table.TransformColumnTypes(Table.AddColumn(Source, "TimeStamp", each Text.Select( [Name], {"0".."9"})), {{"TimeStamp", Int64.Type}})
```

## Extract Numbers: template
```c#
Table.TransformColumnTypes(
    Table.AddColumn(
      Source,
      "NewColumn", 
      each Text.Select( [SourceColumn], {"0".."9"})),
{{"SourceColumn", Int64.Type}})
```

## Extract Numbers: template
```c#
Table.TransformColumnTypes(
    Table.AddColumn(
      Source,
      "NewColumn", 
      each Text.Select( [SourceColumn], {"a".."z"})),
{{"SourceColumn", type text}})
```
