# Unpivot Groups of Columns

```js
let
  Source = DataTable, 
  // select columns and generate list of code
  selectColumns = Table.SelectColumns(
    Source, 
    {
      "School", 
      "FileName", 
      "ID", 
      "Term", 
      "Student",
      "Primary Sector Job", 
      "Primary Career Aspiration", 
      "Secondary Sector Job", 
      "Secondary Career Aspiration", 
      "Terciary Sector Job", 
      "Terciary Career Aspiration"
    }
  ),
  // use previous list of columns to select columns for List.Zip function
  listZipColumns = 
  {
      "Primary Sector Job", 
      "Primary Career Aspiration", 
      "Secondary Sector Job", 
      "Secondary Career Aspiration", 
      "Terciary Sector Job", 
      "Terciary Career Aspiration"
  }, 
  addListZip = Table.AddColumn(
    selectColumns, 
    "Custom", 
    each List.Zip(
      // Group 1 - Attributes
      {
        {"Primary", 
        "Secondary", 
        "Terciary"
      }, 
        // Group 2 - Values 1
        {
          [Primary Career Job], 
          [Secondary Career Job], 
          [Terciary Career Job]
        }, 
            // Group 3 - Values 2
            {
              [Primary Career Aspiration],
              [Secondary Career Aspiration], 
              [Terciary Career Aspiration]
            }
      // add additional column groups as list (as required)
              /* , 
              * {
              *   [ColumnGroupC1]
              *   [ColumnGroupC2]
              *   [ColumnGroupC3]
              * }
              */
      }
    )
  ), 
  removeGroupColumns = Table.RemoveColumns(
    // use previous var listZipColumns as list argument to remove those columns as no longer needed
    addListZip, listZipColumns
  ), 
  expandLists = Table.ExpandListColumn(removeGroupColumns, "Custom"), 
  expandValues = Table.TransformColumns(
    expandLists, 
    {"Custom", each Text.Combine(List.Transform(_, Text.From), ";"), type text}
  ), 
    // Split lists by delimiter - remember to rename columns within code here
    splitColumns = Table.SplitColumn(
    expandValues, 
    "Custom", 
    Splitter.SplitTextByDelimiter(";", QuoteStyle.Csv), 
    {  // rename columns
        "Primary/Secondary/Terciary", 
        "Sector", 
        "Aspiration"
    }
  ), 
  formatColumns = Table.TransformColumnTypes(
    splitColumns, 
    {
        {"Primary/Secondary/Terciary", type text}, 
        {"Sector", type text}, 
        {"Aspiration", type text}
    }
  )
in
  formatColumns

```
