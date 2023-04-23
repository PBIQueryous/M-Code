let
    Source = Table,
    ToRec = Table.CombineColumnsToRecord( Source, "Value", List.Skip( Table.ColumnNames(Source), 1) ),
    ToTable = Table.TransformColumns( ToRec, {"Value", each Record.ToTable( _ )}),
    Expand = Table.ExpandTableColumn(ToTable, "Value", {"Name", "Value"}, {"Name", "Value"})
in
    Expand
