``` ioke
//Function to change column name from 'thiIsColumnName' format to 'This Is Column Name' format
= (_ColumnName as text) =>
let
    #"Added Custom" = Text.ToList (_ColumnName),
    #"Converted to Table" = Table.FromList(#"Added Custom", Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Renamed Columns" = Table.RenameColumns(#"Converted to Table",{{"Column1", "ListOfCharacters"}}),
    #"Added Custom1" = Table.AddColumn(#"Renamed Columns", "Numbers", each Character.ToNumber([ListOfCharacters])),
    #"Added Custom2" = Table.AddColumn(#"Added Custom1", "NewCharacter", each (if [Numbers] > 64 and [Numbers] < 91 then "/" else "") & Character.FromNumber([Numbers])),
    #"Removed Columns" = Table.RemoveColumns(#"Added Custom2",{"ListOfCharacters", "Numbers"}),
    #"Added Custom3" = Table.AddColumn(#"Removed Columns", "One", each 1),
    #"Grouped Rows" = Table.Group(#"Added Custom3", {"One"}, {{"NewName", each Text.Combine([NewCharacter]), type text}}),
    #"Replaced Value" = Table.ReplaceValue(#"Grouped Rows","/"," ",Replacer.ReplaceText,{"NewName"}),
    #"Capitalized Each Word" = Table.TransformColumns(#"Replaced Value",{{"NewName", Text.Proper, type text}}),
    NewName = Table.RemoveColumns(#"Capitalized Each Word",{"One"})[NewName]{0}
in
    NewName
```
