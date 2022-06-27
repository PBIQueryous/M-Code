# Unpivot Multiple Columns
## List.Zip()

```C#
addListZip = Table.AddColumn(
        selectColumns,
        "Custom",
        each List.Zip(
            // Group 1 - Attributes
        { {
                "Attribute1",
                "Attribute2",
                "Attribute3"
            },
            // Group 2 - Values 1
            {
                [ColumnGroupA1],
                [ColumnGroupA2],
                [ColumnGroupA3]
            },
            // Group 3 - Values 2
            {
                [ColumnGroupB1],
                [ColumnGroupB2],
                [ColumnGroupB3]
            }
            // add additional column groups as list (as required)
            /* ,
             * {
             *   [ColumnGroupC1]
             *   [ColumnGroupC2]
             *   [ColumnGroupC3]
             * }
             */
        }))
```
