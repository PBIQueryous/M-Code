# fnBulkReplace
## Bulk Replace Characters

```C#
let BulkReplace = (DataTable as table, FindReplaceTable as table, DataTableColumn as list) =>
    let
        //Convert the FindReplaceTable to a list using the Table.ToRows function
        //so we can reference the list with an index number
        FindReplaceList = Table.ToRows(FindReplaceTable),
        //Count number of rows in the FindReplaceTable to determine
        //how many iterations are needed
        Counter = Table.RowCount(FindReplaceTable),
        //Define a function to iterate over our list 
        //with the Table.ReplaceValue function
        BulkReplaceValues = (DataTableTemp, n) => 
        let 
            //Replace values using nth item in FindReplaceList
            ReplaceTable = Table.ReplaceValue(
                DataTableTemp,
                //replace null with empty string in nth item
                if FindReplaceList{n}{0} = null then "" else FindReplaceList{n}{0},
                if FindReplaceList{n}{1} = null then "" else FindReplaceList{n}{1},
                Replacer.ReplaceText,
                DataTableColumn
                )
        in
            //if we are not at the end of the FindReplaceList
            //then iterate through Table.ReplaceValue again
            if n = Counter - 1 
                then ReplaceTable
                else @BulkReplaceValues(ReplaceTable, n + 1),
        //Evaluate the sub-function at the first row
        Output = BulkReplaceValues(DataTable, 0)   
    in
        Output
    // custom function step: = fnBulkReplace(PreviousStep, ReplacementTable, {"Period"} )
    // explained: = FUNCTION_NAME(PREVIOUS_STEP, TABLE_WITH_OLD_AND_NEW_VALUES, {"COLUMN_NAME_FROM_PREVIOUS_STEP"} )
in
    BulkReplace
```
