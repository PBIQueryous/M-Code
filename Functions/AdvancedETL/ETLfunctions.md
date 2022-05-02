```c#
// Function Code
= (QueryStart as table) =>

// Remove Top Rows upt Specified Rows
= Table.Skip(PrevSTEP, each[Column1] <> "TEXT")

// Remove Bottom Rows upto Specified Rows
= Table.RemoveLastN(Custom1, each[Column1] <> "TEXT")

// Remove First Rows upto Specified Rows
= Table.RemoveFirstN(Prep,each [Column1] <> "TEXT")
	
// Replace Values where the Text Starts with Specific Characters
= Table.ReplaceValue(PrevSTEP,each [Column1],each if Text.StartsWith([Column1], ";0") then "" else null,Replacer.ReplaceText,{"Column1"})
	
// Remove rows until first null
= Table.FirstN(PrevSTEP,each [Column1] <> null)

// Remove nulls until first value
= Table.RemoveFirstN(PrevSTEP,each [Column1] = null)

// Keep Rows until Desired Text Found in Column
= Table.FirstN(PrevSTEP,each [Column1] <> "TEXT")

// Table Schema
Table.Schema

// Count Splits
= Table.AddColumn(#"Removed Columns2", "Count Item", each List.Count(Text.Split([Custom],";")))
= Table.AddColumn(LISTcount, "Custom.1", each List.NonNullCount(Text.Split([Custom], ";" )))


// Get Previous Rows
= Table.AddColumn(IDnext, "IDprevPos", each 
try
// PrevStep[columnName]{0}
prevStep[columnName]{[indexColumn]-1}
otherwise null)

// Get Next Rows
= Table.AddColumn(IDpos, "IDnextPos", each 
try
prevStep[columnName]{[indexColumn]+1}
otherwise null)

// Days Laps Examples
Table.AddColumn(ADDindex1, "Stage Days Lapsed", each try
if [Stage] = "Date S/L Complete" then [Days Lapsed] else [Days Lapsed] - ADDindex1[Days Lapsed]{[Index0]-1}
otherwise null, Int64.Type)
```
