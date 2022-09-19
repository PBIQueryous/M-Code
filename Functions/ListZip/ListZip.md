# List.Zip
## unpivot groups of columns

```C#
  
  // list columns to zip; this list will be used in a later step to remove these columns
  listZipColumns = {
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

      // Group 1 - Attributes (list of lists) // list1 (list of attributes)                  
      {
        {
          "Primary", 
          "Second", 
          "Third"
        }, 
        
        // Group 2 - Values 1           // list2 (list columns in order)                 
        {
          [#"Primary Sector Job/Profession"],
          [#"Second Sector Job/Profession"],
          [#"Third Sector Job/Profession"]
        },
        
        // Group 3 - Values 2           // list3 (list columns in order)          
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
  // use previous var listZipColumns as list argument to remove those columns as no longer needed
  removeGroupColumns = Table.RemoveColumns(                                                                                                
    addListZip,
    listZipColumns
  )
```
