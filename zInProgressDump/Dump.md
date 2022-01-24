```cs

// Dynamic Rename Headers
= Table.RenameColumns(PromotedHeaders, Headers, MissingField.Ignore)
// where headers are a flat (transposed lists) table
Table.ToColumns(Source) //-- source is 2 rows of headers, OLD{0}; NEW{1}

// Filter by Max number
Table.SelectRows(EXPANDinvokedColumn, let latest = List.Max(EXPANDinvokedColumn[FileDate]) in each [FileDate] = latest)

// Get date integer from date
AddDateInt = Table.AddColumn(
    AddMonthEnd,
    "DateInt",
    each [Year] * 10000 + [MonthOfYear] * 100 + [DayOfMonth],
    type number
  )

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

// Get Headers
GetHEADERS = Table.ColumnNames(Table.Combine(QUERYSTART[fnCustom]))
// List Headers
HEADERSTOUNPIVOT = {"Name", "SortID", "ProjID", "ProjName", "Fiscal Period", "Item", "EXPENDITURE", "PaymentType"}
// Expand Headers
ExpandCustomFunction = Table.ExpandTableColumn(QUERYSTART, "fnCustom", GetHEADERS)

// Function to Trim Leadings Spaces and/or Characters
let
  Source = let
      func = // fnPowerRemoveSpaces
      
        let
          Source = (Text as text, optional SpecialCharacter as text) =>
            let
              char         = if SpecialCharacter = null then " " else SpecialCharacter, 
              split        = Text.Split(Text, char), 
              removeblanks = List.Select(split, each _ <> ""),
              removespaces       = Replacer.ReplaceText(Text.Combine(removeblanks, char), " ", "")
              
            in
              removespaces
        in
          Source, 
      documentation = [
        Documentation.Name = " Function.PowerRemoveSpaces ", 
        Documentation.Description = " Trims Excess Spaces. ", 
        Documentation.LongDescription
          = " Add Column, Invoke Custom Function, Choose Column to RemoveSpaces. ", 
        Documentation.Category = " Trim Function ", 
        Documentation.Source = "  TVCA PowerBI Team  ", 
        Documentation.Version = " 02 / 09 / 2022 ", 
        Documentation.Author = " Imran Haq ", 
        Documentation.Examples = {[Description = "  Neat function to remove excess spaces   ", Code = " Removes   All   Spaces   ", Result = " RemovesAllSpaces "]}
      ]
    in
      Value.ReplaceType(func, Value.ReplaceMetadata(Value.Type(func), documentation))
in
  Source
  
  Rename2022Allocation = Table.RenameColumns(FilterRows3,{{"2022/23;Variance", "2022/23ProjectAllocation"}})
 

// Remove null columns
(Source as table) as table =>

let
    RemoveEmptyColumns = Table.SelectColumns(
        Source,
        List.Select(
            Table.ColumnNames(Source),
            each List.NonNullCount(Table.Column(Source,_)) <> 0
        )
    )
in
    RemoveEmptyColumns 
	
// Remove null columns Custom Step
= Table.SelectColumns(Source, 
List.Select(Table.ColumnNames(Source), 
each List.NonNullCount(Table.Column(Source,_)) <> 0))
```
