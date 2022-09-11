# fxDates_Dev
## fxDates M-code for Debugging

```C#
let
  
 //-- Debug
  CalendarYearStart = 2021, 
  CalendarYearEnd = 2022, 
  FiscalStartDate = #date(2021, 8, 1), 
  Holidays = null, 
  WDStartNum = 1, 



//-- fnParameters
/* 
    Source = let
    fnDateTable = (
        CalendarYearStart as number, 
        CalendarYearEnd as number, 
        optional FiscalStartDate as date, 
        optional Holidays as list, 
        optional WDStartNum as number
      ) as table => 
      
*/



  // QUERY START HERE
  StartDate = #date(CalendarYearStart, 1, 1), 
  EndDate = #date(CalendarYearEnd, 12, 31), 
  FiscalDate = if FiscalStartDate = null then StartDate else FiscalStartDate, 
  FYStartMonthNum = 8, 
  FYStartDate = Date.FromText(
    "1-" & Text.From(Date.Month(FiscalDate)) & "-" & Text.From(Date.Year(FiscalDate))
  ), 
  FYEndDate = Date.AddDays(Date.AddYears(FYStartDate, 1), - 1), 
  // ProperStartHere
  DateToday = DateTime.Date(DateTime.LocalNow()), 
  CompleteMTD = Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), 
  PrevMonth1 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), - 1)
  ), 
  LastMonth = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), 0)
  ), 
  ThisMonth = Date.EndOfMonth(DateTime.Date(DateTime.LocalNow())), 
  NextMonths1 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), 1)
  ), 
  NextMonths2 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), 2)
  ), 
  NextMonths3 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), 3)
  ), 
  FYStartMonth = 
    if List.Contains({1 .. 12}, Date.Month(FYStartDate)) then
      Date.Month(FYStartDate)
    else
      1, 
  StartOfWeekDayName = Text.Proper(Text.Start(Date.DayOfWeekName(#date(2021, 2, 1)), 3)), 
  WDStart = if List.Contains({0, 1}, WDStartNum) then WDStartNum else 1, 
  _todaysDate = Date.From(DateTime.FixedLocalNow()), 
  DayCount = Duration.Days(Duration.From(EndDate - StartDate)) + 1, 
  Source = List.Dates(StartDate, DayCount, #duration(1, 0, 0, 0)), 
  AddToday = if EndDate < _todaysDate then List.Combine({Source, {_todaysDate}}) else Source, 
  TableFromList = Table.RenameColumns( Table.TransformColumnTypes(Table.FromList(AddToday, Splitter.SplitByNothing()), {{"Column1", type date}}),  {{"Column1", "Date"}}), 
  dayMonthNUM = Table.AddColumn(TableFromList, "DayMonthNUM", each Date.Day([Date]), type number), 
  yearNUM = Table.AddColumn(dayMonthNUM, "YearNUM", each Date.Year([Date]), type number), 
  isToDate = Table.AddColumn(
    yearNUM, 
    "IsToDate", 
    each if [Date] <= _todaysDate then true else false, 
    type logical
  ), 
  isFuture = Table.AddColumn(
    isToDate, 
    "IsFuture", 
    each if [Date] > _todaysDate then true else false, 
    type logical
  ), 
  yearOffset = Table.AddColumn(
    isFuture, 
    "YearOffset", 
    each Date.Year([Date]) - Date.Year(Date.From(_todaysDate)), 
    type number
  ), 
  isYearComplete = Table.AddColumn(
    yearOffset, 
    "IsYearComplete", 
    each Date.EndOfYear([Date]) < Date.From(Date.EndOfYear(_todaysDate)), 
    type logical
  ), 
  quarterNUM = Table.AddColumn(
    isYearComplete, 
    "QuarterNUM", 
    each Date.QuarterOfYear([Date]), 
    type number
  ), 
  calendarQuarter = Table.AddColumn(
    quarterNUM, 
    "Quarter", 
    each "Q" & Text.From(Date.QuarterOfYear([Date])), 
    type text
  ), 
  quarter_Year = Table.AddColumn(
    calendarQuarter, 
    "Quarter & Year", 
    each "Q" & Number.ToText([QuarterNUM]) & " " & Text.End(Number.ToText([YearNUM]), 2), 
    type text
  ), 
  quarter_YearINT = Table.AddColumn(
    // Quarter and Year as INTEGER
    quarter_Year, 
    "QuarterYearINT", 
    each [YearNUM] * 10000 + [QuarterNUM] * 100, 
    type number
  ), 
  quarterOFFSET = Table.AddColumn(
    quarter_YearINT, 
    "QuarterOFFSET", 
    each ((4 * Date.Year([Date])) + Date.QuarterOfYear([Date]))
      - ((4 * Date.Year(Date.From(_todaysDate))) + Date.QuarterOfYear(Date.From(_todaysDate))), 
    type number
  ), 
  isQuarterComplete = Table.AddColumn(
    quarterOFFSET, 
    "isQuarterComplete", 
    each Date.EndOfQuarter([Date]) < Date.From(Date.EndOfQuarter(_todaysDate)), 
    type logical
  ), 
  monthNUM = Table.AddColumn(
    isQuarterComplete, 
    "MonthNUM", 
    each Date.Month([Date]), 
    type number
  ), 
  monthNAME = Table.AddColumn(
    monthNUM, 
    "Month", 
    each Text.Proper(Date.ToText([Date], "MMMM")), 
    type text
  ), 
  monthABV = Table.AddColumn(
    monthNAME, 
    "Mnth", 
    each try Text.Proper(Text.Start([Month], 3)) otherwise Text.Proper([Month]), 
    type text
  ), 
  monthINITIAL = Table.AddColumn(
    monthABV, 
    "Month Initial", 
    each Text.Proper(Text.Start([Month], 1))
      & Text.Repeat(Character.FromNumber(8203), [MonthNUM]), 
    type text
  ), 
  month_Year = Table.AddColumn(
    monthINITIAL, 
    "Month & Year", 
    each [Mnth] & " " & Text.End(Number.ToText([YearNUM]), 2), 
    type text
  ), 
  month_YearINT = Table.AddColumn(
    month_Year, 
    "MonthYearINT", 
    each [YearNUM] * 10000 + [MonthNUM] * 100, 
    type number
  ), 
  monthOFFSET = Table.AddColumn(
    month_YearINT, 
    "MonthOFFSET", 
    each ((12 * Date.Year([Date])) + Date.Month([Date]))
      - ((12 * Date.Year(Date.From(_todaysDate))) + Date.Month(Date.From(_todaysDate))), 
    type number
  ), 
  isMonthComplete = Table.AddColumn(
    monthOFFSET, 
    "IsMonthComplete", 
    each Date.EndOfMonth([Date]) < Date.From(Date.EndOfMonth(_todaysDate)), 
    type logical
  ), 
  monthStart = Table.AddColumn(
    isMonthComplete, 
    "MonthStart", 
    each Date.StartOfMonth([Date]), 
    type date
  ), 
  monthEnd = Table.AddColumn(monthStart, "MonthEnd", each Date.EndOfMonth([Date]), type date), 
  dateINT = Table.AddColumn(
    monthEnd, 
    "DateINT", 
    each [YearNUM] * 10000 + [MonthNUM] * 100 + [DayMonthNUM], 
    type number
  ), 
  day_YearNUM = Table.AddColumn(dateINT, "DayOfYear", each Date.DayOfYear([Date]), Int64.Type), 
  dayNUM = Table.AddColumn(
    day_YearNUM, 
    "DayNUM", 
    each Date.DayOfWeek([Date]) + WDStart, 
    Int64.Type
  ), 
  dayNAME = Table.AddColumn(
    dayNUM, 
    "DayNAME", 
    each Text.Proper(Date.ToText([Date], "dddd")), 
    type text
  ), 
  dayINITIAL = Table.AddColumn(
    dayNAME, 
    "Weekday Initial", 
    each Text.Proper(Text.Start([DayNAME], 1))
      & Text.Repeat(Character.FromNumber(8203), [DayNUM]), 
    type text
  ), 
  isoWeekNUM = Table.AddColumn(
    dayINITIAL, 
    "ISOWeekNUM", 
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
  isoYearNUM = Table.AddColumn(
    isoWeekNUM, 
    "ISOYearNUM", 
    each Date.Year(Date.AddDays(Date.StartOfWeek([Date], Day.Monday), 3)), 
    Int64.Type
  ), 
  dateSortBUFF = Table.Buffer(
    Table.Sort(Table.Distinct(isoYearNUM[[ISOYearNUM], [DateINT]]), {{"DateINT", Order.Descending}})
  ), 
  isoQtrNUM = Table.AddColumn(
    isoYearNUM, 
    "ISOQuarterNUM", 
    each 
      if [ISOWeekNUM] > 39 then
        4
      else if [ISOWeekNUM] > 26 then
        3
      else if [ISOWeekNUM] > 13 then
        2
      else
        1, 
    Int64.Type
  ), 
  isoQtr = Table.AddColumn(
    isoQtrNUM, 
    "ISO Quarter", 
    each "Q" & Number.ToText([ISOQuarterNUM]), 
    type text
  ), 
  isoQtr_Year = Table.AddColumn(
    isoQtr, 
    "ISO Quarter & Year", 
    each "Q" & Number.ToText([ISOQuarterNUM]) & " " & Text.End(Number.ToText([ISOYearNUM]), 2), 
    type text
  ), 
  isoQtr_YearINT = Table.AddColumn(
    isoQtr_Year, 
    "ISOQuarterYearINT", 
    each [ISOYearNUM] * 10000 + [ISOQuarterNUM] * 100, 
    type number
  ), 
  // InsertISOday = Table.AddColumn(InsertISOqNy, "ISO Day of Year", (OT) => Table.RowCount( Table.SelectRows( BufferTable, (IT) => IT[DateInt] <= OT[DateInt] and IT[ISO Year] = OT[ISO Year])),  Int64.Type),
  calendarWeek_Year = Table.AddColumn(
    isoQtr_YearINT, 
    "Week & Year", 
    each Text.From([ISOYearNUM]) & "-" & Text.PadStart(Text.From([ISOWeekNUM]), 2, "0"), 
    type text
  ), 
  week_YearINT = Table.AddColumn(
    calendarWeek_Year, 
    "WeekYearINT", 
    each [ISOYearNUM] * 10000 + [ISOWeekNUM] * 100, 
    Int64.Type
  ), 
  weekOFFSET = Table.AddColumn(
    week_YearINT, 
    "WeekOFFSET", 
    each (
      Number.From(Date.StartOfWeek([Date], Day.Monday))
        - Number.From(Date.StartOfWeek(_todaysDate, Day.Monday))
    )
      / 7, 
    type number
  ), 
  isWeekComplete = Table.AddColumn(
    weekOFFSET, 
    "isWeekComplete", 
    each Date.EndOfWeek([Date], Day.Monday) < Date.From(Date.EndOfWeek(_todaysDate, Day.Monday)), 
    type logical
  ), 
  weekStart = Table.AddColumn(
    isWeekComplete, 
    "WeekStart", 
    each Date.StartOfWeek([Date], Day.Monday), 
    type date
  ), 
  weekEnd = Table.AddColumn(
    weekStart, 
    "WeekEnd", 
    each Date.EndOfWeek([Date], Day.Monday), 
    type date
  ), 
  fiscalYear = Table.AddColumn(
    weekEnd, 
    "Fiscal Year", 
    each "FY"
      & (
        if [MonthNUM] >= FYStartMonth then
          Text.PadEnd(Text.End(Text.From([YearNUM] + 0), 2), 2, "0")
        else
          Text.PadEnd(Text.End(Text.From([YearNUM] - 1), 2), 2, "0")
      ), 
    type text
  ), 
  fiscalQuarter = Table.AddColumn(
    fiscalYear, 
    "Fiscal Quarter", 
    each "FQ"
      & Text.From(Number.RoundUp(Date.Month(Date.AddMonths([Date], - (FYStartMonth - 1))) / 3)), 
    type text
  ), 
  fiscalQuarterINT = Table.AddColumn(
    fiscalQuarter, 
    "FiscalQuarterYearINT", 
    each (if [MonthNUM] >= FYStartMonth then [YearNUM] + 1 else [YearNUM] + 0)
      * 10000 + Number.RoundUp(Date.Month(Date.AddMonths([Date], - (FYStartMonth - 1))) / 3)
      * 100, 
    type number
  ), 
  fiscalPeriodNUM = Table.AddColumn(
    fiscalQuarterINT, 
    "Fiscal Period", 
    each 
      if [MonthNUM] >= FYStartMonth then
        [MonthNUM] - (FYStartMonth - 1)
      else
        [MonthNUM] + (12 - FYStartMonth + 1), 
    type text
  ), 
  fiscalPeriodINT = Table.AddColumn(
    fiscalPeriodNUM, 
    "FiscalPeriodINT", 
    each (if [MonthNUM] >= FYStartMonth then [YearNUM] + 1 else [YearNUM])
      * 10000 + [Fiscal Period]
      * 100, 
    type number
  ), 
  varFiscalPeriodINT = fiscalPeriodINT, 
  fiscalDateStart = #date(Date.Year(StartDate) - 1, FYStartMonth, 1), 
  fiscalFirstDate = Table.AddColumn(
    varFiscalPeriodINT, 
    "FiscalFirstDay", 
    each 
      if Date.Month([Date]) < FYStartMonth then
        #date(Date.Year([Date]), FYStartMonth, 1)
      else
        #date(Date.Year([Date]) + 1, FYStartMonth, 1)
  ), 
  fiscalYearDateRange = Table.Buffer(
    Table.ExpandTableColumn(
      Table.ExpandTableColumn(
        Table.AddColumn(
          Table.Group(
            Table.Group(
              Table.AddColumn(
                Table.AddColumn(
                  Table.RenameColumns(
                    Table.TransformColumnTypes(
                      Table.FromList(
                        {Number.From(fiscalDateStart) .. Number.From(EndDate)}, 
                        Splitter.SplitByNothing()
                      ), 
                      {{"Column1", type date}}
                    ), 
                    {{"Column1", "Date"}}
                  ), 
                  "FiscalFirstDay", 
                  each 
                    if Date.Month([Date]) < FYStartMonth then
                      #date(Date.Year([Date]), FYStartMonth, 1)
                    else
                      #date(Date.Year([Date]) + 1, FYStartMonth, 1)
                ), 
                "FWStartDate", 
                each Date.AddYears(Date.StartOfWeek([Date], Day.Monday), 1)
              ), 
              {"FiscalFirstDay", "FWStartDate"}, 
              {
                {
                  "AllRows", 
                  each _, 
                  type table [Date = nullable date, FiscalFirstDay = date, FWStartDate = date]
                }
              }
            ), 
            {"FiscalFirstDay"}, 
            {
              {
                "AllRows2", 
                each _, 
                type table [FiscalFirstDay = date, FWStartDate = date, AllRows = table]
              }
            }
          ), 
          "Custom", 
          each Table.AddIndexColumn([AllRows2], "FY Week", 1, 1)
        )[[Custom]], 
        "Custom", 
        {"FiscalFirstDay", "FWStartDate", "AllRows", "FY Week"}, 
        {"FiscalFirstDay", "FWStartDate", "AllRows", "FY Week"}
      ), 
      "AllRows", 
      {"Date"}, 
      {"Date"}
    )[[Date], [FY Week]]
  ), 
  mergeFiscalYear_Week = Table.NestedJoin(
    fiscalFirstDate, 
    {"Date"}, 
    fiscalYearDateRange, 
    {"Date"}, 
    "AddFYWeek", 
    JoinKind.LeftOuter
  ), 
  expandFiscalWeek = Table.TransformColumnTypes(
    Table.ExpandTableColumn(mergeFiscalYear_Week, "AddFYWeek", {"FY Week"}, {"FiscalWeekNUM"}), 
    {{"FiscalWeekNUM", Int64.Type}}
  ), 
  fiscalWeek_Year = Table.AddColumn(
    expandFiscalWeek, 
    "Fiscal Year & Week", 
    each 
      if FYStartMonth = 1 then
        [#"Week & Year"]
      else if Date.Month([Date]) < FYStartMonth then
        Text.From(Date.Year([Date])) & "-" & Text.PadStart(Text.From([FiscalWeekNUM]), 2, "0")
      else
        Text.From(Date.Year([Date]) + 1) & "-" & Text.PadStart(Text.From([FiscalWeekNUM]), 2, "0"), 
    type text
  ), 
  fiscalWeek_YearINT = Table.AddColumn(
    fiscalWeek_Year, 
    "FiscalWeekYearINT", 
    each 
      if FYStartMonth = 1 then
        [WeekYearNUM]
      else
        (if Date.Month([Date]) < FYStartMonth then Date.Year([Date]) else Date.Year([Date]) + 1)
          * 10000 + [FiscalWeekNUM]
          * 100, 
    Int64.Type
  ), 
  isAfterToday = Table.AddColumn(
    fiscalWeek_YearINT, 
    "IsAfterToday", 
    each not ([Date] <= Date.From(_todaysDate)), 
    type logical
  ), 
  isWorkDay = Table.AddColumn(
    isAfterToday, 
    "IsWorkDay", 
    each if Date.DayOfWeek([Date], Day.Monday) > 4 then false else true, 
    type logical
  ), 
  isHoliday = Table.AddColumn(
    isWorkDay, 
    "IsHoliday", 
    each if Holidays = null then null else List.Contains(Holidays, [Date]), 
    if Holidays = null then type text else type logical
  ), 
  isBusinessDay = Table.AddColumn(
    isHoliday, 
    "IsBusinessDay", 
    each if [IsWorkDay] = true and [IsHoliday] <> true then true else false, 
    type logical
  ), 
  dayType = Table.AddColumn(
    isBusinessDay, 
    "Day Type", 
    each 
      if [IsHoliday] = true then
        "Holiday"
      else if [IsWorkDay] = false then
        "Weekend"
      else if [IsWorkDay] = true then
        "Weekday"
      else
        null, 
    type text
  ), 
  currentDateRecord = Table.SelectRows(dayType, each [Date] = _todaysDate), 
  CurrentISOyear = currentDateRecord{0}[ISOYearNUM], 
  CurrentISOqtr = currentDateRecord{0}[ISOQuarterNUM], 
  CurrentYear = currentDateRecord{0}[YearNUM], 
  CurrentMonth = currentDateRecord{0}[MonthNUM], 
  CurrentFiscalFirstDay = currentDateRecord{0}[FiscalFirstDay], 
  PrevFiscalFirstDay = Date.AddYears(CurrentFiscalFirstDay, - 1), 
  CurrentFQ = currentDateRecord{0}[FiscalQuarterYearINT], 
  CurrentFP = currentDateRecord{0}[FiscalPeriodINT], 
  MonthAdd1 = currentDateRecord{0}[FiscalPeriodINT] + 100, 
  MonthAdd2 = currentDateRecord{0}[FiscalPeriodINT] + 200, 
  MonthAdd3 = currentDateRecord{0}[FiscalPeriodINT] + 300, 
  DateAdd1 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), 1)
  ), 
  DateAdd2 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), 2)
  ), 
  DateAdd3 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), 3)
  ), 
  PrevMonthDate = Table.AddColumn(
    currentDateRecord, 
    "PrevMDate", 
    each Date.EndOfMonth(Date.AddMonths([MonthEnd], - 1)), 
    type date
  ), 
  PrevMonth = Table.AddColumn(
    PrevMonthDate, 
    "PMonthOfYear", 
    each Date.Month([PrevMDate]), 
    type number
  ), 
  PrevFP = Table.AddColumn(
    PrevMonth, 
    "PrevFP", 
    each 
      if [PMonthOfYear] >= FYStartMonth then
        [PMonthOfYear] - (FYStartMonth - 1)
      else
        [PMonthOfYear] + (12 - FYStartMonth + 1), 
    type text
  ), 
  PFPeriodnYear = Table.AddColumn(
    PrevFP, 
    "PFPeriodnYear", 
    each (if [PMonthOfYear] >= FYStartMonth then [Year] + 1 else [YearNUM]) * 10000 + [PrevFP] * 100, 
    type number
  ), 
  CurrentFW = currentDateRecord{0}[FiscalWeekYearINT], 
  AddISOQtrOffset = Table.AddColumn(
    dayType, 
    "ISOQuarterOFFSET", 
    each ((4 * [ISOYearNUM]) + [ISOQuarterNUM]) - ((4 * CurrentISOyear) + CurrentISOqtr), 
    type number
  ), 
  AddISOYrOffset = Table.AddColumn(
    AddISOQtrOffset, 
    "ISO YearOffset", 
    each [ISOYearNUM] - CurrentISOyear, 
    type number
  ), 
  AddFYoffset = Table.AddColumn(
    AddISOYrOffset, 
    "FiscalYearOFFSET", 
    each try
      (if [MonthNUM] >= FYStartMonth then [YearNUM] + 1 else [YearNUM])
        - (if CurrentMonth >= FYStartMonth then CurrentYear + 1 else CurrentYear)
    otherwise
      null, 
    type number
  ), 
  AddIsCurrentFQ = Table.AddColumn(
    AddFYoffset, 
    "IsCurrentFiscalQuarter", 
    each if [FiscalQuarterYearINT] = CurrentFQ then true else false, 
    type logical
  ), 
  AddIsCurrentFW = Table.AddColumn(
    AddIsCurrentFQ, 
    "IsCurrentFW", 
    each if [FiscalWeekYearINT] = CurrentFW then true else false, 
    type logical
  ), 
  isPrevYTD = Table.AddColumn(
    AddIsCurrentFW, 
    "IsPYTD", 
    each 
      if CurrentYear - 1 = [YearNUM] and [DayOfYear] <= currentDateRecord{0}[DayOfYear] then
        true
      else
        false, 
    type logical
  ), 
  ListPrevFYDates = List.Buffer(
    Table.SelectRows(
      Table.ExpandTableColumn(
        Table.NestedJoin(
          Table.AddIndexColumn(
            Table.RenameColumns(
              Table.TransformColumnTypes(
                Table.FromList(
                  List.Dates(
                    PrevFiscalFirstDay, 
                    Number.From(CurrentFiscalFirstDay - PrevFiscalFirstDay), 
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
          Table.AddIndexColumn(
            Table.RenameColumns(
              Table.TransformColumnTypes(
                Table.FromList(
                  List.Dates(
                    Date.AddYears(PrevFiscalFirstDay, - 1), 
                    Number.From(PrevFiscalFirstDay - Date.AddYears(PrevFiscalFirstDay, - 1)), 
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
      each [DateFY] <= _todaysDate
    )[PrevDateFY]
  ), 
  isPrevFYTD = Table.AddColumn(
    isPrevYTD, 
    "IsPFYTD", 
    each if [FiscalYearOFFSET] = - 1 and List.Contains(ListPrevFYDates, [Date]) then true else false, 
    type logical
  ), 
  removeToday = Table.RemoveColumns(
    if EndDate < _todaysDate then
      Table.SelectRows(isPrevFYTD, each ([Date] <> _todaysDate))
    else
      isPrevFYTD, 
    {"DayOfYear", "FiscalFirstDay"}
  ),
  FORMAT_COLS = Table.TransformColumnTypes(
  removeToday,
  {
    {"Date", type date},
    {"DayMonthNUM", Int64.Type},
    {"YearNUM", Int64.Type},
    {"IsToDate", type logical},
    {"IsFuture", type logical},
    {"YearOffset", Int64.Type},
    {"IsYearComplete", type logical},
    {"QuarterNUM", Int64.Type},
    {"Quarter", type text},
    {"Quarter & Year", type text},
    {"QuarterYearINT", Int64.Type},
    {"QuarterOFFSET", Int64.Type},
    {"isQuarterComplete", type logical},
    {"MonthNUM", Int64.Type},
    {"Month", type text},
    {"Mnth", type text},
    {"Month Initial", type text},
    {"Month & Year", type date},
    {"MonthYearINT", Int64.Type},
    {"MonthOFFSET", Int64.Type},
    {"IsMonthComplete", type logical},
    {"MonthStart", type date},
    {"MonthEnd", type date},
    {"DateINT", Int64.Type},
    {"DayNUM", Int64.Type},
    {"DayNAME", type text},
    {"Weekday Initial", type text},
    {"ISOWeekNUM", Int64.Type},
    {"ISOYearNUM", Int64.Type},
    {"ISOQuarterNUM", Int64.Type},
    {"ISO Quarter", type text},
    {"ISO Quarter & Year", type text},
    {"ISOQuarterYearINT", Int64.Type},
    {"Week & Year", type text},
    {"WeekYearINT", Int64.Type},
    {"WeekOFFSET", Int64.Type},
    {"isWeekComplete", type logical},
    {"WeekStart", type date},
    {"WeekEnd", type date},
    {"Fiscal Year", type text},
    {"Fiscal Quarter", type text},
    {"FiscalQuarterYearINT", Int64.Type},
    {"Fiscal Period", Int64.Type},
    {"FiscalPeriodINT", Int64.Type},
    {"FiscalWeekNUM", Int64.Type},
    {"Fiscal Year & Week", type text},
    {"FiscalWeekYearINT", Int64.Type},
    {"IsAfterToday", type logical},
    {"IsWorkDay", type logical},
    {"IsHoliday", type text},
    {"IsBusinessDay", type logical},
    {"Day Type", type text},
    {"ISOQuarterOFFSET", Int64.Type},
    {"ISO YearOffset", Int64.Type},
    {"FiscalYearOFFSET", Int64.Type},
    {"IsCurrentFiscalQuarter", type logical},
    {"IsCurrentFW", type logical},
    {"IsPYTD", type logical},
    {"IsPFYTD", type logical}
  }
), 
  isCurrentFiscalPeriod = Table.AddColumn(
    FORMAT_COLS, 
    "IsCurrentFiscalPeriod", 
    each if [FiscalPeriodINT] = CurrentFP then true else false, 
    type logical
  ), 
  isToday = Table.AddColumn(
    isCurrentFiscalPeriod, 
    "IsToday", 
    each if [Date] = DateToday then true else false, 
    type logical
  ), 
  isForecast1 = Table.AddColumn(
    isToday, 
    "IsForecastAdd1", 
    each if [MonthOFFSET] = 1 then true else false, 
    type logical
  ), 
  isForecast2 = Table.AddColumn(
    isForecast1, 
    "IsForecastAdd2", 
    each if [MonthOFFSET] = 2 then true else false, 
    type logical
  ), 
  isForecast3 = Table.AddColumn(
    isForecast2, 
    "IsForecastAdd3", 
    each if [MonthOFFSET] = 3 then true else false, 
    type logical
  ), 
  isPrevMonth1 = Table.AddColumn(
    isForecast3, 
    "IsPrevMonth1", 
    each if [MonthEnd] = PrevMonth1 then true else false, 
    type logical
  ), 
  isLastMonth = Table.AddColumn(
    isPrevMonth1, 
    "IsLastMonth", 
    each if [MonthOFFSET] = -1 then true else false, 
    type logical
  ), 
  isThisMonth = Table.AddColumn(
    isLastMonth, 
    "IsThisMonth", 
    each if [MonthEnd] = ThisMonth then true else false, 
    type logical
  ), 
  isCompleteMonth = Table.AddColumn(
    isThisMonth, 
    "IsCompleteMonth", 
    each if [MonthOFFSET] < 0 then true else false, 
    type logical
  ), 
  YTDAdd1 = Table.AddColumn(
    isCompleteMonth, 
    "YTDAdd1", 
    each if [MonthEnd] <= DateAdd1 then true else false, 
    type logical
  ), 
  YTDAdd2 = Table.AddColumn(
    YTDAdd1, 
    "YTDAdd2", 
    each if [MonthEnd] <= DateAdd2 then true else false, 
    type logical
  ), 
  YTDAdd3 = Table.AddColumn(
    YTDAdd2, 
    "YTDAdd3", 
    each if [MonthEnd] <= DateAdd3 then true else false, 
    type logical
  ), 
  FYend = Table.TransformColumnTypes(
    Table.AddColumn(
      YTDAdd3, 
      "fyEND", 
      each (
        if [MonthNUM] >= FYStartMonth then
          Text.PadEnd(Text.End(Text.From([YearNUM] + 1), 2), 2, "0")
        else
          Text.End(Text.From([YearNUM]), 2)
      ), 
      Int64.Type
    ), 
    {{"fyEND", Int64.Type}}
  ), 
  fyPeriod = Table.AddColumn(
    FYend, 
    "Period", 
    each Number.ToText(([fyEND] - 1)) & "-" & Number.ToText([fyEND]), 
    type text
  ), 
  IsCalendarYTD = Table.AddColumn(
    fyPeriod, 
    "IsCYTD", 
    each Date.IsInYearToDate([Date]), 
    type logical
  ), 
  IsCFY = Table.AddColumn(
    IsCalendarYTD, 
    "IsCFY", 
    each if [FiscalYearOFFSET] = 0 then true else false, 
    type logical
  ), 
  CalendarYear = Table.AddColumn(
    IsCFY, 
    "Calendar Year", 
    each "CY" & (Text.End(Text.From([YearNUM]), 2)), 
    type text
  ), 
  AddFiscalQuarternYR = Table.AddColumn(
    CalendarYear, 
    "Fiscal Quarter & Year", 
    each [Fiscal Quarter] & " " & Text.End([Fiscal Year], 2), 
    type text
  ), 
  LatestMTD = Table.AddColumn(
    AddFiscalQuarternYR, 
    "LatestMTD", 
    each if [IsCompleteMonth] = true then [Date] else null, 
    type date
  ), 
  MTDAdd1 = Table.AddColumn(
    LatestMTD, 
    "MTDAdd1", 
    each if [YTDAdd1] = true then [Date] else null, 
    type date
  ), 
  MTDAdd2 = Table.AddColumn(
    MTDAdd1, 
    "MTDAdd2", 
    each if [YTDAdd2] = true then [Date] else null, 
    type date
  ), 
  MTDAdd3 = Table.AddColumn(
    MTDAdd2, 
    "MTDAdd3", 
    each if [YTDAdd3] = true then [Date] else null, 
    type date
  ), 
  addFY_ = Table.AddColumn(
    MTDAdd3, 
    "FY_", 
    each 
      if [FiscalYearOFFSET] < 2 then
        [Fiscal Year]
      else if [FiscalYearOFFSET] >= 2 then
        List.Max(Table.SelectRows(Source, each ([FiscalYearOFFSET] = 2))[Fiscal Year]) & "+"
      else
        null, 
    type text
  ), 
  groupedQuarters = Table.Buffer(
    Table.Group(
      addFY_, 
      {"Fiscal Quarter & Year", "FiscalQuarterYearINT"}, 
      {{"QuarterDate", each List.Max([Date]), type nullable date}}
    )
  ), 
  mergeFiscalQtrDate = Table.NestedJoin(
    addFY_, 
    {"FiscalQuarterYearINT"}, 
    groupedQuarters, 
    {"FiscalQuarterYearINT"}, 
    "fnFQDate", 
    JoinKind.LeftOuter
  ), 
  fnQuarterEnd = Table.ExpandTableColumn(
    mergeFiscalQtrDate, 
    "fnFQDate", 
    {"QuarterDate"}, 
    {"QuarterEnd"}
  ),
  selectCols = Table.SelectColumns(
  fnQuarterEnd, 
  {
    "Date", 
    "YearNUM", 
    "Fiscal Year", 
    "Calendar Year", 
    "FY_", 
    "Period", 
    "Month", 
    "MonthNUM", 
    "Fiscal Period", 
    "Fiscal Quarter", 
    "Quarter", 
    "Fiscal Quarter & Year", 
    "Quarter & Year", 
    "QuarterEnd",
    "Month & Year", 
    "Fiscal Year & Week", 
    "IsToDate", 
    "IsFuture", 
    "YearOffset", 
    "IsYearComplete", 
    "QuarterNUM", 
    "QuarterYearINT", 
    "QuarterOFFSET", 
    "isQuarterComplete", 
    "MonthStart", 
    "MonthEnd", 
    "Mnth", 
    "MonthOFFSET", 
    "Month Initial", 
    "MonthYearINT", 
    "IsMonthComplete", 
    "WeekStart", 
    "WeekEnd", 
    "DayNAME", 
    "DayNUM", 
    "DateINT", 
    "Weekday Initial", 
    "Week & Year", 
    "WeekYearINT", 
    "WeekOFFSET", 
    "isWeekComplete", 
    "FiscalQuarterYearINT", 
    "FiscalPeriodINT", 
    "FiscalWeekNUM", 
    "FiscalWeekYearINT", 
    "IsAfterToday", 
    "IsWorkDay", 
    "IsHoliday", 
    "IsBusinessDay", 
    "Day Type", 
    "FiscalYearOFFSET", 
    "IsCurrentFiscalQuarter", 
    "IsCurrentFW", 
    "IsPYTD", 
    "IsPFYTD", 
    "IsCurrentFiscalPeriod", 
    "IsToday", 
    "IsForecastAdd1", 
    "IsForecastAdd2", 
    "IsForecastAdd3", 
    "IsPrevMonth1", 
    "IsLastMonth", 
    "IsThisMonth", 
    "IsCompleteMonth", 
    "YTDAdd1", 
    "YTDAdd2", 
    "YTDAdd3",
    "LatestMTD", 
    "MTDAdd1", 
    "MTDAdd2", 
    "MTDAdd3", 
    "DayMonthNUM", 
    "IsCYTD", 
    "IsCFY",
    "ISOWeekNUM", 
    "ISOYearNUM", 
    "ISOQuarterNUM", 
    "ISO Quarter", 
    "ISO Quarter & Year", 
    "ISOQuarterYearINT", 
    "ISOQuarterOFFSET", 
    "ISO YearOffset"
  }
)
in
  selectCols
```
