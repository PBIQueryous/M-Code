# Unpivot Groups of Columns

```js
let
  Source = Adviser, 
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
    addListZip, 
    {
      "Primary Sector Job/Profession", 
      "Primary Career Aspiration", 
      "Second Sector Job/Profession", 
      "Career Aspiration2", 
      "Third Sector Job/Profession", 
      "Career Aspiration3"
    }
  ), 
  expandLists = Table.ExpandListColumn(removeGroupColumns, "Custom"), 
  expandValues = Table.TransformColumns(
    expandLists, 
    {"Custom", each Text.Combine(List.Transform(_, Text.From), ";"), type text}
  ), 
    // Split lists by delimiter
    splitColumns = Table.SplitColumn(
    expandValues, 
    "Custom", 
    Splitter.SplitTextByDelimiter(";", QuoteStyle.Csv), 
    {
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
