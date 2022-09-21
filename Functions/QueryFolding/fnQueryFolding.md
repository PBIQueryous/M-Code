## _QFIndicator

```C#
// Save as __QFIndicator                
(tableName as table) =>
  let
    fn =
      if (Value.Metadata(tableName)[QueryFolding][IsFolded] = true) then
        "Query Folded Successfully"
      else
        error Error.Record(
          "Query Folding Warning",
          "Query not folding",
          "Either the query does not use native query (i.e SQL) or the transformations are not foldable. If you are using SQL, check the query logs"
        )
  in
    fn
```


## _QFAudit

```C#
// Save as __QFAudit
(optional RunFn as text) =>
  let
    Source = #sections[Section1], 
    convertToTable = Record.ToTable(Source), 
    removeErrors = Table.RemoveRowsWithErrors(convertToTable), 
    addErrorCol = Table.AddColumn(
            removeErrors, 
            "IsTable", 
            each [Value] is table, 
            type logical
    ), 
    filterRows = Table.SelectRows(addErrorCol, each ([IsTable] = true)), 
    QFCheck = Table.AddColumn(
            filterRows, 
            "QF Check", 
             each try __QFIndicator([Value]) otherwise Character.FromNumber(10060) & " Check the query", 
            type text
    ), 
    Result = Table.Sort(QFCheck, QFCheck)
  in
    Result
```
