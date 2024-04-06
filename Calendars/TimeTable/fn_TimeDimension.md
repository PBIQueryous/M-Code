# Time Dimension Function
## fn_TimeDimension

```ioke
let
  fn_TimeDimension =  // function to create a Time dimension (seconds / hours)                 
/* -------------------------------- 
  Author: Imran Haq - PBI QUERYOUS
  Function Name: fn_TimeDimension
  Description: function to create a Time dimension (seconds / hours)
 ---------------------------------*/

// 1.0: invoke function & define parameter inputs
    let
      invokeFunction = (optional choose_granularity as nullable text  ) =>
        
// ------------------------------------------------------------------
// 2.0: function transformations
    let

// hours function
  invokeHours = 
    let
      fn_hours = 
        let
          SecList = {0 .. 23}, 
          SecTable = 
            let
              _name = "Hour ID", 
              addCol = Table.TransformColumnTypes(
                Table.FromList(SecList, Splitter.SplitByNothing(), {_name}, null, ExtraValues.Error), 
                {{_name, Int64.Type}}
              )
            in
              addCol, 
          TimeCol = Table.AddColumn(SecTable, "Time", each #time([Hour ID], 0, 0), type time), 
          HourCol = Table.AddColumn(TimeCol, "Hour Text", each Text.PadStart(Text.From([Hour ID]), 2, "0") & ":00", Text.Type), 
          HourQuarter = Table.AddColumn(HourCol, "Hour Quarter", each Number.IntegerDivide([Hour ID] + 6, 6), Int64.Type), 
          HourlyQuartileCol = Table.AddColumn(
            HourQuarter, 
            "Hourly Quartile", 
            each 
              if [Hour Quarter] = 1 then
                "12AM - 6AM"
              else if [Hour Quarter] = 2 then
                "6AM - 12PM"
              else if [Hour Quarter] = 3 then
                "12PM - 6PM"
              else if [Hour Quarter] = 4 then
                "6PM - 12AM"
              else
                "Unknown", 
            type text
          ), 
          HourlyQuartileID = Table.AddColumn(
            HourlyQuartileCol, 
            "HourlyQuartileID", 
            each 
              if [Hour Quarter] = 1 then
                1
              else if [Hour Quarter] = 2 then
                2
              else if [Hour Quarter] = 3 then
                3
              else if [Hour Quarter] = 4 then
                4
              else
                99, 
            type text
          ), 
          AMPMCol = Table.AddColumn(HourlyQuartileID, "AMPM", each if [Hour Quarter] <= 2 then "AM" else "PM", type text), 
          hr_24 = Table.AddColumn(AMPMCol, "24hr", each Text.PadStart(Text.From([Hour ID]), 2, "0") & "H", Text.Type), 
          hr_12 = Table.AddColumn(
            hr_24, 
            "12hr", 
            each 
              let
                _hr = Number.ToText([Hour ID], "#"), 
                _result = 
                  if [Hour ID] = 12 then
                    _hr & " PM"
                  else if [Hour ID] <= 11 then
                    (if _hr = "" then "12" else _hr) & " AM"
                  else
                    (Text.From([Hour ID] - 12) & " PM")
              in
                _result, 
            type text
          )
        in
          hr_12
    in
      fn_hours,
// hours function end
invokeSeconds = 
    let
      SecList = {0 .. 86399}, 
      SecTable = 
        let
          _name = "Second ID", 
          addCol = Table.TransformColumnTypes(
            Table.FromList(SecList, Splitter.SplitByNothing(), {_name}, null, ExtraValues.Error), 
            {{_name, Int64.Type}}
          )
        in
          addCol, 
      TimeDurCol = Table.AddColumn(SecTable, "TimeDuration", each #duration(0, 0, 0, [Second ID]), type duration), 
      TimeCol = Table.AddColumn(
        TimeDurCol, 
        "Time", 
        each #time(Duration.Hours([TimeDuration]), Duration.Minutes([TimeDuration]), Duration.Seconds([TimeDuration])), 
        type time
      ), 
      HourCol = Table.AddColumn(TimeCol, "Hour Number", each Time.Hour([Time]), Int64.Type), 
      MinuteCol = Table.AddColumn(HourCol, "Minute Number", each Time.Minute([Time]), Int64.Type), 
      SecondCol = Table.AddColumn(MinuteCol, "Second Number", each Time.Second([Time]), Int64.Type), 
      TimeHour = Table.AddColumn(SecondCol, "Time Hour", each #time(Time.Hour([Time]), 0, 0), type time), 
      TimeHourMinute = Table.AddColumn(TimeHour, "Time Hour Minute", each #time([Hour Number], [Minute Number], 0), type time), 
      HourQuarter = Table.AddColumn(TimeHourMinute, "Hour Quarter", each Number.IntegerDivide([Hour Number] + 6, 6), Int64.Type), 
      HourlyQuartileCol = Table.AddColumn(
        HourQuarter, 
        "Hourly Quartile", 
        each 
          if [Hour Quarter] = 1 then
            "12AM - 6AM"
          else if [Hour Quarter] = 2 then
            "6AM - 12PM"
          else if [Hour Quarter] = 3 then
            "12PM - 6PM"
          else if [Hour Quarter] = 4 then
            "6PM - 12AM"
          else
            "Unknown", 
        type text
      ), 
      HourlyQuartileID = Table.AddColumn(
        HourlyQuartileCol, 
        "HourlyQuartileID", 
        each 
          if [Hour Quarter] = 1 then
            1
          else if [Hour Quarter] = 2 then
            2
          else if [Hour Quarter] = 3 then
            3
          else if [Hour Quarter] = 4 then
            4
          else
            99, 
        type text
      ), 
      AMPMCol = Table.AddColumn(HourlyQuartileID, "AMPM", each if [Hour Quarter] <= 2 then "AM" else "PM", type text), 
      RemoveTimeDurationCol = Table.RemoveColumns(AMPMCol, {"TimeDuration"})
    in
      RemoveTimeDurationCol,

finalresult = if choose_granularity = "Seconds" then invokeSeconds else  (invokeHours ?? "Hours")
in
  finalresult
    , 

// ------------------------------------------------------------------     
// 3.0: change parameter metadata here
      fnType = type function (
        // 3.0.1: first parameter
        optional choose_granularity as (
          type text
            meta 
            [
              Documentation.FieldCaption     = " Time Granularity: #(lf) Seconds or Hours ", 
              Documentation.FieldDescription = " Choose Time Granularity: #(cr,lf) Seconds or Hours ",
              Documentation.AllowedValues = {"Seconds", "Hours"}
            ]
        )
       
        // 3.0.2: second parameter
        /* ,
         optional temptext as (
          type text
            meta 
            [
              Documentation.FieldCaption     = " Choose Separator Type ", 
              Documentation.FieldDescription = " Recommended to use #(lf) forward slash / ", 
              Documentation.AllowedValues    = {"-", "/"}
            ]
        ) */
      //) 
   // 3.1: parameter return type   
    ) as list,
// ------------------------------------------------------------------
// 4.0: edit function metadata here
      documentation = 
      [  

          Documentation.Name = " fn_TimeDimension ", 
          Documentation.Description = " Generate a Time Dimension with Seconds / Hours Granularity ", 
          Documentation.LongDescription = " Generate a Time Dimension with Seconds / Hours Granularity ", 
          Documentation.Category = " ETL Category ", 
          Documentation.Source = "  PBIQUERYOUS  ", 
          Documentation.Version = " 1.0 ", 
          Documentation.Author = " Imran Haq ", 
          Documentation.Examples = 
          {
            [
            Description = "  Generate a Time Dimension with Seconds / Hours Granularity   ",
            Code    = " fn_TimeDimension( 'Seconds' ) ", 
            Result  = 
"
 1. Select Granularity
 2. Invoke Function
 3. Enjoy!
 
"

            ]
            /* ,
            [
            Description = "  description   ",
            Code    = " code ", 
            Result  = " result #(cr,lf) new line
                      #(cr,lf) new line #(cr,lf) 2 "
            ] */
          }
       
      ]
       ,
       
// ------------------------------------------------------------------
// 5.0: Choose between Parameter Documentation or Function Documentation
      functionDocumentation =      // -- function metadata
      Value.ReplaceType(invokeFunction, Value.ReplaceMetadata( Value.Type(invokeFunction), documentation)),
      
      parameterDocumentation =    // -- parameter metadata
      Value.ReplaceType(invokeFunction, fnType),
      
      replaceMeta =               // -- both metas
        Value.ReplaceType(
          Value.ReplaceType( invokeFunction, fnType ), // parameter documentation
          Value.ReplaceMetadata( Value.Type(invokeFunction), documentation) // function documentation
        ) 
    in
// ------------------------------------------------------------------
// select one of the above steps and paste below
      parameterDocumentation      /* <-- Choose final documentation type */
      
in
  fn_TimeDimension

```
