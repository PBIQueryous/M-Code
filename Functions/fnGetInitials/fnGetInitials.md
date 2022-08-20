# fnGetInitials
## get initials of each word (replacing " and " & " of ")

```c#
Table.AddColumn(
  PrevStep, 
  "NewColumnName", 
  each Text.Combine(
    List.Transform(
      Text.Split(Text.Replace(Text.Replace([ColumnName], " text1 ", ""), " text2 ", ""), " "), 
      each Text.Start(_, 1)
    ), 
    ""
  )
)
```
