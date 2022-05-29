# Replace Text
### several templates for replacing text, conditional and multiple

```c#
= Table.TransformColumns(#”Changed Type”, {“FieldBeingChanged”, each if _ null then “New Value” else “Old Value”})
```
## Single Step
```c#
= Table.ReplaceValue(
     #"Removed Other Columns", 
     each [Income] > 50000, 
     each 2, 
     (x,y,z)=> if y then z else x,
     {"Kidhome", "Teenhome"} 
)
```

```c#
  = List.Accumulate(
      Table.ToRecords(ReplacementTable), 
      [Consumer_ID], 
      (valueToReplace, replaceOldNewRecord) =>
        Text.Replace(valueToReplace, replaceOldNewRecord[Old], replaceOldNewRecord[New])
    )
```

## Bulk Replace
```c#
= Table.ReplaceValue(
     #"Changed Type", 
     each [Consumer_ID],  
     each List.Accumulate(
        List.Buffer( Table.ToRecords( ReplacementTable ) ), 
          [Consumer_ID], 
           ( valueToReplace, replaceOldNewRecord ) => 
               Text.Replace( valueToReplace,                
                             replaceOldNewRecord[Old],           
                             replaceOldNewRecord[New] ) ),
     Replacer.ReplaceText,
     {"Consumer_ID"}
 )
```


```c#
= Text.Combine(
       List.ReplaceMatchingItems( 
          { [Consumer_ID] }, 
          List.Buffer( 
             List.Zip( { ReplacementTable[Old], 
                         ReplacementTable[New] } ),
          Comparer.OrdinalIgnoreCase
          )
   )
```

## contains word

```c#
= Table.ReplaceValue(
     #"Changed Type",
     each [Consumer_ID], 
     each if Text.Contains([Consumer_ID] ), "rick", 
           Comparer.OrdinalIgnoreCase ) then "Rick" else 
           [Consumer_ID],
     Replacer.ReplaceValue,
     {"Consumer_ID"}
 )
```

```c#
= Text.Combine(
       List.ReplaceMatchingItems( 
          { [Consumer_ID] }, 
          { { "Rick", "RICk" } },
          Comparer.OrdinalIgnoreCase
          )
   )
```

```c#
Text.Combine(
  List.ReplaceMatchingItems(
    {[Consumer_ID]}, 
    {
      {"Rick", "RICk"}, 
      {"GorillaBI", "GORILLABi"}, 
      {"RickdeGroot", "RICKDEGROOt"}
    }, 
    Comparer.OrdinalIgnoreCase
  )
)
```
