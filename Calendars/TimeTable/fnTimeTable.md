# fnTimeTable

```ioke
let
  fn = () =>
    let
      Source = List.Times(
        #time(0, 0, 0), 
        Duration.TotalSeconds(#duration(1, 0, 0, 0)), 
        #duration(0, 0, 0, 1)
      ), 
      list_ToTable = Table.TransformColumnTypes(
        Table.FromList(Source, Splitter.SplitByNothing(), {"Second"}), 
        {{"Second", type time}}
      ), 
      col_Hour = Table.AddColumn(list_ToTable, "Hour", each Time.Hour([Second]), Int64.Type), 
      col_Minute = Table.AddColumn(col_Hour, "Minute", each Time.Minute([Second]), Int64.Type), 
      col_5mins = Table.AddColumn(
        col_Minute, 
        "5 min", 
        each #time(0, Number.IntegerDivide(Time.Minute([Second]), 5) * 5, 0), 
        Time.Type
      ), 
      col_15mins = Table.AddColumn(
        col_5mins, 
        "15 min", 
        each #time(0, Number.IntegerDivide(Time.Minute([Second]), 15) * 15, 0), 
        Time.Type
      ), 
      col_30mins = Table.AddColumn(
        col_15mins, 
        "30 min", 
        each #time(0, Number.IntegerDivide(Time.Minute([Second]), 30) * 30, 0), 
        Time.Type
      ), 
      col_12hr = Table.AddColumn(
        col_30mins, 
        "12hr", 
        each 
          let
            x1 = Number.Mod([Hour], 12), 
            x2 = if x1 = 0 then 12 else x1
          in
            x2, 
        Int64.Type
      ), 
      col_AMPM = Table.AddColumn(
        col_12hr, 
        "AM/PM", 
        each if [Hour] < 12 then "AM" else "PM", 
        type text
      ), 
      col_24hrLabel = Table.AddColumn(
        col_AMPM, 
        "24hr Label", 
        each Text.PadStart(Text.From([Hour]), 2, "0"), 
        type text
      ), 
      col_12hrLabel = Table.AddColumn(
        col_24hrLabel, 
        "12hr Label", 
        each Text.Combine({Text.From([12hr], "en-GB"), [#"AM/PM"]}, " "), 
        type text
      ), 
      cols_Reorder = Table.ReorderColumns(
        col_12hrLabel, 
        {
          "24hr Label", 
          "12hr", 
          "AM/PM", 
          "12hr Label", 
          "Second", 
          "Hour", 
          "Minute", 
          "5 min", 
          "15 min", 
          "30 min"
        }
      ), 
      HrMin_Label = Table.TransformColumnTypes(
        Table.DuplicateColumn(cols_Reorder, "Second", "HourMinute"), 
        {{"HourMinute", type text}}
      )
    in
      HrMin_Label
in
  fn

```
