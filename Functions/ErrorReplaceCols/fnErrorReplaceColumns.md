``` ioke

//Build a list of all table columns for Table.ReplaceErrorValues()
//Output: {{"Column1",null}, {"Column2",null}}
let 
    GetListOfAllErrReplacements = (_table as table) =>
let
    _AllColumns = Table.ColumnNames(_table),
    #"Converted to Table" = Table.FromList(_AllColumns, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Added Custom1" = Table.AddColumn(#"Converted to Table", "Custom1", each null),
    #"Added Custom2" = Table.AddColumn(#"Added Custom1", "Custom2", each {[Column1],[Custom1]}),
    #"Removed Columns" = Table.RemoveColumns(#"Added Custom2",{"Column1", "Custom1"}),
    _ListOfAllReplacements = #"Removed Columns"[Custom2]
in 
    _ListOfAllReplacements
in
    GetListOfAllErrReplacements

```
