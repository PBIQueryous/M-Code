= (MyTable as table) =>
let
    UnderScoreReplaced = Table.TransformColumnNames(MyTable, each Text.Replace(_, "_", " ")  ),
    CapitalizeFirstLetters = Table.TransformColumnNames(UnderScoreReplaced, each Text.Proper(_))
in
    CapitalizeFirstLetters
