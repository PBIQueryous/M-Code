# Unpivot Groups of Columns

```js
let
  Source = Adviser, 
  // select columns and generate list of code
  selectColumns = Table.SelectColumns(
    Source, 
    {
      "School Code", 
      "FileName", 
      "ID", 
      "Cycle?", 
      "Student", 
      "Primary Sector Job/Profession", 
      "Primary Career Aspiration", 
      "Second Sector Job/Profession", 
      "Career Aspiration2", 
      "Third Sector Job/Profession", 
      "Career Aspiration3"
    }
  ),
  // use previous list of columns to select columns for List.Zip function
  listZipColumns = 
  {
      "Primary Sector Job/Profession", 
      "Primary Career Aspiration", 
      "Second Sector Job/Profession", 
      "Career Aspiration2", 
      "Third Sector Job/Profession", 
      "Career Aspiration3"
  }, 
  addListZip = Table.AddColumn(
    selectColumns, 
    "Custom", 
    each List.Zip(
      // Group 1 - Attributes
      {
        {"Primary", 
        "Second", 
        "Third"
      }, 
        // Group 2 - Values 1
        {
          [#"Primary Sector Job/Profession"], 
          [#"Second Sector Job/Profession"], 
          [#"Third Sector Job/Profession"]
        }, 
            // Group 3 - Values 2
            {
              [Primary Career Aspiration],
              [Career Aspiration2], 
              [Career Aspiration3]
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
