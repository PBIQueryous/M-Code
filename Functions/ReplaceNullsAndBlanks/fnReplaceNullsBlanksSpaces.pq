(t as table) as table =>
let
    RemoveEmptyCols = Table.RemoveColumns( t, 
        Table.SelectRows(
            Table.Profile( t, 
                {
                    {"NonEmpty", each true, each List.NonNullCount( List.Select( List.Transform( _, each try Text.Trim(Text.Clean(_)) otherwise _), each _ <> ""))}
                }
            )[[Column], [NonEmpty]], each [NonEmpty] = 0
        )[Column]
    ), 
    RemoveEmptyRows = Table.SelectRows( RemoveEmptyCols, 
        each List.NonNullCount( List.Select( List.Transform( Record.FieldValues(_), each try Text.Trim(Text.Clean(_)) otherwise _),  each _ <> "")) >0
    )
in
    RemoveEmptyRows
