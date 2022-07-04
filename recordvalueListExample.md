# Records, Values, Lists


```c#
//GetCodeFromGithub
let
  Source =  //Record.ToTable (                                                      
  
  [ NewNested =
  
  [
    Nested = 
      [
        Record1 = "Text",
        Record2 = {1 .. 10}
        ]
  ],
  SubNested2 =
  [
    Nested = 
      [
        Record1 = "Text",
        Record2 = {1 .. 10}
        ]
  ]
  ],
  #"Converted to Table1" = Record.ToTable(Source),
    #"Expanded Value1" = Table.ExpandRecordColumn(#"Converted to Table1", "Value", {"Nested"}, {"Nested"}),
    #"Expanded Nested" = Table.ExpandRecordColumn(#"Expanded Value1", "Nested", {"Record1", "Record2"}, {"Record1", "Record2"}),
    #"Expanded Record2" = Table.ExpandListColumn(#"Expanded Nested", "Record2")
in
    #"Expanded Record2"
```
