//function = fnDateTable
let
  Source =  // fnDateTableSTART                   
  
    let
      fnDateTable = (
        CalendarYearStart as number, 
        CalendarYearEnd as number, 
        optional FiscalStartDate as date, 
        optional Holidays as list, 
        optional WDStartNum as number
      ) as table =>
        // fnDateTableEND
        //QuerySTART
  let
  //QUERY START HERE                  
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
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 0)
  ),
  ThisMonth = Date.EndOfMonth(DateTime.Date(DateTime.LocalNow())),
  NextMonths1 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 1)
  ),
  NextMonths2 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 2)
  ),
  NextMonths3 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 3)
  ),
  FYStartMonth =
    if List.Contains({1 .. 12}, Date.Month(FYStartDate)) then
      Date.Month(FYStartDate)
    else
      1,
  StartOfWeekDayName = Text.Proper(Text.Start(Date.DayOfWeekName(#date(2021, 2, 1)), 3)),
  WDStart = if List.Contains({0, 1}, WDStartNum) then WDStartNum else 1,
  CurrentDate = Date.From(DateTime.FixedLocalNow()),
  DayCount = Duration.Days(Duration.From(EndDate - StartDate)) + 1,
  Source = List.Dates(StartDate, DayCount, #duration(1, 0, 0, 0)),
  AddToday = if EndDate < CurrentDate then List.Combine({Source, {CurrentDate}}) else Source,
  TableFromList = Table.FromList(AddToday, Splitter.SplitByNothing()),
  ChangedType = Table.TransformColumnTypes(TableFromList, {{"Column1", type date}}),
  RenamedColumns = Table.RenameColumns(ChangedType, {{"Column1", "Date"}}),
  AddYear = Table.AddColumn(RenamedColumns, "Year", each Date.Year([Date]), type number),
  AddIsToDate = Table.AddColumn(
    AddYear,
    "IsToDate",
    each if [Date] <= CurrentDate then true else false,
    type logical
  ),
  AddIsFuture = Table.AddColumn(
    AddIsToDate,
    "IsFuture",
    each if [Date] > CurrentDate then true else false,
    type logical
  ),
  AddYearOffset = Table.AddColumn(
    AddIsFuture,
    "YearOffset",
    each Date.Year([Date]) - Date.Year(Date.From(CurrentDate)),
    type number
  ),
  AddYearComplete = Table.AddColumn(
    AddYearOffset,
    "YearCompleted",
    each Date.EndOfYear([Date]) < Date.From(Date.EndOfYear(CurrentDate)),
    type logical
  ),
  AddQuarterN = Table.AddColumn(
    AddYearComplete,
    "QuarterOfYear",
    each Date.QuarterOfYear([Date]),
    type number
  ),
  AddQuarter = Table.AddColumn(
    AddQuarterN,
    "Quarter",
    each "Q" & Text.From(Date.QuarterOfYear([Date])),
    type text
  ),
  AddCalendarQtr = Table.AddColumn(
    AddQuarter,
    "Quarter & Year",
    each "Q" & Number.ToText([QuarterOfYear]) & " " & Text.End(Number.ToText([Year]), 2),
    type text
  ),
  AddQuarterYearN = Table.AddColumn(
    AddCalendarQtr,
    "QuarterYrN",
    each [Year] * 10000 + [QuarterOfYear] * 100,
    type number
  ),
  AddQuarterOffset = Table.AddColumn(
    AddQuarterYearN,
    "QuarterOffset",
    each ((4 * Date.Year([Date])) + Date.QuarterOfYear([Date]))
      - ((4 * Date.Year(Date.From(CurrentDate))) + Date.QuarterOfYear(Date.From(CurrentDate))),
    type number
  ),
  AddQuarterComplete = Table.AddColumn(
    AddQuarterOffset,
    "QuarterCompleted",
    each Date.EndOfQuarter([Date]) < Date.From(Date.EndOfQuarter(CurrentDate)),
    type logical
  ),
  AddMonthN = Table.AddColumn(
    AddQuarterComplete,
    "MonthOfYear",
    each Date.Month([Date]),
    type number
  ),
  AddDay = Table.AddColumn(AddMonthN, "DayOfMonth", each Date.Day([Date]), type number),
  AddMonth = Table.AddColumn(
    AddDay,
    "Month",
    each Text.Proper(Date.ToText([Date], "MMMM")),
    type text
  ),
  AddMnth = Table.AddColumn(
    AddMonth,
    "Mnth",
    each try Text.Proper(Text.Start([Month], 3)) otherwise Text.Proper([Month]),
    type text
  ),
  InsertMonthInitial = Table.AddColumn(
    AddMnth,
    "Month Initial",
    each Text.Proper(Text.Start([Month], 1))
      & Text.Repeat(Character.FromNumber(8203), [MonthOfYear]),
    type text
  ),
  AddMonthYear = Table.AddColumn(
    InsertMonthInitial,
    "Month & Year",
    each [Mnth] & " " & Text.End(Number.ToText([Year]), 2),
    type text
  ),
  AddMonthYearN = Table.AddColumn(
    AddMonthYear,
    "MonthYearN",
    each [Year] * 10000 + [MonthOfYear] * 100,
    type number
  ),
  AddMonthOffset = Table.AddColumn(
    AddMonthYearN,
    "MonthOffset",
    each ((12 * Date.Year([Date])) + Date.Month([Date]))
      - ((12 * Date.Year(Date.From(CurrentDate))) + Date.Month(Date.From(CurrentDate))),
    type number
  ),
  AddMonthComplete = Table.AddColumn(
    AddMonthOffset,
    "MonthComplete",
    each Date.EndOfMonth([Date]) < Date.From(Date.EndOfMonth(CurrentDate)),
    type logical
  ),
  AddMonthStart = Table.AddColumn(
    AddMonthComplete,
    "MonthStart",
    each Date.StartOfMonth([Date]),
    type date
  ),
  AddMonthEnd = Table.AddColumn(AddMonthStart, "MonthEnd", each Date.EndOfMonth([Date]), type date),
  AddDateInt = Table.AddColumn(
    AddMonthEnd,
    "DateInt",
    each [Year] * 10000 + [MonthOfYear] * 100 + [DayOfMonth],
    type number
  ),
  AddDayOfYear = Table.AddColumn(AddDateInt, "Day of Year", each Date.DayOfYear([Date]), Int64.Type),
  AddDayOfWeek = Table.AddColumn(
    AddDayOfYear,
    "DayOfWeek",
    each Date.DayOfWeek([Date]) + WDStart,
    Int64.Type
  ),
  AddDayName = Table.AddColumn(
    AddDayOfWeek,
    "DayOfWeekName",
    each Text.Proper(Date.ToText([Date], "dddd")),
    type text
  ),
  AddDayInitial = Table.AddColumn(
    AddDayName,
    "Weekday Initial",
    each Text.Proper(Text.Start([DayOfWeekName], 1))
      & Text.Repeat(Character.FromNumber(8203), [DayOfWeek]),
    type text
  ),
  AddWeekN = Table.AddColumn(
    AddDayInitial,
    "ISO Weeknumber",
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
  AddISOYear = Table.AddColumn(
    AddWeekN,
    "ISO Year",
    each Date.Year(Date.AddDays(Date.StartOfWeek([Date], Day.Monday), 3)),
    Int64.Type
  ),
  BufferTable = Table.Buffer(
    Table.Sort(Table.Distinct(AddISOYear[[ISO Year], [DateInt]]), {{"DateInt", Order.Descending}})
  ),
  AddISOQtrN = Table.AddColumn(
    AddISOYear,
    "ISO QuarterOfYear",
    each
      if [ISO Weeknumber] > 39 then
        4
      else if [ISO Weeknumber] > 26 then
        3
      else if [ISO Weeknumber] > 13 then
        2
      else
        1,
    Int64.Type
  ),
  AddISOQtr = Table.AddColumn(
    AddISOQtrN,
    "ISO Quarter",
    each "Q" & Number.ToText([ISO QuarterOfYear]),
    type text
  ),
  AddISOQtrYr = Table.AddColumn(
    AddISOQtr,
    "ISO Quarter & Year",
    each "Q" & Number.ToText([ISO QuarterOfYear]) & " " & Text.End(Number.ToText([ISO Year]), 2),
    type text
  ),
  AddISOQtrYrN = Table.AddColumn(
    AddISOQtrYr,
    "ISO QuarterYearN",
    each [ISO Year] * 10000 + [ISO QuarterOfYear] * 100,
    type number
  ),
  //InsertISOday = Table.AddColumn(InsertISOqNy, "ISO Day of Year", (OT) => Table.RowCount( Table.SelectRows( BufferTable, (IT) => IT[DateInt] <= OT[DateInt] and IT[ISO Year] = OT[ISO Year])),  Int64.Type),                                                                                                                                                                                                            
  AddCalendarWkYr = Table.AddColumn(
    AddISOQtrYrN,
    "Week & Year",
    each Text.From([ISO Year]) & "-" & Text.PadStart(Text.From([ISO Weeknumber]), 2, "0"),
    type text
  ),
  AddWeekYrN = Table.AddColumn(
    AddCalendarWkYr,
    "WeekYearN",
    each [ISO Year] * 10000 + [ISO Weeknumber] * 100,
    Int64.Type
  ),
  AddWeekOffset = Table.AddColumn(
    AddWeekYrN,
    "WeekOffset",
    each (
      Number.From(Date.StartOfWeek([Date], Day.Monday))
        - Number.From(Date.StartOfWeek(CurrentDate, Day.Monday))
    )
      / 7,
    type number
  ),
  AddWeekComplete = Table.AddColumn(
    AddWeekOffset,
    "WeekCompleted",
    each Date.EndOfWeek([Date], Day.Monday) < Date.From(Date.EndOfWeek(CurrentDate, Day.Monday)),
    type logical
  ),
  AddWeekStart = Table.AddColumn(
    AddWeekComplete,
    "WeekStart",
    each Date.StartOfWeek([Date], Day.Monday),
    type date
  ),
  AddWeekEnd = Table.AddColumn(
    AddWeekStart,
    "WeekEnd",
    each Date.EndOfWeek([Date], Day.Monday),
    type date
  ),
  AddFY = Table.AddColumn(
    AddWeekEnd,
    "Fiscal Year",
    each "FY"
      & (
        if [MonthOfYear] >= FYStartMonth then
          Text.PadEnd(Text.End(Text.From([Year] + 1), 2), 2, "0")
        else
          Text.End(Text.From([Year]), 2)
      ),
    type text
  ),
  AddFQ = Table.AddColumn(
    AddFY,
    "Fiscal Quarter",
    each "FQ"
      & Text.From(Number.RoundUp(Date.Month(Date.AddMonths([Date], - (FYStartMonth - 1))) / 3)),
    type text
  ),
  AddFQnYr = Table.AddColumn(
    AddFQ,
    "FQuarternYear",
    each (if [MonthOfYear] >= FYStartMonth then [Year] + 1 else [Year])
      * 10000 + Number.RoundUp(Date.Month(Date.AddMonths([Date], - (FYStartMonth - 1))) / 3)
      * 100,
    type number
  ),
  AddFM = Table.AddColumn(
    AddFQnYr,
    "Fiscal Period",
    each
      if [MonthOfYear] >= FYStartMonth then
        [MonthOfYear] - (FYStartMonth - 1)
      else
        [MonthOfYear] + (12 - FYStartMonth + 1),
    type text
  ),
  AddFMnYr = Table.AddColumn(
    AddFM,
    "FPeriodnYear",
    each (if [MonthOfYear] >= FYStartMonth then [Year] + 1 else [Year])
      * 10000 + [Fiscal Period]
      * 100,
    type number
  ),
  AddFYPeriod = AddFMnYr,
  FYCalendarStart = #date(Date.Year(StartDate) - 1, FYStartMonth, 1),
  InsertFFD = Table.AddColumn(
    AddFYPeriod,
    "FiscalFirstDay",
    each
      if Date.Month([Date]) < FYStartMonth then
        #date(Date.Year([Date]), FYStartMonth, 1)
      else
        #date(Date.Year([Date]) + 1, FYStartMonth, 1)
  ),
  AddFYDateRange = Table.Buffer(
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
                        {Number.From(FYCalendarStart) .. Number.From(EndDate)},
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
  MergeFYW = Table.NestedJoin(
    InsertFFD,
    {"Date"},
    AddFYDateRange,
    {"Date"},
    "AddFYWeek",
    JoinKind.LeftOuter
  ),
  ExpandFYWeek = Table.TransformColumnTypes(
    Table.ExpandTableColumn(MergeFYW, "AddFYWeek", {"FY Week"}, {"Fiscal Week"}),
    {{"Fiscal Week", Int64.Type}}
  ),
  AddFYW = Table.AddColumn(
    ExpandFYWeek,
    "Fiscal Year & Week",
    each
      if FYStartMonth = 1 then
        [#"Week & Year"]
      else if Date.Month([Date]) < FYStartMonth then
        Text.From(Date.Year([Date])) & "-" & Text.PadStart(Text.From([Fiscal Week]), 2, "0")
      else
        Text.From(Date.Year([Date]) + 1) & "-" & Text.PadStart(Text.From([Fiscal Week]), 2, "0"),
    type text
  ),
  AddFWeekYrN = Table.AddColumn(
    AddFYW,
    "FWeekYrN",
    each
      if FYStartMonth = 1 then
        [WeekYearN]
      else
        (if Date.Month([Date]) < FYStartMonth then Date.Year([Date]) else Date.Year([Date]) + 1)
          * 10000 + [Fiscal Week]
          * 100,
    Int64.Type
  ),
  AddIsAfterToday = Table.AddColumn(
    AddFWeekYrN,
    "IsAfterToday",
    each not ([Date] <= Date.From(CurrentDate)),
    type logical
  ),
  AddIsWorkDay = Table.AddColumn(
    AddIsAfterToday,
    "IsWorkingDay",
    each if Date.DayOfWeek([Date], Day.Monday) > 4 then false else true,
    type logical
  ),
  AddIsHoliday = Table.AddColumn(
    AddIsWorkDay,
    "IsHoliday",
    each if Holidays = null then "Unknown" else List.Contains(Holidays, [Date]),
    if Holidays = null then type text else type logical
  ),
  AddBusinessDay = Table.AddColumn(
    AddIsHoliday,
    "IsBusinessDay",
    each if [IsWorkingDay] = true and [IsHoliday] <> true then true else false,
    type logical
  ),
  AddDayType = Table.AddColumn(
    AddBusinessDay,
    "Day Type",
    each
      if [IsHoliday] = true then
        "Holiday"
      else if [IsWorkingDay] = false then
        "Weekend"
      else if [IsWorkingDay] = true then
        "Weekday"
      else
        null,
    type text
  ),
  CurrentDateRecord = Table.SelectRows(AddDayType, each ([Date] = CurrentDate)),
  CurrentISOyear = CurrentDateRecord{0}[ISO Year],
  CurrentISOqtr = CurrentDateRecord{0}[ISO QuarterOfYear],
  CurrentYear = CurrentDateRecord{0}[Year],
  CurrentMonth = CurrentDateRecord{0}[MonthOfYear],
  CurrentFiscalFirstDay = CurrentDateRecord{0}[FiscalFirstDay],
  PrevFiscalFirstDay = Date.AddYears(CurrentFiscalFirstDay, - 1),
  CurrentFQ = CurrentDateRecord{0}[FQuarternYear],
  CurrentFP = CurrentDateRecord{0}[FPeriodnYear],
  MonthAdd1 = CurrentDateRecord{0}[FPeriodnYear] + 100,
  MonthAdd2 = CurrentDateRecord{0}[FPeriodnYear] + 200,
  MonthAdd3 = CurrentDateRecord{0}[FPeriodnYear] + 300,
  DateAdd1 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 1)
  ),
  DateAdd2 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 2)
  ),
  DateAdd3 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 3)
  ),
  PrevMonthDate = Table.AddColumn(
    CurrentDateRecord,
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
    each (if [PMonthOfYear] >= FYStartMonth then [Year] + 1 else [Year]) * 10000 + [PrevFP] * 100,
    type number
  ),
  CurrentFW = CurrentDateRecord{0}[FWeekYrN],
  AddISOQtrOffset = Table.AddColumn(
    AddDayType,
    "ISO QuarterOffset",
    each ((4 * [ISO Year]) + [ISO QuarterOfYear]) - ((4 * CurrentISOyear) + CurrentISOqtr),
    type number
  ),
  AddISOYrOffset = Table.AddColumn(
    AddISOQtrOffset,
    "ISO YearOffset",
    each [ISO Year] - CurrentISOyear,
    type number
  ),
  AddFYoffset = Table.AddColumn(
    AddISOYrOffset,
    "FiscalYearOffset",
    each try
      (if [MonthOfYear] >= FYStartMonth then [Year] + 1 else [Year])
        - (if CurrentMonth >= FYStartMonth then CurrentYear + 1 else CurrentYear)
    otherwise
      null,
    type number
  ),
  AddIsCurrentFQ = Table.AddColumn(
    AddFYoffset,
    "IsCurrentFQ",
    each if [FQuarternYear] = CurrentFQ then true else false,
    type logical
  ),
  AddIsCurrentFW = Table.AddColumn(
    AddIsCurrentFQ,
    "IsCurrentFW",
    each if [FWeekYrN] = CurrentFW then true else false,
    type logical
  ),
  AddPYTD = Table.AddColumn(
    AddIsCurrentFW,
    "IsPYTD",
    each
      if CurrentYear - 1 = [Year] and [Day of Year] <= CurrentDateRecord{0}[Day of Year] then
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
      each [DateFY] <= CurrentDate
    )[PrevDateFY]
  ),
  InsertPFYTD = Table.AddColumn(
    AddPYTD,
    "IsPFYTD",
    each if [FiscalYearOffset] = - 1 and List.Contains(ListPrevFYDates, [Date]) then true else false,
    type logical
  ),
  RemoveToday = Table.RemoveColumns(
    if EndDate < CurrentDate then
      Table.SelectRows(InsertPFYTD, each ([Date] <> CurrentDate))
    else
      InsertPFYTD,
    {"Day of Year", "FiscalFirstDay"}
  ),
  ChType = Table.TransformColumnTypes(
    RemoveToday,
    {
      {"Year", Int64.Type},
      {"QuarterOfYear", Int64.Type},
      {"MonthOfYear", Int64.Type},
      {"DayOfMonth", Int64.Type},
      {"DateInt", Int64.Type},
      {"DayOfWeek", Int64.Type},
      {"ISO Weeknumber", Int64.Type},
      {"WeekYearN", Int64.Type},
      {"MonthYearN", Int64.Type},
      {"QuarterYrN", Int64.Type},
      {"Fiscal Period", Int64.Type},
      {"WeekOffset", Int64.Type},
      {"MonthOffset", Int64.Type},
      {"QuarterOffset", Int64.Type},
      {"YearOffset", Int64.Type},
      {"FiscalYearOffset", Int64.Type}
    }
  ),
  AddIsCurrentFP = Table.AddColumn(
    ChType,
    "IsCurrentFP",
    each if [FPeriodnYear] = CurrentFP then true else false,
    type logical
  ),
  AddIsToday = Table.AddColumn(
    AddIsCurrentFP,
    "IsToday",
    each if [Date] = DateToday then true else false,
    type logical
  ),
  IsForecast1 = Table.AddColumn(
    AddIsToday,
    "IsForecastAdd1",
    each if [FPeriodnYear] = MonthAdd1 then true else false,
    type logical
  ),
  IsForecast2 = Table.AddColumn(
    IsForecast1,
    "IsForecastAdd2",
    each if [FPeriodnYear] = MonthAdd2 then true else false,
    type logical
  ),
  IsForecast3 = Table.AddColumn(
    IsForecast2,
    "IsForecastAdd3",
    each if [FPeriodnYear] = MonthAdd3 then true else false,
    type logical
  ),
  IsPaidFF = Table.AddColumn(
    IsForecast3,
    "IsPaidFF",
    each if [MonthEnd] <= LastMonth then true else false,
    type logical
  ),
    IsPrevMonth1 = Table.AddColumn(
    IsPaidFF,
    "IsPrevMonth1",
    each if [MonthEnd] = PrevMonth1 then true else false,
    type logical
  ),
    IsLastMonth = Table.AddColumn(
    IsPrevMonth1,
    "IsLastMonth",
    each if [MonthEnd] = LastMonth then true else false,
    type logical
  ),
  IsThisMonth = Table.AddColumn(
    IsLastMonth,
    "IsThisMonth",
    each if [MonthEnd] = ThisMonth then true else false,
    type logical
  ),
  IsCompleteMonth = Table.AddColumn(
    IsThisMonth,
    "IsCompleteMonth",
    each if [MonthEnd] <= DateToday then true else false,
    type logical
  ),
  YTDAdd1 = Table.AddColumn(
    IsCompleteMonth,
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
  AcPeriod = Table.TransformColumnTypes(
    Table.AddColumn(
      YTDAdd3,
      "AcPeriod",
      each (
        if [MonthOfYear] >= FYStartMonth then
          Text.PadEnd(Text.End(Text.From([Year] + 1), 2), 2, "0")
        else
          Text.End(Text.From([Year]), 2)
      ),
      Int64.Type
    ),
    {{"AcPeriod", Int64.Type}}
  ),
  AddPeriod = Table.AddColumn(
    AcPeriod,
    "Period",
    each Number.ToText(([AcPeriod] - 1)) & "-" & Number.ToText([AcPeriod]),
    type text
  ),
  IsCalendarYTD = Table.AddColumn(
    AddPeriod,
    "IsCYTD",
    each Date.IsInYearToDate([Date]),
    type logical
  ),
  AddIsCFY = Table.AddColumn(
    IsCalendarYTD,
    "IsCFY",
    each if [FiscalYearOffset] = 0 then true else false,
    type logical
  ),
  CalendarYear = Table.AddColumn(
    AddIsCFY,
    "Calendar Year",
    each "CY" & (Text.End(Text.From([Year]), 2)),
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
  ReorderColumns = Table.ReorderColumns(
    MTDAdd3,
    {
      "Date", 
      "Calendar Year", 
      "Fiscal Year", 
      "Period", 
      "ISO Year", 
      "Quarter", 
      "Fiscal Quarter", 
      "Fiscal Quarter & Year", 
      "Quarter & Year", 
      "AcPeriod", 
      "Year", 
      "IsToDate", 
      "IsFuture", 
      "YearOffset", 
      "YearCompleted", 
      "QuarterOfYear", 
      "QuarterYrN", 
      "QuarterOffset", 
      "QuarterCompleted", 
      "MonthOfYear", 
      "DayOfMonth", 
      "Month", 
      "Mnth", 
      "Month Initial", 
      "Month & Year", 
      "MonthYearN", 
      "MonthOffset", 
      "MonthComplete", 
      "MonthStart", 
      "MonthEnd", 
      "DateInt", 
      "DayOfWeek", 
      "DayOfWeekName", 
      "Weekday Initial", 
      "ISO Weeknumber", 
      "ISO QuarterOfYear", 
      "ISO Quarter", 
      "ISO Quarter & Year", 
      "ISO QuarterYearN", 
      "Week & Year", 
      "WeekYearN", 
      "WeekOffset", 
      "WeekCompleted", 
      "WeekStart", 
      "WeekEnd", 
      "FQuarternYear", 
      "Fiscal Period", 
      "FPeriodnYear", 
      "Fiscal Week", 
      "Fiscal Year & Week", 
      "FWeekYrN", 
      "IsAfterToday", 
      "IsWorkingDay", 
      "IsHoliday", 
      "IsBusinessDay", 
      "Day Type", 
      "ISO QuarterOffset", 
      "ISO YearOffset", 
      "FiscalYearOffset", 
      "IsCurrentFQ", 
      "IsCurrentFW", 
      "IsPYTD", 
      "IsPFYTD", 
      "IsToday", 
      "IsCurrentFP", 
      "IsLastMonth", 
      "IsPrevMonth1", 
      "IsForecastAdd1", 
      "IsForecastAdd2", 
      "IsForecastAdd3", 
      "IsPaidFF", 
      "IsThisMonth", 
      "IsCompleteMonth", 
      "YTDAdd1", 
      "YTDAdd2", 
      "YTDAdd3", 
      "IsCFY", 
      "IsCYTD", 
      "LatestMTD", 
      "MTDAdd1", 
      "MTDAdd2", 
      "MTDAdd3"
    }
  ),
  RemoveISOcolumns = Table.SelectColumns(
    ReorderColumns,
    {
      "Date", 
      "Calendar Year", 
      "Fiscal Year", 
      "Period", 
      "Quarter", 
      "Fiscal Quarter", 
      "Fiscal Quarter & Year", 
      "Quarter & Year", 
      "AcPeriod", 
      "Year", 
      "IsToDate", 
      "IsFuture", 
      "YearOffset", 
      "YearCompleted", 
      "QuarterOfYear", 
      "QuarterYrN", 
      "QuarterOffset", 
      "QuarterCompleted", 
      "MonthOfYear", 
      "DayOfMonth", 
      "Month", 
      "Mnth", 
      "Month Initial", 
      "Month & Year", 
      "MonthYearN", 
      "MonthOffset", 
      "MonthComplete", 
      "MonthStart", 
      "MonthEnd", 
      "DateInt", 
      "DayOfWeek", 
      "DayOfWeekName", 
      "Weekday Initial", 
      "Week & Year", 
      "WeekYearN", 
      "WeekOffset", 
      "WeekCompleted", 
      "WeekStart", 
      "WeekEnd", 
      "FQuarternYear", 
      "Fiscal Period", 
      "FPeriodnYear", 
      "Fiscal Week", 
      "Fiscal Year & Week", 
      "FWeekYrN", 
      "IsAfterToday", 
      "IsWorkingDay", 
      "IsHoliday", 
      "IsBusinessDay", 
      "Day Type", 
      "FiscalYearOffset", 
      "IsCurrentFQ", 
      "IsCurrentFW", 
      "IsPYTD", 
      "IsPFYTD", 
      "IsPrevMonth1", 
      "IsLastMonth", 
      "IsToday", 
      "IsCYTD", 
      "IsCurrentFP", 
      "IsThisMonth", 
      "IsCompleteMonth", 
      "IsForecastAdd1", 
      "IsForecastAdd2", 
      "IsForecastAdd3", 
      "IsPaidFF", 
      "YTDAdd1", 
      "YTDAdd2", 
      "YTDAdd3", 
      "IsCFY", 
      "LatestMTD", 
      "MTDAdd1", 
      "MTDAdd2", 
      "MTDAdd3"
    }
  )
in
  RemoveISOcolumns // QueryEND                                                       
      , 
      // MetaData
      documentation = [
        Documentation.Name = " fnDateTable", 
        Documentation.Description
          = " Date table function to create an ISO-8601 calendar with additional columns for TVCA Group analytics ", 
        Documentation.LongDescription
          = " Date table function to create an Standard and Fiscal Calendar with additional columns for TVCA Group analytics ", 
        Documentation.Category = " Dates Table", 
        Documentation.Version
          = " 01-12-2021 ", 
        Documentation.Source = " local", 
        Documentation.Author = " Imran Haq", 
        Documentation.Examples = {
          [
            Description
              = " Inspired by Melissa Koarte at Enterprise DNA - See: https://forum.enterprisedna.co/t/extended-date-table-power-query-m-function/6390", 
            Code
              = " Optional paramters: #(lf)
      (FYStartMonthNum) Month number the fiscal year starts, January if omitted #(lf) 
      (Holidays) Select a query (and column) that contains a list of holiday dates #(lf) 
      (WDStartNum) Switch default weekday numbering from 0-6 to 1-7 by entering a 1 #(lf)
      #(lf)
      Important to note: #(lf)
      [Fiscal Week] starts on a Monday and can contain less than 7 days in a First- and/or Last Week of a FY #(lf)
      [IsWorkingDay] does not take holiday dates into account  #(lf)
      [IsBusinessDay] does take optional holiday dates into account  #(lf)
      [IsPYTD] and [IsPFYTD] compare Previous [Day of Year] with the Current [Day of Year] number, so dates don't align in leap years", 
            Result = " "
          ]
        }
      ]
    in
      Value.ReplaceType(fnDateTable, Value.ReplaceMetadata(Value.Type(fnDateTable), documentation))
// MetaData
in Source
  // fnDateTable
