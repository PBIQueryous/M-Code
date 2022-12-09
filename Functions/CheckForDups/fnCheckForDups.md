``` ioke
//Chech if there are duplicate rows in the table. Return Error if any
    _CountRows1 = Table.RowCount(<#"Previous Step">),
    #"Removed Duplicates" = Table.Distinct(#"Previous Step", {<"Column Name">}),
    _CountRows2 = Table.RowCount(#"Removed Duplicates"),
    _Error = 
    error [ 
        Reason = "DuplicateRecords", 
        Message = "Duplicate records", 
        Detail = "Duplicate records found in <[Column Name]> column" 
    ],
    Result = if _CountRows2 = _CountRows1 then #"Removed Duplicates" else _Error
    

```
