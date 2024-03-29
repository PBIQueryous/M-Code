# fn_CustomCalendar
## for non-standard Calendar Years

```ioke

let
  customFunction =  // fn_CustomPeriodCalendar                 
/* ------------------------------ 
  Author: Imran Haq - PBI QUERYOUS
  Description: fn_CustomPeriodCalendar
  Special Thanks: SQLBI (Alberto Ferrari and Marco Russo)
  Link: https://www.sqlbi.com/
 ---------------------------------*/

// 1.0: invoke function & define parameter inputs
let
  invokeFunction = (
    minYear as number,
    maxYear as number, 
    MonthsInYear as number, 
    optional AYMonthNUM as number
  ) as table =>
        
// ------------------------------------------------------------------
// 2.0: function transformations
   
let
      // // //Parameters
      // StartDate = #date(2023, 1, 1),
      // EndDate = #date(2024, 12, 31),
      // minYear = 2021,
      // maxYear = 2023,
      // MonthsInYear = 14,
      // AYMonthNUM = 8,
      //Date table code
      AYMonthStart = List.Select({1 .. 12}, each _ = AYMonthNUM){0}? ?? 1, 
      StartDate = Date.From("01/" & Text.From(AYMonthStart) & "/" & Text.From(minYear)), 
      EndDate = Date.From("31/" & Text.From(AYMonthStart - 1) & "/" & Text.From(maxYear)), 
      StartYear = minYear, 
      StartMonth = Date.Month(StartDate), 
      EndYear = maxYear, 
      EndMonth = Date.Month(EndDate), 
      var_CountDays = Duration.Days(Duration.From(EndDate - StartDate)) + 1, 
      list_Dates = List.Dates(StartDate, var_CountDays, #duration(1, 0, 0, 0)), 
      toTbl_Dates = Table.TransformColumnTypes(
        Table.RenameColumns(
          Table.FromList(list_Dates, Splitter.SplitByNothing(), null, null, ExtraValues.Error), 
          {{"Column1", "Date"}}
        ), 
        {{"Date", type date}}
      ), 
      col_MonthEnd = Table.AddColumn(
        toTbl_Dates, 
        "MonthEnd", 
        each Date.EndOfMonth([Date]), 
        type date
      ), 
      col_DataGrainOG = Table.AddColumn(
        col_MonthEnd, 
        "Original Year Month Number", 
        each Date.Year([Date]) * MonthsInYear + Date.Month([Date]) - 1
      ), 
      tempTbl_Grouped = 
        let
          _record = [
            MonthEnd = Table.RemoveColumns(
              Table.Group(col_DataGrainOG, {"MonthEnd"}, {{"Detail", each _}}), 
              {"Detail"}
            )
          ]
        in
          _record, 
      ListMin = 
        let
          result = [
            xStartYear  = StartYear, 
            xMonths     = MonthsInYear, 
            xStartMonth = StartMonth, 
            xCalc1      = if (xStartMonth < AYMonthStart) then 1 else 0, 
            xCalc2      = (xStartYear * xMonths + xStartMonth) - 1, 
            xCalc3      = (xMonths - 12) * xCalc1, 
            xResult     = xCalc2 - xCalc3
          ]
        in
          result[xResult], 
      ListMax = 
        let
          result = [
            xEndYear  = EndYear, 
            xMonths   = MonthsInYear, 
            xEndMonth = EndMonth, 
            xCalc1    = if (xEndMonth < AYMonthStart) then 1 else 0, 
            xCalc2    = (xEndYear * xMonths + xEndMonth) - 1, 
            xCalc3    = (xMonths - 12) * xCalc1, 
            xResult   = xCalc2 - xCalc3
          ]
        in
          result[xResult], 
      GenerateList = {ListMin .. ListMax}, 
      tbl_MonthlyGrain = Table.FromList(
        GenerateList, 
        Splitter.SplitByNothing(), 
        null, 
        null, 
        ExtraValues.Error
      ), 
      col_Rename = Table.RenameColumns(tbl_MonthlyGrain, {{"Column1", "OG_MonthYear_ID"}}), 
      col_INT = Table.TransformColumnTypes(col_Rename, {{"OG_MonthYear_ID", Int64.Type}}), 
      col_AcademicMonth = Table.AddColumn(
        col_INT, 
        "AcademicMonth_NUM", 
        each 
          let
            result = [
              xMonthInt = [OG_MonthYear_ID] + 1, 
              xCond1    = if (AYMonthStart > 1) then 1 else 0, 
              xCalc1    = MonthsInYear + 1 - AYMonthStart, 
              xMod      = [OG_MonthYear_ID] + (1 * xCond1 * xCalc1), 
              xResult   = Number.Mod(xMod, MonthsInYear) + 1
            ]
          in
            result[xResult], 
        Int64.Type
      ), 
      fn_GetMonth = 
        let
          invokeFunction = (fiscalPeriod as any, fiscalStart as number) =>
            let
              fiscalMonth = if fiscalStart = null then 1 else fiscalStart, 
              columnName  = fiscalPeriod, 
              calc        = (12 - fiscalMonth) + 1, 
              x           = Number.Abs(columnName + fiscalMonth) - 1, 
              y           = Number.Abs(columnName + fiscalMonth) - 13, 
              z           = if columnName <= calc then x else y
            in
              z
        in
          invokeFunction, 
      col_GetActualMonth = Table.AddColumn(
        col_AcademicMonth, 
        "ActualMonth_NUM", 
        each fn_GetMonth([AcademicMonth_NUM], AYMonthStart), 
        Int64.Type
      ), 
      col_AcYearStart = Table.AddColumn(
        col_GetActualMonth, 
        "AcademicYear_NUM", 
        each 
          let
            result = [
              xMonthInt = [OG_MonthYear_ID], 
              xCond1    = if (AYMonthStart > 1) then 1 else 0, 
              xCalc1    = MonthsInYear + 1 - AYMonthStart, 
              xMod      = xMonthInt + (1 * xCond1 * xCalc1), 
              xResult   = Number.IntegerDivide(xMod, MonthsInYear) - 1
            ]
          in
            result[xResult], 
        Int64.Type
      ), 
      col_Year = Table.AddColumn(
        col_AcYearStart, 
        "ActualYear_NUM", 
        each 
          let
            x1 = if [ActualMonth_NUM] > [AcademicMonth_NUM] then 1 else 0, 
            x2 = ([AcademicYear_NUM] - 1 * x1) + 1
          in
            x2, 
        Int64.Type
      ), 
      col_CalendarMonth = Table.AddColumn(
        col_Year, 
        "RelativeMonth_NUM", 
        each if [AcademicMonth_NUM] >= 12 then 7 else [ActualMonth_NUM], 
        Int64.Type
      ), 
      col_Month_Actual = Table.AddColumn(
        col_CalendarMonth, 
        "Actual_Date", 
        each Date.From("1/" & Text.From([ActualMonth_NUM]) & "/" & Text.From([ActualYear_NUM])), 
        type date
      ), 
      col_Month_Relative = Table.AddColumn(
        col_Month_Actual, 
        "Relative_Date", 
        each Date.From("1/" & Text.From([RelativeMonth_NUM]) & "/" & Text.From([ActualYear_NUM])), 
        type date
      ), 
      col_ActualMonthEnd = Table.AddColumn(
        col_Month_Relative, 
        "ActualMonth_End", 
        each Date.EndOfMonth([Actual_Date]), 
        type date
      ), 
      col_RelativeMonthEnd = Table.AddColumn(
        col_ActualMonthEnd, 
        "RelativeMonth_End", 
        each Date.EndOfMonth([Relative_Date]), 
        type date
      ), 
      col_Return = Table.AddColumn(
        col_RelativeMonthEnd, 
        "Return", 
        each "R" & Text.PadStart(Text.From([AcademicMonth_NUM]), 2, "0"), 
        type text
      ), 
      col_ActualMonthName = Table.AddColumn(
        col_Return, 
        "ActualMonth_Name", 
        each Text.Start(Date.MonthName([ActualMonth_End]), 3), 
        type text
      ), 
      col_RelativeMonthName = Table.AddColumn(
        col_ActualMonthName, 
        "RelativeMonth_Name", 
        each Text.Start(Date.MonthName([RelativeMonth_End]), 3), 
        type text
      ), 
      col_MonthPeriod = Table.AddColumn(
        col_RelativeMonthName, 
        "Month Period", 
        each 
          let
            x0 = Text.PadStart(Text.From([AcademicMonth_NUM]), 2, "0"), 
            x1 = if [AcademicMonth_NUM] <= 12 then [RelativeMonth_Name] else "P" & x0
          in
            x1, 
        type text
      ), 
      col_AcademicPeriod = Table.AddColumn(
        col_MonthPeriod, 
        "Academic Period", 
        each 
          let
            StartYear = Text.End(Text.From([AcademicYear_NUM]), 2), 
            EndYear   = Text.End(Text.From([AcademicYear_NUM] + 1), 2)
          in
            StartYear & "/" & EndYear, 
        type text
      ), 
      col_Quarter = Table.AddColumn(
        col_AcademicPeriod, 
        "Quarter", 
        each "Q" & Text.From(Date.QuarterOfYear([Actual_Date])), 
        type text
      ), 
      col_AcademicQuarter = Table.AddColumn(
        col_Quarter, 
        "Academic Quarter", 
        each 
          let
            xCol   = [AcademicMonth_NUM], 
            x1     = xCol >= 1 and xCol <= 3, 
            x2     = xCol >= 4 and xCol <= 6, 
            x3     = xCol >= 7 and xCol <= 9, 
            x4     = xCol >= 10 and xCol <= 12, 
            result = if x1 then "AQ1" else if x2 then "AQ2" else if x3 then "AQ3" else "AQ4"
          in
            result, 
        type text
      )
    in
      col_AcademicQuarter

    , 

// ------------------------------------------------------------------     
/*
    minYear as number,
    maxYear as number, 
    MonthsInYear as number, 
    optional AYMonthNUM as number
*/

// 3.0: change parameter metadata here
      fnType = type function (

        // 3.0.1: Calendar Start Year parameter
        minYear as (
          type number
            meta 
            [
              Documentation.FieldCaption     = " Start Year: #(lf) 4-digit integer ", 
              Documentation.FieldDescription = " 4-digit integer: #(cr,lf) YYYY ",
              Documentation.SampleValues = {2021}
            ]
        ),

        // 3.0.2: Calendar End Year parameter
        maxYear as (
          type number
            meta 
            [
              Documentation.FieldCaption     = " Start Year: #(lf) 4-digit integer ", 
              Documentation.FieldDescription = " 4-digit integer: #(cr,lf) YYYY ",
              Documentation.SampleValues = {2023}
            ]
        ),
        // 3.0.3: Fiscal Start Month parameter
        MonthsInYear as (
          type number
            meta 
            [
              Documentation.FieldCaption     = " Total Months in Period: #(lf) (eg: 14) ", 
              Documentation.FieldDescription = " Total Months in Custom Period: #(lf) (eg: 14) ",
              Documentation.SampleValues = {14}
            ]
        )
       
        // 3.0.4: Academic Start Month parameter
        ,
         optional AYMonthNUM as (
          type number
            meta 
            [
              Documentation.FieldCaption     = " Fiscal Month Start: #(lf) Aug = 8, May = 5 ", 
              Documentation.FieldDescription = " Fiscal Month Start: #(lf) Aug = 8, May = 5 ", 
              Documentation.SampleValues    = {123}
            ]
        )


   // 3.1: parameter return type   
    ) as list,
// ------------------------------------------------------------------
// 4.0: edit function metadata here
      documentation = 
      [  
// Inspired by SQLBI - Alberto Ferrari and Marco Russo (https://www.daxpatterns.com/custom-time-related-calculations/)
          Documentation.Name = " fnCustomPeriodCalendar ", 
          Documentation.Description = " Custom Calendar for non-standard Periods ", 
          Documentation.LongDescription = " Custom Calendar for non-standard Periods ", 
          Documentation.Category = " Calendar Category ", 
          Documentation.Source = "  PBIQUERYOUS  ", 
          Documentation.Version = " 1.0 (Custom Calendar for non-standard Periods (> 12 months))", 
          Documentation.Author = " Imran Haq ", 
          Documentation.Examples = 
          {
            [
            Description = "  Custom Calendar for non-standard Periods   ",
            Code    = " fn_CustomPeriodCalendar(2021, 2024, 14, 8) ", 
            Result  = 
"
 1. Input paramaters
 2. Invoke function
 3. Optional: replace start / end year parameters with dynamic values to automatically extend table
 
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
      Value.ReplaceType(functionDocumentation, fnType)
    in
// ------------------------------------------------------------------
// select one of the above steps and paste below
      parameterDocumentation      /* <-- Choose final documentation type */
      
in
  customFunction

```
