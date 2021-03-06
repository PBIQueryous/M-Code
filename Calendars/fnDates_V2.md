## fnDates_V2

```c#
let
  Source =  // fnDateTableSTART                   
  
    let
      fnDates = (
        // Year start as number: yyyy
        varYearStart as number, 
        
        // Year end as number: yyyy
        varYearEnd as number, 
        
        // Fiscal start date: dd/mm/yyyy
        optional varFiscalDate as date, 
        
        // Fiscal start month: mm
        optional varHolidays as list, 
        
        // Add week stark by default 1 = Mon, 0 = Sun
        optional varWDStartNum as number
      ) as table =>
        // fnDateTableEND
        //QuerySTART
  let
  dateStart = #date(varYearStart, 1, 1),
  dateEnd = #date(varYearEnd, 12, 31),
  dateFiscalOrCalendar = if varFiscalDate = null then dateStart else varFiscalDate,
  dateFiscalStart = Date.FromText(
    "1-" & Text.From(Date.Month(varFiscalDate)) & "-" & Text.From(Date.Year(varFiscalDate))
  ),
  varFiscalMonthStart = Date.Month(varFiscalDate),
  dateFiscalEnd = Date.AddDays(Date.AddYears(dateFiscalStart, 1), - 1),
  
  // ProperStartHere                  
  dateToday = DateTime.Date(DateTime.LocalNow()),
  dateLatestCompleteMTD = Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1),
  datePrevMTD = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), - 1)
  ),
  dateLastMTD = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 0)
  ),
  dateThisMTD = Date.EndOfMonth(DateTime.Date(DateTime.LocalNow())),
  dateNextMTD1 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 1)
  ),
  dateNextMTD2 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 2)
  ),
  dateNextMTD3 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 3)
  ),
  fiscalMonthStart =
    if List.Contains({1 .. 12}, varFiscalMonthStart) then varFiscalMonthStart else 1,
  weekDayStart = Text.Proper(Text.Start(Date.DayOfWeekName(#date(2021, 2, 1)), 3)),
  weekdayStartNum = if List.Contains({0, 1}, varWDStartNum) then varWDStartNum else 1,
  dateNow = Date.From(DateTime.FixedLocalNow()),
  daysCount = Duration.Days(Duration.From(dateEnd - dateStart)) + 1,
    START_DATES = daysCount,
  datesList = List.Dates(dateStart, START_DATES, #duration(1, 0, 0, 0)),
  dateToTable = if dateEnd < dateNow then Table.FromList(List.Combine({datesList, {dateNow}})) 
else Table.FromList(datesList, Splitter.SplitByNothing()),
  formatColumn = Table.RenameColumns(Table.TransformColumnTypes(dateToTable, {{"Column1", type date}}), {{"Column1", "Date"}}),
  addYear = Table.AddColumn(formatColumn, "Year", each Date.Year([Date]), type number),
    addCalendarYear = Table.AddColumn(
    addYear,
    "Calendar Year",
    each "CY" & (Text.End(Text.From([Year]), 2)),
    type text
  ),
    addQuarterNUM = Table.AddColumn(
    addCalendarYear,
    "QuarterNUM",
    each Date.QuarterOfYear([Date]),
    type number
  ),
    addQuarterYearINT = Table.AddColumn(
    addQuarterNUM,
    "QuarterYearINT",
    each [Year] * 10000 + [QuarterNUM] * 100,
    type number
  ),
    addQuarter = Table.AddColumn(
    addQuarterYearINT,
    "Quarter",
    each "Q" & Text.From(Date.QuarterOfYear([Date])),
    type text
  ),
    addQuarterYear = Table.AddColumn(
    addQuarter,
    "Qtr & Yr",
    each "Q" & Number.ToText([QuarterNUM]) & " " & Text.End(Number.ToText([Year]), 2),
    type text
  ),
    addMonthNUM = Table.AddColumn(
    addQuarterYear,
    "MonthNUM",
    each Date.Month([Date]),
    type number
  ),
    addMonthYearINT = Table.AddColumn(
    addMonthNUM,
    "MonthYearINT",
    each [Year] * 10000 + [MonthNUM] * 100,
    type number
  ),
    addMonth = Table.AddColumn(
    addMonthYearINT,
    "Month",
    each Text.Proper(Date.ToText([Date], "MMMM")),
    type text
  ),
    addMnth = Table.AddColumn(
    addMonth,
    "Mnth",
    each try Text.Proper(Text.Start([Month], 3)) otherwise Text.Proper([Month]),
    type text
  ),
    addMonthInitial = Table.AddColumn(
    addMnth,
    "Month Initial",
    each Text.Proper(Text.Start([Month], 1))
      & Text.Repeat(Character.FromNumber(8203), [MonthNUM]),
    type text
  ),
    addMonthYear = Table.AddColumn(
    addMonthInitial,
    "Month & Year",
    each [Mnth] & " " & Text.End(Number.ToText([Year]), 2),
    type text
  ),
    addDayOfMonth = Table.AddColumn(addMonthYear, "DayOfMonth", each Date.Day([Date]), type number),
    addDateINT = Table.AddColumn(
    addDayOfMonth,
    "DateINT",
    each [Year] * 10000 + [MonthNUM] * 100 + [DayOfMonth],
    type number
  ),
    addDayOfYear = Table.AddColumn(addDateINT, "DayOfYear", each Date.DayOfYear([Date]), Int64.Type),
    addDayOfWeek = Table.AddColumn(
    addDayOfYear,
    "DayOfWeek",
    each Date.DayOfWeek([Date]) + weekdayStartNum,
    Int64.Type
  ),
    addDayName = Table.AddColumn(
    addDayOfWeek,
    "DayName",
    each Text.Proper(Date.ToText([Date], "dddd")),
    type text
  ),
    addDay = Table.AddColumn(
    addDayName,
    "Day",
    each Text.Proper(Date.ToText([Date], "ddd")),
    type text
  ),
    addDayInitial = Table.AddColumn(
    addDay,
    "Weekday Initial",
    each Text.Proper(Text.Start([DayName], 1))
      & Text.Repeat(Character.FromNumber(8203), [DayOfWeek]),
    type text
  ),
    addisWorkDay = Table.AddColumn(
    addDayInitial,
    "IsWorkingDay",
    each if Date.DayOfWeek([Date], Day.Monday) > 4 then false else true,
    type logical
  ),
    AddIsHoliday = Table.AddColumn(
    addisWorkDay,
    "IsHoliday",
    each if varHolidays = null then "Unknown" else List.Contains(varHolidays, [Date]),
    if varHolidays = null then type text else type logical
  ),
    AddBusinessDay = Table.AddColumn(
    AddIsHoliday,
    "IsBusinessDay",
    each if [IsWorkingDay] = true and [IsHoliday] <> true then true else false,
    type logical
  ),
    addisAfterToday = Table.AddColumn(
    AddBusinessDay,
    "isAfterToday",
    each not ([Date] <= Date.From(dateNow)),
    type logical
  ),
    AddDayType = Table.AddColumn(
    addisAfterToday,
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
    addWeekNUM = Table.AddColumn(AddDayType, "WeekNUM", each Date.WeekOfYear([Date], Day.Monday), Int64.Type),
    addisActual = Table.AddColumn(
    addWeekNUM,
    "isActual",
    each if [Date] <= dateNow then true else false,
    type logical
  ),
  addIsForecast = Table.AddColumn(
    addisActual,
    "isForecast",
    each if [Date] > dateNow then true else false,
    type logical
  ),
    addIsYearComplete = Table.AddColumn(
    addIsForecast,
    "isYearComplete",
    each Date.EndOfYear([Date]) < Date.From(Date.EndOfYear(dateNow)),
    type logical
  ),
    addIsQuarterComplete = Table.AddColumn(
    addIsYearComplete,
    "isQuarterComplete",
    each Date.EndOfQuarter([Date]) < Date.From(Date.EndOfQuarter(dateNow)),
    type logical
  ),
    addIsMonthComplete = Table.AddColumn(
    addIsQuarterComplete,
    "isMonthComplete",
    each Date.EndOfMonth([Date]) < Date.From(Date.EndOfMonth(dateNow)),
    type logical
  ),
    addMonthStart = Table.AddColumn(
    addIsMonthComplete,
    "MonthStart",
    each Date.StartOfMonth([Date]),
    type date
  ),
    addMonthEnd = Table.AddColumn(addMonthStart, "MonthEnd", each Date.EndOfMonth([Date]), type date),
    offsetYear = Table.AddColumn(
    addMonthEnd,
    "offsetYear",
    each Date.Year([Date]) - Date.Year(Date.From(dateNow)),
    type number
  ),
  offsetQuarter = Table.AddColumn(
    offsetYear,
    "offsetQuarter",
    each ((4 * Date.Year([Date])) + Date.QuarterOfYear([Date]))
      - ((4 * Date.Year(Date.From(dateNow))) + Date.QuarterOfYear(Date.From(dateNow))),
    type number
  ),
  offsetMonth = Table.AddColumn(
    offsetQuarter,
    "offsetMonth",
    each ((12 * Date.Year([Date])) + Date.Month([Date]))
      - ((12 * Date.Year(Date.From(dateNow))) + Date.Month(Date.From(dateNow))),
    type number
  ),
    addWeekISO = Table.AddColumn(
    offsetMonth,
    "WeekISO",
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
  addYearISO = Table.AddColumn(
    addWeekISO,
    "YearISO",
    each Date.Year(Date.AddDays(Date.StartOfWeek([Date], Day.Monday), 3)),
    Int64.Type
  ),
  bufferTable = Table.Buffer(
    Table.Sort(Table.Distinct(addYearISO[[YearISO], [DateINT]]), {{"DateINT", Order.Descending}})
  ),
  addQtrYrISO = Table.AddColumn(
    addYearISO,
    "QuarterYearISONUM",
    each
      if [WeekISO] > 39 then
        4
      else if [WeekISO] > 26 then
        3
      else if [WeekISO] > 13 then
        2
      else
        1,
    Int64.Type
  ),
  addQtrISO = Table.AddColumn(
    addQtrYrISO,
    "QuarterISO",
    each "Q" & Number.ToText([QuarterYearISONUM]),
    type text
  ),
  addQuarterYearISO = Table.AddColumn(
    addQtrISO,
    "QuarterYearISO",
    each "Q" & Number.ToText([QuarterYearISONUM]) & " " & Text.End(Number.ToText([YearISO]), 2),
    type text
  ),
  addQuarterYearISOINT = Table.AddColumn(
    addQuarterYearISO,
    "QuarterYearISOINT",
    each [YearISO] * 10000 + [QuarterYearISONUM] * 100,
    type number
  ),
  //InsertISOday = Table.AddColumn(InsertISOqNy, "ISO Day of Year", (OT) => Table.RowCount( Table.SelectRows( BufferTable, (IT) => IT[DateInt] <= OT[DateInt] and IT[ISO Year] = OT[ISO Year])),  Int64.Type),                                                                                                                                                                                                            
  addWeekYearISO = Table.AddColumn(
    addQuarterYearISOINT,
    "WeekYearISO",
    each Text.From([YearISO]) & "-" & Text.PadStart(Text.From([WeekISO]), 2, "0"),
    type text
  ),
  addWeekYearISOINT = Table.AddColumn(
    addWeekYearISO,
    "WeekYearISOINT",
    each [YearISO] * 10000 + [WeekISO] * 100,
    Int64.Type
  ),
  addWeekOffset = Table.AddColumn(
    addWeekYearISOINT,
    "offsetWeek",
    each (
      Number.From(Date.StartOfWeek([Date], Day.Monday))
        - Number.From(Date.StartOfWeek(dateNow, Day.Monday))
    )
      / 7,
    type number
  ),
  addIsWeekComplete = Table.AddColumn(
    addWeekOffset,
    "isWeekComplete",
    each Date.EndOfWeek([Date], Day.Monday) < Date.From(Date.EndOfWeek(dateNow, Day.Monday)),
    type logical
  ),
  addWeekStart = Table.AddColumn(
    addIsWeekComplete,
    "WeekStart",
    each Date.StartOfWeek([Date], Day.Monday),
    type date
  ),
  addWeekEnd = Table.AddColumn(
    addWeekStart,
    "WeekEnd",
    each Date.EndOfWeek([Date], Day.Monday),
    type date
  ),
  addFiscalYear = Table.AddColumn(
    addWeekEnd,
    "Fiscal Year",
    each "FY"
      & (
        if [MonthNUM] >= fiscalMonthStart then
          Text.PadEnd(Text.End(Text.From([Year] + 1), 2), 2, "0")
        else
          Text.End(Text.From([Year]), 2)
      ),
    type text
  ),
  addFiscalQuarter = Table.AddColumn(
    addFiscalYear,
    "Fiscal Quarter",
    each "FQ"
      & Text.From(Number.RoundUp(Date.Month(Date.AddMonths([Date], - (fiscalMonthStart - 1))) / 3)),
    type text
  ),
  addFiscalQuarterINT = Table.AddColumn(
    addFiscalQuarter,
    "FiscalQuarterYearINT",
    each (if [MonthNUM] >= fiscalMonthStart then [Year] + 1 else [Year])
      * 10000 + Number.RoundUp(Date.Month(Date.AddMonths([Date], - (fiscalMonthStart - 1))) / 3)
      * 100,
    type number
  ),
  addFiscalMonthNUM = Table.AddColumn(
    addFiscalQuarterINT,
    "FiscalMonthNUM",
    each
      if [MonthNUM] >= fiscalMonthStart then
        [MonthNUM] - (fiscalMonthStart - 1)
      else
        [MonthNUM] + (12 - fiscalMonthStart + 1),
    type text
  ),
  addFiscalMonthYearINT = Table.AddColumn(
    addFiscalMonthNUM,
    "FiscalMonthYearINT",
    each (if [MonthNUM] >= fiscalMonthStart then [Year] + 1 else [Year])
      * 10000 + [FiscalMonthNUM]
      * 100,
    type number
  ),
    addFiscalQuarterYear = Table.AddColumn(
    addFiscalMonthYearINT,
    "Fiscal Quarter & Year",
    each [Fiscal Quarter] & " " & Text.End([Fiscal Year], 2),
    type text
  ),
  AddFYPeriod = addFiscalQuarterYear,
  varFiscalYearStart = #date(Date.Year(dateStart) - 1, fiscalMonthStart, 1),
  addFiscalDateStart = Table.AddColumn(
    AddFYPeriod,
    "FiscalFirstDay",
    each
      if Date.Month([Date]) < fiscalMonthStart then
        #date(Date.Year([Date]), fiscalMonthStart, 1)
      else
        #date(Date.Year([Date]) + 1, fiscalMonthStart, 1)
  ),
  addFiscalWeekRange = Table.Buffer(
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
                        {Number.From(varFiscalYearStart) .. Number.From(dateEnd)},
                        Splitter.SplitByNothing()
                      ),
                      {{"Column1", type date}}
                    ),
                    {{"Column1", "Date"}}
                  ),
                  "FiscalFirstDay",
                  each
                    if Date.Month([Date]) < fiscalMonthStart then
                      #date(Date.Year([Date]), fiscalMonthStart, 1)
                    else
                      #date(Date.Year([Date]) + 1, fiscalMonthStart, 1)
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
  mergeFiscalWeek = Table.NestedJoin(
    addFiscalDateStart,
    {"Date"},
    addFiscalWeekRange,
    {"Date"},
    "AddFYWeek",
    JoinKind.LeftOuter
  ),
  expandFiscalWeekNUM = Table.TransformColumnTypes(
    Table.ExpandTableColumn(mergeFiscalWeek, "AddFYWeek", {"FY Week"}, {"Fiscal Week"}),
    {{"Fiscal Week", Int64.Type}}
  ),
  addYearFiscalWk = Table.AddColumn(
    expandFiscalWeekNUM,
    "Fiscal Year & Week",
    each
      if fiscalMonthStart = 1 then
        [#"Week & Year"]
      else if Date.Month([Date]) < fiscalMonthStart then
        Text.From(Date.Year([Date])) & "-" & Text.PadStart(Text.From([Fiscal Week]), 2, "0")
      else
        Text.From(Date.Year([Date]) + 1) & "-" & Text.PadStart(Text.From([Fiscal Week]), 2, "0"),
    type text
  ),
  addFiscalWeekINT = Table.AddColumn(
    addYearFiscalWk,
    "FiscalWeekINT",
    each
      if fiscalMonthStart = 1 then
        [WeekYearN]
      else
        (if Date.Month([Date]) < fiscalMonthStart then Date.Year([Date]) else Date.Year([Date]) + 1)
          * 10000 + [Fiscal Week]
          * 100,
    Int64.Type
  ),
  varDateNowRow = Table.SelectRows(addFiscalWeekINT, each ([Date] = dateNow)),
  varCurrentYearISO = varDateNowRow{0}[YearISO],
  varCurrentQuarterISO = varDateNowRow{0}[QuarterYearISONUM],
  varCurrentYear = varDateNowRow{0}[Year],
  varCurrentMonth = varDateNowRow{0}[MonthNUM],
  varCurrentFiscalFirstDay = varDateNowRow{0}[FiscalFirstDay],
  varPrevFiscalFirstDay = Date.AddYears(varCurrentFiscalFirstDay, - 1),
  varCurrentFQINT = varDateNowRow{0}[FiscalQuarterYearINT],
  varCurrentFMINT = varDateNowRow{0}[FiscalMonthYearINT],
  MonthAdd1 = varDateNowRow{0}[FiscalMonthYearINT] + 100,
  MonthAdd2 = varDateNowRow{0}[FiscalMonthYearINT] + 200,
  MonthAdd3 = varDateNowRow{0}[FiscalMonthYearINT] + 300,
    MonthAdd4 = varDateNowRow{0}[FiscalMonthYearINT] + 400,
    MonthAdd5 = varDateNowRow{0}[FiscalMonthYearINT] + 500,
    MonthAdd6 = varDateNowRow{0}[FiscalMonthYearINT] + 600,
  DateAdd1 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 1)
  ),
  DateAdd2 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 2)
  ),
  DateAdd3 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 3)
  ),
    DateAdd4 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 4)
  ),
    DateAdd5 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 5)
  ),
    DateAdd6 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 6)
  ),
  DateAdd7 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 7)
  ),
  DateAdd8 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 8)
  ),
  DateAdd9 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 9)
  ),
    DateAdd10 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 10)
  ),
    DateAdd11 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 11)
  ),
    DateAdd12 = Date.EndOfMonth(
    Date.AddMonths(Date.AddDays(Date.StartOfMonth(DateTime.Date(DateTime.LocalNow())), - 1), + 12)
  ),
  addPrevMonthDate = Table.AddColumn(
    varDateNowRow,
    "PrevFiscalDate",
    each Date.EndOfMonth(Date.AddMonths([MonthEnd], - 1)),
    type date
  ),
  addPrevMonthNUM = Table.AddColumn(
    addPrevMonthDate,
    "PrevMonthNUM",
    each Date.Month([PrevFiscalDate]),
    type number
  ),
  addPrevFiscalMonthNUM = Table.AddColumn(
    addPrevMonthNUM,
    "PrevFiscalMonthNUM",
    each
      if [PrevMonthNUM] >= fiscalMonthStart then
        [PrevMonthNUM] - (fiscalMonthStart - 1)
      else
        [PMonthOfYear] + (12 - fiscalMonthStart + 1),
    type text
  ),
  addPrevFiscalMonthINT = Table.AddColumn(
    addPrevFiscalMonthNUM,
    "PrevFiscalMonthINT",
    each (if [PrevMonthNUM] >= fiscalMonthStart then [Year] + 1 else [Year]) * 10000 + [PrevFiscalMonthNUM] * 100,
    type number
  ),
  varCurrentFiscalWeek = varDateNowRow{0}[FiscalWeekINT],
  offsetQuarterISO = Table.AddColumn(
    addFiscalWeekINT,
    "offsetQuarterISO",
    each ((4 * [YearISO]) + [QuarterYearISONUM]) - ((4 * varCurrentYearISO) + varCurrentQuarterISO),
    type number
  ),
  offsetYearISO = Table.AddColumn(
    offsetQuarterISO,
    "offsetYearISO",
    each [YearISO] - varCurrentYearISO,
    type number
  ),
  offsetFiscalYear = Table.AddColumn(
    offsetYearISO,
    "offsetFiscalYear",
    each try
      (if [MonthNUM] >= fiscalMonthStart then [Year] + 1 else [Year])
        - (if varCurrentMonth >= fiscalMonthStart then varCurrentYear + 1 else varCurrentYear)
    otherwise
      null,
    type number
  ),
  addIsCurrFiscalQuarter = Table.AddColumn(
    offsetFiscalYear,
    "isCurrentFiscalQuarter",
    each if [FiscalQuarterYearINT] = varCurrentFQINT then true else false,
    type logical
  ),
  addIsCurrFiscalWeek = Table.AddColumn(
    addIsCurrFiscalQuarter,
    "isCurrentFiscalWeek",
    each if [FiscalWeekINT] = varCurrentFiscalWeek then true else false,
    type logical
  ),
  addPrevYTD = Table.AddColumn(
    addIsCurrFiscalWeek,
    "isPrevYTD",
    each
      if varCurrentYear - 1 = [Year] and [DayOfYear] <= varDateNowRow{0}[DayOfYear] then
        true
      else
        false,
    type logical
  ),
  listPrevYearDates = List.Buffer(
    Table.SelectRows(
      Table.ExpandTableColumn(
        Table.NestedJoin(
          Table.AddIndexColumn(
            Table.RenameColumns(
              Table.TransformColumnTypes(
                Table.FromList(
                  List.Dates(
                    varPrevFiscalFirstDay,
                    Number.From(varCurrentFiscalFirstDay - varPrevFiscalFirstDay),
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
                    Date.AddYears(varPrevFiscalFirstDay, - 1),
                    Number.From(varPrevFiscalFirstDay - Date.AddYears(varPrevFiscalFirstDay, - 1)),
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
      each [DateFY] <= dateNow
    )[PrevDateFY]
  ),
  addPrevFiscalYTD = Table.AddColumn(
    addPrevYTD,
    "isPrevFiscalYTD",
    each if [offsetFiscalYear] = - 1 and List.Contains(listPrevYearDates, [Date]) then true else false,
    type logical
  ),
  removeToday = Table.RemoveColumns(
    if dateEnd < dateNow then
      Table.SelectRows(addPrevFiscalYTD, each ([Date] <> dateNow))
    else
      addPrevFiscalYTD,
    {"DayOfYear", "FiscalFirstDay"}
  ),
  addIsCurrentFiscalMonth = Table.AddColumn(
    removeToday,
    "isCurrentFiscalMonth",
    each if [FiscalMonthYearINT] = varCurrentFMINT then true else false,
    type logical
  ),
  addIsToday = Table.AddColumn(
    addIsCurrentFiscalMonth,
    "isToday",
    each if [Date] = dateToday then true else false,
    type logical
  ),
  IsForecast1 = Table.AddColumn(
    addIsToday,
    "IsForecastAdd1",
    each if [FiscalMonthYearINT] = MonthAdd1 then true else false,
    type logical
  ),
  IsForecast2 = Table.AddColumn(
    IsForecast1,
    "IsForecastAdd2",
    each if [FiscalMonthYearINT] = MonthAdd2 then true else false,
    type logical
  ),
  IsForecast3 = Table.AddColumn(
    IsForecast2,
    "IsForecastAdd3",
    each if [FiscalMonthYearINT] = MonthAdd6 then true else false,
    type logical
  ),
  IsPaidFF = Table.AddColumn(
    IsForecast3,
    "IsPaidFF",
    each if [MonthEnd] <= dateLastMTD then true else false,
    type logical
  ),
    IsPrevMonth1 = Table.AddColumn(
    IsPaidFF,
    "IsPrevMonth1",
    each if [MonthEnd] = datePrevMTD then true else false,
    type logical
  ),
    IsLastMonth = Table.AddColumn(
    IsPrevMonth1,
    "IsLastMonth",
    each if [MonthEnd] = dateLastMTD then true else false,
    type logical
  ),
  IsThisMonth = Table.AddColumn(
    IsLastMonth,
    "IsThisMonth",
    each if [MonthEnd] = dateThisMTD then true else false,
    type logical
  ),
  IsCompleteMonth = Table.AddColumn(
    IsThisMonth,
    "IsCompleteMonth",
    each if [MonthEnd] <= dateToday then true else false,
    type logical
  ),
    IsIncompleteMonth = Table.AddColumn(
    IsCompleteMonth,
    "isIncompleteMonth",
    each if [MonthEnd] > dateToday then true else false,
    type logical
  ),
  YTDAdd1 = Table.AddColumn(
    IsIncompleteMonth,
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
  YTDAdd4 = Table.AddColumn(
    YTDAdd3,
    "YTDAdd4",
    each if [MonthEnd] <= DateAdd4 then true else false,
    type logical
  ),
  YTDAdd5 = Table.AddColumn(
    YTDAdd4,
    "YTDAdd5",
    each if [MonthEnd] <= DateAdd5 then true else false,
    type logical
  ),
  YTDAdd6 = Table.AddColumn(
    YTDAdd5,
    "YTDAdd6",
    each if [MonthEnd] <= DateAdd6 then true else false,
    type logical
  ),
  YTDAdd7 = Table.AddColumn(
    YTDAdd6,
    "YTDAdd7",
    each if [MonthEnd] <= DateAdd7 then true else false,
    type logical
  ),
  YTDAdd8 = Table.AddColumn(
    YTDAdd7,
    "YTDAdd8",
    each if [MonthEnd] <= DateAdd8 then true else false,
    type logical
  ),
  YTDAdd9 = Table.AddColumn(
    YTDAdd8,
    "YTDAdd9",
    each if [MonthEnd] <= DateAdd9 then true else false,
    type logical
  ),
  YTDAdd10 = Table.AddColumn(
    YTDAdd9,
    "YTDAdd10",
    each if [MonthEnd] <= DateAdd10 then true else false,
    type logical
  ),
  YTDAdd11 = Table.AddColumn(
    YTDAdd10,
    "YTDAdd11",
    each if [MonthEnd] <= DateAdd11 then true else false,
    type logical
  ),
  YTDAdd12 = Table.AddColumn(
    YTDAdd11,
    "YTDAdd12",
    each if [MonthEnd] <= DateAdd12 then true else false,
    type logical
  ),
  addFiscalYr = Table.TransformColumnTypes(
    Table.AddColumn(
      YTDAdd12,
      "FiscalYr",
      each (
        if [MonthNUM] >= fiscalMonthStart then
          Text.PadEnd(Text.End(Text.From([Year] + 1), 2), 2, "0")
        else
          Text.End(Text.From([Year]), 2)
      ),
      Int64.Type
    ),
    {{"FiscalYr", Int64.Type}}
  ),
  addFiscalPeriod = Table.AddColumn(
    addFiscalYr,
    "FiscalPeriod",
    each Number.ToText(([FiscalYr] - 1)) & "-" & Number.ToText([FiscalYr]),
    type text
  ),
  addIsCurrentYTD = Table.AddColumn(
    addFiscalPeriod,
    "isCurrentYTD",
    each Date.IsInYearToDate([Date]),
    type logical
  ),
  addIsCurrentFY = Table.AddColumn(
    addIsCurrentYTD,
    "isCurrentFiscalYear",
    each if [offsetFiscalYear] = 0 then true else false,
    type logical
  ),
  dateCompleteMonth = Table.AddColumn(
    addIsCurrentFY,
    "CompleteMonthAdd0",
    each if [IsCompleteMonth] = true then [Date] else null,
    type date
  ),
  dateCompleteMonth1 = Table.AddColumn(
    dateCompleteMonth,
    "CompleteMonthAdd1",
    each if [YTDAdd1] = true then [Date] else null,
    type date
  ),
  dateCompleteMonth2 = Table.AddColumn(
    dateCompleteMonth1,
    "CompleteMonthAdd2",
    each if [YTDAdd2] = true then [Date] else null,
    type date
  ),
  dateCompleteMonth3 = Table.AddColumn(
    dateCompleteMonth2,
    "CompleteMonthAdd3",
    each if [YTDAdd3] = true then [Date] else null,
    type date
  )
in
    dateCompleteMonth3
    // QueryEND                                                       
      
      , 
      // MetaData
      documentation = [
        Documentation.Name = " fnDates", 
        Documentation.Description
          = " Date table function: Creates ISO-8601 calendar with Fiscal Calendar ", 
        Documentation.LongDescription
          = " Date table function: Creates ISO-8601 calendar with Fiscal Calendar ", 
        Documentation.Category = " Dates Table", 
        Documentation.Version
          = " 22-01-2022 ", 
        Documentation.Source = " remote ", 
        Documentation.Author = " Imran Haq", 
        Documentation.Examples = {
          [
            Description
              = " Inspired by Melissa Koarte at Enterprise DNA - See: https://forum.enterprisedna.co/t/extended-date-table-power-query-m-function/6390", 
            Code
              = " Optional paramters: #(lf)
      (varFiscalMonthStart) Month number the fiscal year starts, January if omitted #(lf) 
      (varHolidays) Select a query (and column) that contains a list of holiday dates #(lf) 
      (varWDStartNum) Switch default weekday numbering from 0-6 to 1-7 by entering a 1 #(lf)
      #(lf)
      Important to note: #(lf)
      [Fiscal Week] starts on a Monday and can contain less than 7 days in a First- and/or Last Week of a FY #(lf)
      [isWorkingDay] does not take holiday dates into account  #(lf)
      [isBusinessDay] does take optional holiday dates into account  #(lf)
      [isPrevYTD] and [issPrevFiscalYTD] compare Previous [DayOfYear] with the Current [DayOfYear] number, so dates don't align in leap years", 
            Result = " "
          ]
        }
      ]
    in
      Value.ReplaceType(fnDates, Value.ReplaceMetadata(Value.Type(fnDates), documentation))
// MetaData
in Source

```
