# Date Table

```ioke
let
  customFunction =  // fnReplaceBlanksRemoveNulls                 
/* ------------------------------ 
  Author: Imran Haq - PBI QUERYOUS
  Description: fnReplaceBlanksRemoveNulls
 ---------------------------------*/

// 1.0: invoke function & define parameter inputs
let
  invokeFunction = (
    StartYearNUM as number, 
    EndYearNUM as number, 
    optional FYStartMonthNum as number, 
    optional AYStartMonthNum as number, 
    optional Holidays as list, 
    optional WDStartNum as number, 
    optional AddRelativeNetWorkdays as logical
  ) as table =>
        
// ------------------------------------------------------------------
// 2.0: function transformations
   
let
                // // // //Parameters
      // StartDate = #date(2020, 1, 1), // - turn off in custom function
      // EndDate = #date(2024, 12, 31), // -turn off in custom function
      // FYStartMonthNum = null,
      // AYStartMonthNum  = null,
      // Holidays = {},
      // WDStartNum = 1,
      // AddRelativeNetWorkdays = true,

                //Date table code
      StartDate = Date.From("01/01/" & Text.From(StartYearNUM)),  // -- turn on in custom fn                          
      EndDate = Date.From("31/12/" & Text.From(EndYearNUM)),  // -- turn on in custom fn                          
      FYStartMonth = List.Select({1 .. 12}, each _ = FYStartMonthNum){0}? ?? 1, 
      AYStartMonth = List.Select({1 .. 12}, each _ = AYStartMonthNum){0}? ?? 1, 
      WDStart = List.Select({0 .. 1}, each _ = WDStartNum){0}? ?? 0, 
      var_CurrentDate = Date.From(DateTime.FixedLocalNow()), 
      var_DayCount = Duration.Days(Duration.From(EndDate - StartDate)) + 1, 
      list_Dates = List.Dates(StartDate, var_DayCount, #duration(1, 0, 0, 0)), 
      tx_AddToday = 
        if EndDate < var_CurrentDate then
          List.Combine({list_Dates, {var_CurrentDate}})
        else
          list_Dates, 
      make_Table = Table.FromList(
        tx_AddToday, 
        Splitter.SplitByNothing(), 
        type table [Date = Date.Type]
      ), 
      col_Year = Table.AddColumn(make_Table, "YearNUM", each Date.Year([Date]), type number), 
      col_YearOFFSET = Table.AddColumn(
        col_Year, 
        "CurrYearOffset", 
        each Date.Year([Date]) - Date.Year(Date.From(var_CurrentDate)), 
        type number
      ), 
      col_isYearComplete = Table.AddColumn(
        col_YearOFFSET, 
        "isYearComplete", 
        each Date.EndOfYear([Date]) < Date.From(Date.EndOfYear(var_CurrentDate)), 
        type logical
      ), 
      col_QuarterNUM = Table.AddColumn(
        col_isYearComplete, 
        "QuarterNUM", 
        each Date.QuarterOfYear([Date]), 
        type number
      ), 
      col_QuarterTXT = Table.AddColumn(
        col_QuarterNUM, 
        "Quarter", 
        each "Q" & Number.ToText([QuarterNUM]), 
        type text
      ), 
      col_QuarterSTART = Table.AddColumn(
        col_QuarterTXT, 
        "Start of Quarter", 
        each Date.StartOfQuarter([Date]), 
        type date
      ), 
      col_QuarterEND = Table.AddColumn(
        col_QuarterSTART, 
        "End of Quarter", 
        each Date.EndOfQuarter([Date]), 
        type date
      ), 
      col_Quarter_Year = Table.AddColumn(
        col_QuarterEND, 
        "Quarter & Year", 
        each "Q" & Number.ToText(Date.QuarterOfYear([Date])) & Date.ToText([Date], [Format = " yy"]), 
        type text
      ), 
      col_QuarterYearINT = Table.AddColumn(
        col_Quarter_Year, 
        "QuarterYearINT", 
        each [YearNUM] * 10 + [QuarterNUM], 
        type number
      ), 
      col_QuarterOFFSET = Table.AddColumn(
        col_QuarterYearINT, 
        "CurrQuarterOffset", 
        each ((4 * Date.Year([Date])) + Date.QuarterOfYear([Date]))
          - (
            (4 * Date.Year(Date.From(var_CurrentDate)))
              + Date.QuarterOfYear(Date.From(var_CurrentDate))
          ), 
        type number
      ), 
      col_isQuarterComplete = Table.AddColumn(
        col_QuarterOFFSET, 
        "isQuarterComplete", 
        each 
          let
            qtrEnd        = Date.EndOfQuarter([Date]), 
            currQtrEnd    = Date.From(Date.EndOfQuarter(var_CurrentDate)), 
            isQtrComplete = qtrEnd < currQtrEnd
          in
            isQtrComplete, 
        type logical
      ), 
      col_MonthNUM = Table.AddColumn(
        col_isQuarterComplete, 
        "MonthNUM", 
        each Date.Month([Date]), 
        type number
      ), 
      col_MonthSTART = Table.AddColumn(
        col_MonthNUM, 
        "Start of Month", 
        each Date.StartOfMonth([Date]), 
        type date
      ), 
      col_MonthEND = Table.AddColumn(
        col_MonthSTART, 
        "End of Month", 
        each Date.EndOfMonth([Date]), 
        type date
      ), 
      col_CalendarMONTH = Table.AddColumn(
        col_MonthEND, 
        "Month & Year", 
        each Text.Proper(Date.ToText([Date], [Format = "MMM yy"])), 
        type text
      ), 
      col_MonthYearINT = Table.AddColumn(
        col_CalendarMONTH, 
        "MonthYearINT", 
        each [YearNUM] * 100 + [MonthNUM], 
        type number
      ), 
      col_MonthOFFSET = Table.AddColumn(
        col_MonthYearINT, 
        "CurrMonthOffset", 
        each ((12 * Date.Year([Date])) + Date.Month([Date]))
          - ((12 * Date.Year(Date.From(var_CurrentDate))) + Date.Month(Date.From(var_CurrentDate))), 
        type number
      ), 
      col_isMonthComplete = Table.AddColumn(
        col_MonthOFFSET, 
        "isMonthComplete", 
        each Date.EndOfMonth([Date]) < Date.From(Date.EndOfMonth(var_CurrentDate)), 
        type logical
      ), 
      col_MonthNAME = Table.AddColumn(
        col_isMonthComplete, 
        "Month Name", 
        each Text.Proper(Date.ToText([Date], "MMMM")), 
        type text
      ), 
      col_MonthNameSHORT = Table.AddColumn(
        col_MonthNAME, 
        "Month Short", 
        each Text.Proper(Date.ToText([Date], "MMM")), 
        type text
      ), 
      col_MonthNameINITIAL = Table.AddColumn(
        col_MonthNameSHORT, 
        "Month Initial", 
        each Text.Start([Month Name], 1)
          & Text.Repeat(Character.FromNumber(8203), Date.Month([Date])), 
        type text
      ), 
      var_CurrentMonthName = Date.MonthName(DateTime.LocalNow()), 
      col_MonthSelection = Table.AddColumn(
        col_MonthNameINITIAL, 
        "Month Selection", 
        each if [Month Name] = var_CurrentMonthName then "Current" else [Month Short], 
        type text
      ), 
      col_DayMonthNUM = Table.AddColumn(
        col_MonthSelection, 
        "DayMonthNUM", 
        each Date.Day([Date]), 
        type number
      ), 
      col_WeekNUM = Table.AddColumn(
        col_DayMonthNUM, 
        "Week Number", 
        each 
          if Number.RoundDown(
            (Date.DayOfYear([Date]) - (Date.DayOfWeek([Date], Day.Monday) + 1) + 10) / 7
          )
            = 0
          then
            Number.RoundDown(
              (
                Date.DayOfYear(#date(Date.Year([Date]) - 1, 12, 31))
                  - (Date.DayOfWeek(#date(Date.Year([Date]) - 1, 12, 31), Day.Monday) + 1)
                  + 10
              )
                / 7
            )
          else if (
            Number.RoundDown(
              (Date.DayOfYear([Date]) - (Date.DayOfWeek([Date], Day.Monday) + 1) + 10) / 7
            )
              = 53 and (Date.DayOfWeek(#date(Date.Year([Date]), 12, 31), Day.Monday) + 1 < 4)
          )
          then
            1
          else
            Number.RoundDown(
              (Date.DayOfYear([Date]) - (Date.DayOfWeek([Date], Day.Monday) + 1) + 10) / 7
            ), 
        type number
      ), 
      col_WeekSTART = Table.AddColumn(
        col_WeekNUM, 
        "Start of Week", 
        each Date.StartOfWeek([Date], Day.Monday), 
        type date
      ), 
      col_WeekEND = Table.AddColumn(
        col_WeekSTART, 
        "End of Week", 
        each Date.EndOfWeek([Date], Day.Monday), 
        type date
      ), 
      col_CalendarWEEK = Table.AddColumn(
        col_WeekEND, 
        "Week & Year", 
        each "W"
          & Text.PadStart(Text.From([Week Number]), 2, "0")
          & " "
          & Text.End(Text.From(Date.Year(Date.AddDays(Date.StartOfWeek([Date], Day.Monday), 3))), 2), 
        type text
      ), 
      col_WeekYearINT = Table.AddColumn(
        col_CalendarWEEK, 
        "WeekYearINT", 
        each Date.Year(Date.AddDays(Date.StartOfWeek([Date], Day.Monday), 3)) * 100 + [Week Number], 
        Int64.Type
      ), 
      col_WeekOFFSET = Table.AddColumn(
        col_WeekYearINT, 
        "CurrWeekOffset", 
        each (
          Number.From(Date.StartOfWeek([Date], Day.Monday))
            - Number.From(Date.StartOfWeek(var_CurrentDate, Day.Monday))
        )
          / 7, 
        type number
      ), 
      col_isWeekComplete = Table.AddColumn(
        col_WeekOFFSET, 
        "WeekCompleted", 
        each Date.EndOfWeek([Date], Day.Monday)
          < Date.From(Date.EndOfWeek(var_CurrentDate, Day.Monday)), 
        type logical
      ), 
      col_DayWeekNUM = Table.AddColumn(
        col_isWeekComplete, 
        "DayWeekNUM", 
        each Date.DayOfWeek([Date], Day.Monday) + WDStart, 
        Int64.Type
      ), 
      col_DayNAME = Table.AddColumn(
        col_DayWeekNUM, 
        "Day of Week Name", 
        each Text.Proper(Date.ToText([Date], "dddd")), 
        type text
      ), 
      col_DayINITIAL = Table.AddColumn(
        col_DayNAME, 
        "Day Initial", 
        each Text.Proper(Text.Start([Day of Week Name], 1))
          & Text.Repeat(Character.FromNumber(8203), Date.DayOfWeek([Date], Day.Monday) + WDStart), 
        type text
      ), 
      col_DayYearNUM = Table.AddColumn(
        col_DayINITIAL, 
        "DayYearNUM", 
        each Date.DayOfYear([Date]), 
        Int64.Type
      ), 
      col_DayMonthYearINT = Table.AddColumn(
        col_DayYearNUM, 
        "DateINT", 
        each [YearNUM] * 10000 + [MonthNUM] * 100 + [DayMonthNUM], 
        type number
      ), 
      col_DayOFFSET = Table.AddColumn(
        col_DayMonthYearINT, 
        "CurrDayOffset", 
        each Number.From([Date]) - Number.From(var_CurrentDate), 
        type number
      ), 
      col_isAfterToday = Table.AddColumn(
        col_DayOFFSET, 
        "IsAfterToday", 
        each not ([Date] <= Date.From(var_CurrentDate)), 
        type logical
      ), 
      col_isWeekDay = Table.AddColumn(
        col_isAfterToday, 
        "IsWeekDay", 
        each if Date.DayOfWeek([Date], Day.Monday) > 4 then false else true, 
        type logical
      ), 
      col_isHoliday = Table.AddColumn(
        col_isWeekDay, 
        "IsHoliday", 
        each if Holidays = null then "Unknown" else List.Contains(Holidays, [Date]), 
        if Holidays = null then type text else type logical
      ), 
      col_isBusinessDay = Table.AddColumn(
        col_isHoliday, 
        "IsBusinessDay", 
        each if [IsWeekDay] = true and [IsHoliday] <> true then true else false, 
        type logical
      ), 
      col_DayTYPE = Table.AddColumn(
        col_isBusinessDay, 
        "Day Type", 
        each 
          if [IsHoliday] = true then
            "Holiday"
          else if [IsWeekDay] = false then
            "Weekend"
          else if [IsWeekDay] = true then
            "Weekday"
          else
            null, 
        type text
      ), 
      col_ISOYear = Table.AddColumn(
        col_DayTYPE, 
        "ISO Year", 
        each Date.Year(Date.AddDays(Date.StartOfWeek([Date], Day.Monday), 3)), 
        type number
      ), 
      col_ISOQuarterNUM = Table.AddColumn(
        col_ISOYear, 
        "ISO QuarterNUM", 
        each 
          if [Week Number] > 39 then
            4
          else if [Week Number] > 26 then
            3
          else if [Week Number] > 13 then
            2
          else
            1, 
        Int64.Type
      ), 
      col_ISOQuarterNAME = Table.AddColumn(
        col_ISOQuarterNUM, 
        "ISO Quarter", 
        each "Q" & Number.ToText([ISO QuarterNUM]), 
        type text
      ), 
      col_ISOQuarterYearNAME = Table.AddColumn(
        col_ISOQuarterNAME, 
        "ISO Quarter & Year", 
        each "Q" & Number.ToText([ISO QuarterNUM]) & " " & Number.ToText([ISO Year]), 
        type text
      ), 
      col_ISOQuarterYearINT = Table.AddColumn(
        col_ISOQuarterYearNAME, 
        "ISO QuarterYearINT", 
        each [ISO Year] * 10 + [ISO QuarterNUM], 
        type number
      ), 
      // BufferTable = Table.Buffer(Table.Distinct( col_ISOQuarterYearINT[[ISO Year], [DateInt]])),
      // InsertISOday = Table.AddColumn(col_ISOQuarterYearINT, "ISO Day of Year", (OT) => Table.RowCount( Table.SelectRows( BufferTable, (IT) => IT[DateInt] <= OT[DateInt] and IT[ISO Year] = OT[ISO Year])),  Int64.Type),
      col_FY = Table.AddColumn(
        col_ISOQuarterYearINT, 
        "Fiscal Year", 
        each 
          let
            arg1     = ([MonthNUM] >= FYStartMonth and FYStartMonth > 1), 
            yearNum1 = Text.End(Text.From([YearNUM] + 0), 2), 
            yearNum0 = Text.End(Text.From([YearNUM] - 1), 2), 
            result1  = if arg1 then yearNum1 else yearNum0
          in
            "FY" & result1, 
        type text
      ), 
      col_AY = Table.AddColumn(
        col_FY, 
        "Academic Year", 
        each 
          let
            arg1     = ([MonthNUM] >= AYStartMonth and AYStartMonth > 1), 
            yearNum1 = Text.End(Text.From([YearNUM] + 0), 2), 
            yearNum0 = Text.End(Text.From([YearNUM] - 1), 2), 
            result1  = if arg1 then yearNum1 else yearNum0
          in
            "AY" & result1, 
        type text
      ), 
      //col_FYs = Table.AddColumn(col_FY, "Fiscal Year short", each "FY" & (if [MonthNUM] >= FYStartMonth and FYStartMonth >1 then Text.PadEnd( Text.End( Text.From([YearNUM] +1), 2), 2, "0") else Text.End( Text.From([YearNUM]), 2)), type text),
      col_FQ = Table.AddColumn(
        col_AY, 
        "Fiscal Quarter", 
        each "FQ"
          & Text.From(Number.RoundUp(Date.Month(Date.AddMonths([Date], - (FYStartMonth - 1))) / 3))
          & " "
          & (
            if [MonthNUM] >= FYStartMonth and FYStartMonth > 1 then
              Text.End(Text.From([YearNUM] + 0), 2)
            else
              Text.End(Text.From([YearNUM] - 1), 2)
          ), 
        type text
      ), 
      col_AQ = Table.AddColumn(
        col_FQ, 
        "Academic Quarter", 
        each "AQ"
          & Text.From(Number.RoundUp(Date.Month(Date.AddMonths([Date], - (AYStartMonth - 1))) / 3))
          & " "
          & (
            if [MonthNUM] >= AYStartMonth and AYStartMonth > 1 then
              Text.End(Text.From([YearNUM] + 0), 2)
            else
              Text.End(Text.From([YearNUM] - 1), 2)
          ), 
        type text
      ), 
      col_FQtrYrINT = Table.AddColumn(
        col_AQ, 
        "FiscalQuarterYearINT", 
        each (
          if [MonthNUM] >= FYStartMonth and FYStartMonth > 1 then [YearNUM] + 0 else [YearNUM] - 1
        )
          * 10 + Number.RoundUp(Date.Month(Date.AddMonths([Date], - (FYStartMonth - 1))) / 3), 
        type number
      ), 
      col_AQtrYrINT = Table.AddColumn(
        col_FQtrYrINT, 
        "AcademicQuarterYearINT", 
        each (
          if [MonthNUM] >= AYStartMonth and AYStartMonth > 1 then [YearNUM] + 0 else [YearNUM] - 1
        )
          * 10 + Number.RoundUp(Date.Month(Date.AddMonths([Date], - (AYStartMonth - 1))) / 3), 
        type number
      ), 
      col_FPNUM = Table.AddColumn(
        col_AQtrYrINT, 
        "FiscalPeriodNUM", 
        each 
          let
            arg1   = [MonthNUM] >= FYStartMonth and FYStartMonth > 1, 
            res1   = [MonthNUM] - (FYStartMonth - 1), 
            arg2   = [MonthNUM] >= FYStartMonth and FYStartMonth = 1, 
            res2   = [MonthNUM], 
            res3   = [MonthNUM] + (12 - FYStartMonth + 1), 
            result = if arg1 then res1 else if arg2 then res2 else res3
          in
            result, 
        type number
      ), 
      col_APNUM = Table.AddColumn(
        col_FPNUM, 
        "AcademicPeriodNUM", 
        each 
          let
            arg1   = [MonthNUM] >= AYStartMonth and AYStartMonth > 1, 
            res1   = [MonthNUM] - (AYStartMonth - 1), 
            arg2   = [MonthNUM] >= AYStartMonth and AYStartMonth = 1, 
            res2   = [MonthNUM], 
            res3   = [MonthNUM] + (12 - AYStartMonth + 1), 
            result = if arg1 then res1 else if arg2 then res2 else res3
          in
            result, 
        type number
      ), 
      col_FYPeriod = Table.AddColumn(
        col_APNUM, 
        "Fiscal Period", 
        each "FP"
          & Text.PadStart(Text.From([FiscalPeriodNUM]), 2, "0")
          & " "
          & (
            if [MonthNUM] >= FYStartMonth and FYStartMonth > 1 then
              Text.End(Text.From([YearNUM] + 0), 2)
            else
              Text.End(Text.From([YearNUM] - 1), 2)
          ), 
        type text
      ), 
      col_AYPeriod = Table.AddColumn(
        col_FYPeriod, 
        "Academic Period", 
        each "AP"
          & Text.PadStart(Text.From([AcademicPeriodNUM]), 2, "0")
          & " "
          & (
            if [MonthNUM] >= AYStartMonth and AYStartMonth > 1 then
              Text.End(Text.From([YearNUM] + 0), 2)
            else
              Text.End(Text.From([YearNUM] - 1), 2)
          ), 
        type text
      ), 
      col_FPYrINT = Table.AddColumn(
        col_AYPeriod, 
        "FiscalPeriodYearINT", 
        each (
          if [MonthNUM] >= FYStartMonth and FYStartMonth > 1 then [YearNUM] + 0 else [YearNUM] - 1
        )
          * 100 + [FiscalPeriodNUM], 
        type number
      ), 
      col_APYrINT = Table.AddColumn(
        col_FPYrINT, 
        "AcademicPeriodYearINT", 
        each (
          if [MonthNUM] >= AYStartMonth and AYStartMonth > 1 then [YearNUM] + 0 else [YearNUM] - 1
        )
          * 100 + [AcademicPeriodNUM], 
        type number
      ), 
      var_FiscalCalendarSTART = #date(Date.Year(StartDate) - 1, FYStartMonth, 1), 
      var_AcademicCalendarSTART = #date(Date.Year(StartDate) - 1, AYStartMonth, 1), 
      col_FiscalFirstDay = Table.AddColumn(
        col_APYrINT, 
        "FiscalFirstDate", 
        each 
          if [MonthNUM] >= FYStartMonth and FYStartMonth > 1 then
            #date(Date.Year([Date]) + 0, FYStartMonth, 1)
          else
            #date(Date.Year([Date]) - 1, FYStartMonth, 1), 
        type date
      ), 
      col_AcademicFirstDay = Table.AddColumn(
        col_FiscalFirstDay, 
        "AcademicFirstDate", 
        each 
          if [MonthNUM] >= AYStartMonth and AYStartMonth > 1 then
            #date(Date.Year([Date]) + 0, AYStartMonth, 1)
          else
            #date(Date.Year([Date]) - 1, AYStartMonth, 1), 
        type date
      ), 
      var_Table = Table.FromList(
        List.Transform({Number.From(var_AcademicCalendarSTART) .. Number.From(EndDate)}, Date.From), 
        Splitter.SplitByNothing(), 
        type table [DateFW = Date.Type]
      ), 
      col_FFD = Table.AddColumn(
        var_Table, 
        "FiscalFirstDay", 
        each 
          if Date.Month([DateFW]) < FYStartMonth then
            #date(Date.Year([DateFW]) - 1, FYStartMonth, 1)
          else
            #date(Date.Year([DateFW]) + 0, FYStartMonth, 1)
      ), 
      col_FWSD = Table.AddColumn(
        col_FFD, 
        "FWStartDate", 
        each Date.AddYears(Date.StartOfWeek([DateFW], Day.Monday), 0)
      ), 
      tbl_Group1 = Table.Group(
        col_FWSD, 
        {"FiscalFirstDay", "FWStartDate"}, 
        {
          {
            "AllRows", 
            each _, 
            type table [DateFW = nullable date, FiscalFirstDay = date, FWStartDate = date]
          }
        }
      ), 
      tbl_Group2 = Table.Group(
        tbl_Group1, 
        {"FiscalFirstDay"}, 
        {
          {
            "AllRows2", 
            each _, 
            type table [FiscalFirstDay = date, FWStartDate = date, AllRows = table]
          }
        }
      ), 
      col_Index = Table.AddColumn(
        tbl_Group2, 
        "Custom", 
        each Table.AddIndexColumn([AllRows2], "Fiscal Week Number", 1, 1)
      )[[Custom]], 
      cols_Expand1 = Table.ExpandTableColumn(
        col_Index, 
        "Custom", 
        {"FiscalFirstDay", "FWStartDate", "AllRows", "Fiscal Week Number"}, 
        {"FiscalFirstDay", "FWStartDate", "AllRows", "Fiscal Week Number"}
      ), 
      cols_Expand2 = Table.ExpandTableColumn(cols_Expand1, "AllRows", {"DateFW"}, {"DateFW"})[
        [DateFW], 
        [Fiscal Week Number]
      ], 
      join_Date_DateFW = Table.Join(
        col_AcademicFirstDay, 
        {"Date"}, 
        cols_Expand2, 
        {"DateFW"}, 
        JoinKind.LeftOuter, 
        JoinAlgorithm.SortMerge
      ), 
      var_FYLogicTest = List.Contains({null}, FYStartMonthNum), 
      var_AYLogicTest = List.Contains({null}, AYStartMonthNum), 
      var_FYAYTest = var_FYLogicTest = true and var_AYLogicTest = true, 
      txt_Replace = 
        if var_AYLogicTest then
          Table.ReplaceValue(
            join_Date_DateFW, 
            each [Fiscal Week Number], 
            each if FYStartMonth = 1 then [Week Number] else [Fiscal Week Number], 
            Replacer.ReplaceValue, 
            {"Fiscal Week Number"}
          )
        else
          join_Date_DateFW, 
      col_FYW = Table.AddColumn(
        txt_Replace, 
        "Fiscal Week", 
        each 
          if var_AYLogicTest then
            "F" & [#"Week & Year"]
          else if FYStartMonth = 1 then
            "FW"
              & Text.PadStart(Text.From([Fiscal Week Number]), 2, "0")
              & Date.ToText(Date.AddYears([Date], 0), " yy")
          else if Date.Month([Date]) < FYStartMonth then
            "FW"
              & Text.PadStart(Text.From([Fiscal Week Number]), 2, "0")
              & Date.ToText(Date.AddYears([Date], - 1), " yy")
          else
            "FW"
              & Text.PadStart(Text.From([Fiscal Week Number]), 2, "0")
              & " "
              & Text.End(Text.From(Date.Year([Date]) + 0), 2), 
        type text
      ), 
      col_FWYearINT = Table.AddColumn(
        col_FYW, 
        "FiscalWeekYearINT", 
        each 
          if var_FYLogicTest then
            [WeeknYear]
          else
            (
              if FYStartMonth = 1 then
                Date.Year([Date])
              else if Date.Month([Date]) < FYStartMonth then
                Date.Year([Date]) - 1
              else
                Date.Year([Date]) + 0
            )
              * 100 + [Fiscal Week Number], 
        Int64.Type
      ), 
      rec_CurrentDate = Table.SelectRows(col_FWYearINT, each ([Date] = var_CurrentDate)), 
      var_CurrISOYear = rec_CurrentDate{0}[ISO Year], 
      var_CurrISOQtr = rec_CurrentDate{0}[ISO QuarterNUM], 
      var_CurrYear = rec_CurrentDate{0}[YearNUM], 
      var_CurrMonth = rec_CurrentDate{0}[MonthNUM], 
      var_FFD = rec_CurrentDate{0}[FiscalFirstDate], 
      var_AFD = rec_CurrentDate{0}[AcademicFirstDate], 
      var_PFFD = Date.AddYears(var_FFD, - 1), 
      var_PAFD = Date.AddYears(var_AFD, - 1), 
      var_CurrFY = rec_CurrentDate{0}[Fiscal Year], 
      var_CurrAY = rec_CurrentDate{0}[Academic Year], 
      var_CurrFQ = rec_CurrentDate{0}[FiscalQuarterYearINT], 
      var_CurrAQ = rec_CurrentDate{0}[AcademicQuarterYearINT], 
      var_CurrFP = rec_CurrentDate{0}[FiscalPeriodYearINT], 
      var_CurrAP = rec_CurrentDate{0}[AcademicPeriodYearINT], 
      var_CurrFW = rec_CurrentDate{0}[FiscalWeekYearINT], 
      col_ISOYearOFFSET = Table.AddColumn(
        col_FWYearINT, 
        "ISO CurrYearOffset", 
        each [ISO Year] - var_CurrISOYear, 
        type number
      ), 
      col_ISOQuarterOFFSET = Table.AddColumn(
        col_ISOYearOFFSET, 
        "ISO CurrQuarterOffset", 
        each ((4 * [ISO Year]) + [ISO QuarterNUM]) - ((4 * var_CurrISOYear) + var_CurrISOQtr), 
        type number
      ), 
      col_FiscalYearOFFSET = Table.AddColumn(
        col_ISOQuarterOFFSET, 
        "Fiscal CurrYearOffset", 
        each try
          (if [MonthNUM] >= FYStartMonth then [YearNUM] + 1 else [YearNUM])
            - (if var_CurrMonth >= FYStartMonth then var_CurrYear + 1 else var_CurrYear)
        otherwise
          null, 
        type number
      ), 
      col_AcademicYearOFFSET = Table.AddColumn(
        col_FiscalYearOFFSET, 
        "Academic CurrYearOffset", 
        each try
          (if [MonthNUM] >= AYStartMonth then [YearNUM] + 1 else [YearNUM])
            - (if var_CurrMonth >= AYStartMonth then var_CurrYear + 1 else var_CurrYear)
        otherwise
          null, 
        type number
      ), 
      col_isCurrFY = Table.AddColumn(
        col_AcademicYearOFFSET, 
        "IsCurrentFY", 
        each if [Fiscal Year] = var_CurrFY then true else false, 
        type logical
      ), 
      col_isCurrAY = Table.AddColumn(
        col_isCurrFY, 
        "IsCurrentAY", 
        each if [Academic Year] = var_CurrAY then true else false, 
        type logical
      ), 
      col_isCurrFQ = Table.AddColumn(
        col_isCurrAY, 
        "IsCurrentFQ", 
        each if [FiscalQuarterYearINT] = var_CurrFQ then true else false, 
        type logical
      ), 
      col_isCurrAQ = Table.AddColumn(
        col_isCurrFQ, 
        "IsCurrentAQ", 
        each if [AcademicQuarterYearINT] = var_CurrAQ then true else false, 
        type logical
      ), 
      col_isCurrFP = Table.AddColumn(
        col_isCurrAQ, 
        "IsCurrentFP", 
        each if [FiscalPeriodYearINT] = var_CurrFP then true else false, 
        type logical
      ), 
      col_isCurrAP = Table.AddColumn(
        col_isCurrFP, 
        "IsCurrentAP", 
        each if [AcademicPeriodYearINT] = var_CurrAP then true else false, 
        type logical
      ), 
      col_isCurrFW = Table.AddColumn(
        col_isCurrAP, 
        "IsCurrentFW", 
        each if [FiscalWeekYearINT] = var_CurrFW then true else false, 
        type logical
      ), 
      col_isPrevYTD = Table.AddColumn(
        col_isCurrFW, 
        "IsPYTD", 
        each 
          if var_CurrYear - 1 = [YearNUM] and [DayYearNUM] <= rec_CurrentDate{0}[DayYearNUM] then
            true
          else
            false, 
        type logical
      ), 
      list_PrevFiscalYearDates = List.Buffer(
        Table.SelectRows(
          Table.ExpandTableColumn(
            Table.NestedJoin(
              Table.AddIndexColumn(
                Table.RenameColumns(
                  Table.TransformColumnTypes(
                    Table.FromList(
                      List.Dates(var_PFFD, Number.From(var_FFD - var_PFFD), #duration(1, 0, 0, 0)), 
                      Splitter.SplitByNothing()
                    ), 
                    {{"Column1", type date}}
                  ), 
                  {{"Column1", "DateFY"}}
                ), 
                "Index", 
                1, 
                1
              ), 
              {"Index"}, 
              Table.AddIndexColumn(
                Table.RenameColumns(
                  Table.TransformColumnTypes(
                    Table.FromList(
                      List.Dates(
                        Date.AddYears(var_PFFD, + 0), 
                        Number.From(var_PFFD - Date.AddYears(var_PFFD, - 1)), 
                        #duration(1, 0, 0, 0)
                      ), 
                      Splitter.SplitByNothing()
                    ), 
                    {{"Column1", type date}}
                  ), 
                  {{"Column1", "DateFY"}}
                ), 
                "Index", 
                1, 
                1
              ), 
              {"Index"}, 
              "Table", 
              JoinKind.LeftOuter
            ), 
            "Table", 
            {"DateFY"}, 
            {"PrevDateFY"}
          ), 
          each [DateFY] <= var_CurrentDate
        )[PrevDateFY]
      ), 
      col_isPrevFYTD = Table.AddColumn(
        col_isPrevYTD, 
        "IsPFYTD", 
        each 
          if [Fiscal CurrYearOffset] = - 1 and List.Contains(list_PrevFiscalYearDates, [Date]) then
            true
          else
            false, 
        type logical
      ), 
      col_isPrevAYTD = Table.AddColumn(
        col_isPrevFYTD, 
        "IsPAYTD", 
        each if [Academic CurrYearOffset] = - 1 then true else false, 
        type logical
      ), 
      col_NetWorkDays = 
        if AddRelativeNetWorkdays = true then
          Table.AddColumn(
            col_isPrevAYTD, 
            "Relative Networkdays", 
            each fxNETWORKDAYS(StartDate, [Date], Holidays), 
            type number
          )
        else
          col_isPrevAYTD, 
      fxNETWORKDAYS = (StartDate, EndDate, optional Holidays as list) =>
        let
          list_Dates = List.Dates(StartDate, Number.From(EndDate - StartDate) + 1, Duration.From(1)), 
          DeleteHolidays = 
            if Holidays = null then
              list_Dates
            else
              List.Difference(list_Dates, List.Transform(Holidays, Date.From)), 
          DeleteWeekends = List.Select(DeleteHolidays, each Date.DayOfWeek(_, Day.Monday) < 5), 
          CountDays = List.Count(DeleteWeekends)
        in
          CountDays, 
      cols_RemoveToday = Table.RemoveColumns(
        if EndDate < var_CurrentDate then
          Table.SelectRows(col_NetWorkDays, each ([Date] <> var_CurrentDate))
        else
          col_NetWorkDays, 
        {"DayYearNUM", "FiscalFirstDate"}
      ), 
      cols_Format = Table.TransformColumnTypes(
        cols_RemoveToday, 
        {
          {"YearNUM", Int64.Type}, 
          {"QuarterNUM", Int64.Type}, 
          {"MonthNUM", Int64.Type}, 
          {"DayMonthNUM", Int64.Type}, 
          {"DateINT", Int64.Type}, 
          {"DayWeekNUM", Int64.Type}, 
          {"ISO CurrYearOffset", Int64.Type}, 
          {"ISO QuarterYearINT", Int64.Type}, 
          {"ISO CurrQuarterOffset", Int64.Type}, 
          {"Week Number", Int64.Type}, 
          {"WeekYearINT", Int64.Type}, 
          {"MonthYearINT", Int64.Type}, 
          {"QuarterYearINT", Int64.Type}, 
          {"FiscalQuarterYearINT", Int64.Type}, 
          {"FiscalPeriodNUM", Int64.Type}, 
          {"FiscalPeriodYearINT", Int64.Type}, 
          {"CurrWeekOffset", Int64.Type}, 
          {"CurrMonthOffset", Int64.Type}, 
          {"CurrQuarterOffset", Int64.Type}, 
          {"CurrYearOffset", Int64.Type}, 
          {"Fiscal CurrYearOffset", Int64.Type}, 
          {"FiscalWeekYearINT", Int64.Type}
        }
      ), 
      cols_Reorder = Table.ReorderColumns(
        cols_Format, 
        {
          "Date", 
          "YearNUM", 
          "CurrYearOffset", 
          "isYearComplete", 
          "QuarterNUM", 
          "Quarter", 
          "Start of Quarter", 
          "End of Quarter", 
          "Quarter & Year", 
          "QuarterYearINT", 
          "CurrQuarterOffset", 
          "isQuarterComplete", 
          "MonthNUM", 
          "Start of Month", 
          "End of Month", 
          "Month & Year", 
          "MonthYearINT", 
          "CurrMonthOffset", 
          "isMonthComplete", 
          "Month Name", 
          "Month Short", 
          "Month Initial", 
          "DayMonthNUM", 
          "Week Number", 
          "Start of Week", 
          "End of Week", 
          "Week & Year", 
          "WeekYearINT", 
          "CurrWeekOffset", 
          "WeekCompleted", 
          "DayWeekNUM", 
          "Day of Week Name", 
          "Day Initial", 
          "DateINT", 
          "CurrDayOffset", 
          "IsAfterToday", 
          "IsWeekDay", 
          "IsHoliday", 
          "IsBusinessDay", 
          "Day Type", 
          "ISO Year", 
          "ISO CurrYearOffset", 
          "ISO QuarterNUM", 
          "ISO Quarter", 
          "ISO Quarter & Year", 
          "ISO QuarterYearINT", 
          "ISO CurrQuarterOffset", 
          "Fiscal Year", 
          "Fiscal CurrYearOffset", 
          "Fiscal Quarter", 
          "FiscalQuarterYearINT", 
          "FiscalPeriodNUM", 
          "Fiscal Period", 
          "FiscalPeriodYearINT", 
          "DateFW", 
          "Fiscal Week Number", 
          "Fiscal Week", 
          "FiscalWeekYearINT", 
          "IsCurrentFY", 
          "IsCurrentFQ", 
          "IsCurrentFP", 
          "IsCurrentFW", 
          "IsPYTD", 
          "IsPFYTD"
        }
      ), 
      AYCols = {
        "Academic Year", 
        "Academic Quarter", 
        "AcademicQuarterYearINT", 
        "AcademicPeriodNUM", 
        "Academic Period", 
        "AcademicPeriodYearINT", 
        "Academic CurrYearOffset", 
        "IsCurrentAQ", 
        "IsCurrentAP", 
        "IsPAYTD", 
        "IsCurrentAY", 
        "AcademicFirstDate"
      }, 
      FYCols = {
        "ISO QuarterNUM", 
        "Fiscal Year", 
        "Fiscal Quarter", 
        "FiscalQuarterYearINT", 
        "FiscalPeriodNUM", 
        "Fiscal Period", 
        "FiscalPeriodYearINT", 
        "DateFW", 
        "Fiscal Week Number", 
        "Fiscal Week", 
        "FiscalWeekYearINT", 
        "Fiscal CurrYearOffset", 
        "IsCurrentFQ", 
        "IsCurrentFP", 
        "IsCurrentFW", 
        "IsPFYTD", 
        "IsCurrentFY"
      }, 
      AllCols = List.Union({FYCols, AYCols}), 
      ListCols = 
        if var_FYAYTest then
          Table.RemoveColumns(cols_Reorder, AllCols)
        else if var_AYLogicTest then
          Table.RemoveColumns(cols_Reorder, AYCols)
        else if var_FYLogicTest then
          Table.RemoveColumns(cols_Reorder, FYCols)
        else
          Table.RemoveColumns(
            cols_Reorder, 
            {"DateFW", "FiscalWeekYearINT", "ISO QuarterNUM" /* "FiscalPeriodNUM",  */                         }
          )
    in
      ListCols

    , 

// ------------------------------------------------------------------     
/*
  invokeFunction = (
    StartYearNUM as number, 
    EndYearNUM as number, 
    optional FYStartMonthNum as number, 
    optional AYStartMonthNum as number, 
    optional Holidays as list, 
    optional WDStartNum as number, 
    optional AddRelativeNetWorkdays as logical
  ) as table =>
*/

// 3.0: change parameter metadata here
      fnType = type function (

        // 3.0.1: first parameter
        StartYearNUM as (
          type number
            meta 
            [
              Documentation.FieldCaption     = " Select Query: #(lf) Or input previous step ", 
              Documentation.FieldDescription = " Select Query/Step: #(cr,lf) Or input previous step ",
              Documentation.SampleValues = {"Table/Step"}
            ]
        ),

        // 3.0.2: second parameter
        EndYearNUM as (
          type number
            meta 
            [
              Documentation.FieldCaption     = " Select Query: #(lf) Or input previous step ", 
              Documentation.FieldDescription = " Select Query/Step: #(cr,lf) Or input previous step ",
              Documentation.SampleValues = {"Table/Step"}
            ]
        ),
        // 3.0.3: third parameter
        optional FYStartMonthNum as (
          type number
            meta 
            [
              Documentation.FieldCaption     = " Select Query: #(lf) Or input previous step ", 
              Documentation.FieldDescription = " Select Query/Step: #(cr,lf) Or input previous step ",
              Documentation.SampleValues = {"Table/Step"}
            ]
        )
       
        // 3.0.4: fourth parameter
        ,
         optional AYStartMonthNum as (
          type number
            meta 
            [
              Documentation.FieldCaption     = " Choose Separator Type ", 
              Documentation.FieldDescription = " Recommended to use #(lf) forward slash / ", 
              Documentation.SampleValues    = {"123"}
            ]
        )
  // 3.0.5: fifth parameter
        ,
         optional Holidays as (
          type list
            meta 
            [
              Documentation.FieldCaption     = " Choose Separator Type ", 
              Documentation.FieldDescription = " Recommended to use #(lf) forward slash / ", 
              Documentation.SampleValues    = {"List"}
            ]
        )
  // 3.0.6: sixth parameter Week Start number
        ,
         optional WDStartNum as (
          type number
            meta 
            [
              Documentation.FieldCaption     = " Choose Separator Type ", 
              Documentation.FieldDescription = " Recommended to use #(lf) forward slash / ", 
              Documentation.SampleValues    = {"123"}
            ]
        )
  // 3.0.7: seventh parameter AddRelativeNetWorkdays
        ,
         optional AddRelativeNetWorkdays as (
          type logical
            meta 
            [
              Documentation.FieldCaption     = " Choose Separator Type ", 
              Documentation.FieldDescription = " Recommended to use #(lf) forward slash / ", 
              Documentation.SampleValues    = {"True/False"}
            ]
        )
   // 3.1: parameter return type   
    ) as list,
// ------------------------------------------------------------------
// 4.0: edit function metadata here
      documentation = 
      [  

          Documentation.Name = " fnDates ", 
          Documentation.Description = " Dates Table with Fiscal and Academic Year ", 
          Documentation.LongDescription = " Dates Table with Fiscal and Academic Year ", 
          Documentation.Category = " Calendar Category ", 
          Documentation.Source = "  PBIQUERYOUS  ", 
          Documentation.Version = " 1.0 ", 
          Documentation.Author = " Imran Haq ", 
          Documentation.Examples = 
          {
            [
            Description = "  Dates Table with Fiscal and Academic Year   ",
            Code    = " fn_Dates_v3( 2021, 2023, 4,8, null, null ) ", 
            Result  = 
"
 1. Input paramaters
 2. Invoke function
 
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
      Value.ReplaceType(invokeFunction, fnType)
    in
// ------------------------------------------------------------------
// select one of the above steps and paste below
      parameterDocumentation      /* <-- Choose final documentation type */
      
in
  customFunction
  
  ```
