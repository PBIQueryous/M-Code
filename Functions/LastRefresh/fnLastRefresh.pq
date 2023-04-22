let
    invokeFn = () => let
    inputData = DateTimeZone.FixedUtcNow(),
    extractTable = #table(1, {{inputData}}),
    formatData = Table.TransformColumnTypes(extractTable,{{"Column1", type datetime}}),
        extractDate = Table.AddColumn(formatData, "Date", each DateTime.Date([Column1]), type date),
        extractTime = Table.AddColumn(extractDate, "Time", each DateTime.Time([Column1]), type time),
        renameHeader = Table.RenameColumns(extractTime,{{"Column1", "Date/Time"}})
in
    renameHeader
in
    invokeFn
