let
    fxDecimalTimeInMinToDuration = 
        ( DecimalTimeInMin ) as duration => 
            let
                t = Splitter.SplitTextByAnyDelimiter({",", "."})(Text.From( DecimalTimeInMin )),
                x = Number.From( t{0}? ?? "0" ),
                d = if x >1440 then x /1440 else 0, 
                h = if x >1440 then (Number.Mod( d, 1) *1440) /60 else if x >60 then x /60 else 0, 
                m = if x >60 then Number.Round(Number.Mod(h, 1) *60 ) else x,
                r = #duration( Number.RoundDown(d, 0), Number.RoundDown(h, 0), m, Number.From( Text.PadEnd( t{1}? ?? "0", 2, "0")) )
            in
        r,
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WMlWK1YlWMtQxhtB6ENpIxwQiYaQHZRhASB1DcwhDD8ow1DExhGqFMsxhWo0hegxNYAKWFiY6RkALYgE=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [InMinutes = _t]),
    InvokeCustom = Table.AddColumn(Source, "fxDecimalTimeInMinToDuration", each fxDecimalTimeInMinToDuration([InMinutes]), type duration)
in
    InvokeCustom
