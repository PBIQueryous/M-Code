```ioke

let
    Source = let
    ChangeTypefx = (Table as table, DataTypes as list) as table => 
    let
        SourceCols = Table.ColumnNames(Table),
        DataTypesColumnList = List.Transform(DataTypes, each _{0}),
        MatchingCols = List.Intersect({SourceCols, DataTypesColumnList}),
        MatchingTypesRestoredasList = 
            List.Transform(
                List.Transform(
                    MatchingCols, 
                    each List.PositionOf(DataTypesColumnList, _)
                ), 
            each DataTypes{_}
        ),
        Custom2 = Table.TransformColumnTypes(Table, MatchingTypesRestoredasList)
    in
        Custom2,
        Docs = [
                Documentation.Name = "ChangeTypeFxNoErrors",
                Documentation.Description = "Returns no error if the data types applied are not found.",
                Documentation.Author = "Chandeep Chhabra @ goodly.co.in",
                Documentation.Examples = 
                    {
                        [
                            Description = "There are 2 arguments to this function. Table, DataTypes as List of List", 
                            Code = 
    "ChangeTypeNoErrors (
        Source,                     -- Table Name 
        { {Date, type date}, 
        {Region, type text}, 
        {Units, Int64.Type} }       -- Data types applied to columns
    )
    ",
                            Result = "Table with no errors"
                        ]
                    }
            ]
    in
    Value.ReplaceType(ChangeTypefx, Value.ReplaceMetadata(Value.Type(ChangeTypefx), Docs))
in
    Source

```
