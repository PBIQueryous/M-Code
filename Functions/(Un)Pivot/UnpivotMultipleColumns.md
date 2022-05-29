# Unpivot Groups of Columns

```js
= Table.AddColumn(#"Removed Other Columns", "Custom", each List.Zip( {
    {
        // list attribute names
        "Primary",
        "Second",
        "Third"
    },
    {
        // list 1st column group
        [#"Primary Sector Job/Profession"],
        [#"Second Sector Job/Profession"],
        [#"Third Sector Job/Profession"]
    },
    {
        // list 2nd corresponding column group
        [Primary Career Aspiration],
        [Career Aspiration2],
        [Career Aspiration3]
    }
        // add additional column groups as list (as required)
     /* , 
      *   {
      *   [ColumnGroupC1]
      *   [ColumnGroupC2]
      *   [ColumnGroupC3]
      *   }
      */
}
))

```
