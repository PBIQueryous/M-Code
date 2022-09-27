# tx_DatesTable
## Extended dates table DEBUG mode
### Author: Enterpise DNA

```C#
// fxCalendar = let fnDateTable = ( StartDate as date, EndDate as date, optional FYStartMonthNum as number, optional Holidays as list, optional WDStartNum as number, optional AddRelativeNetWorkdays as logical ) as table =>    
let
                // //Parameters
                StartDate = #date(2020, 1, 1),
                EndDate = #date(2024, 12, 31),
                FYStartMonthNum = 1,
                Holidays = {},
                WDStartNum = 1,
                AddRelativeNetWorkdays = true,

                //Date table code
                FYStartMonth = List.Select( {1..12}, each _ = FYStartMonthNum ){0}? ?? 1,
                WDStart = List.Select( {0..1}, each _ = WDStartNum ){0}? ?? 0,
                CurrentDate = Date.From( DateTime.FixedLocalNow()),
                DayCount = Duration.Days( Duration.From( EndDate - StartDate)) +1,
                list_Dates = List.Dates( StartDate, DayCount, #duration(1,0,0,0)),
                tx_AddToday = if EndDate < CurrentDate then List.Combine( {list_Dates, {CurrentDate}}) else list_Dates,
                make_Table = Table.FromList(tx_AddToday, Splitter.SplitByNothing(), type table [Date = Date.Type] ),
                col_Year = Table.AddColumn(make_Table, "Year", each Date.Year([Date]), type number),
                col_YearOFFSET = Table.AddColumn(col_Year, "CurrYearOffset", each Date.Year([Date]) - Date.Year( Date.From(CurrentDate)), type number),
                col_isYearComplete = Table.AddColumn(col_YearOFFSET, "isYearComplete", each Date.EndOfYear([Date]) < Date.From( Date.EndOfYear(CurrentDate)), type logical),

                col_QuarterNUM = Table.AddColumn(col_isYearComplete, "QuarterNUM", each Date.QuarterOfYear([Date]), type number),
                col_QuarterTXT = Table.AddColumn(col_QuarterNUM, "Quarter", each "Q" & Number.ToText([QuarterNUM]), type text),
                col_QuarterSTART = Table.AddColumn(col_QuarterTXT, "Start of Quarter", each Date.StartOfQuarter([Date]), type date),
                col_QuarterEND = Table.AddColumn(col_QuarterSTART, "End of Quarter", each Date.EndOfQuarter([Date]), type date),
                col_Quarter_Year = Table.AddColumn(col_QuarterEND, "Quarter & Year", each "Q" & Number.ToText( Date.QuarterOfYear([Date])) & Date.ToText([Date], [Format = " yyyy"]), type text),
                col_QuarterYearINT = Table.AddColumn(col_Quarter_Year, "QuarterYearINT", each [Year] * 10 + [QuarterNUM], type number),
                col_QuarterOFFSET = Table.AddColumn(col_QuarterYearINT, "CurrQuarterOffset", each ((4 * Date.Year([Date])) +  Date.QuarterOfYear([Date])) - ((4 * Date.Year(Date.From(CurrentDate))) +  Date.QuarterOfYear(Date.From(CurrentDate))), type number),
                col_isQuarterComplete = Table.AddColumn(col_QuarterOFFSET, "isQuarterComplete", each Date.EndOfQuarter([Date]) < Date.From(Date.EndOfQuarter(CurrentDate)), type logical),

                col_MonthNUM = Table.AddColumn(col_isQuarterComplete, "MonthNUM", each Date.Month([Date]), type number),
                col_MonthSTART = Table.AddColumn(col_MonthNUM, "Start of Month", each Date.StartOfMonth([Date]), type date),
                col_MonthEND = Table.AddColumn(col_MonthSTART, "End of Month", each Date.EndOfMonth([Date]), type date),
                col_CalendarMONTH = Table.AddColumn(col_MonthEND, "Month & Year", each Text.Proper( Date.ToText([Date], [Format = "MMM yyyy"])), type text),
                col_MonthINT = Table.AddColumn(col_CalendarMONTH , "MonthnYear", each [Year] * 100 + [Month], type number),
                col_MonthOFFSET = Table.AddColumn(col_MonthINT, "CurrMonthOffset", each ((12 * Date.Year([Date])) +  Date.Month([Date])) - ((12 * Date.Year(Date.From(CurrentDate))) +  Date.Month(Date.From(CurrentDate))), type number),
                col_isMonthComplete = Table.AddColumn(col_MonthOFFSET, "MonthCompleted", each Date.EndOfMonth([Date]) < Date.From(Date.EndOfMonth(CurrentDate)), type logical),
                col_MonthNAME = Table.AddColumn(col_isMonthComplete, "Month Name", each Text.Proper( Date.ToText([Date], "MMMM")), type text),
                col_MonthNameSHORT = Table.AddColumn( col_MonthNAME, "Month Short", each Text.Proper( Date.ToText([Date], "MMM")), type text),
                col_MonthNameINITIAL = Table.AddColumn(col_MonthNameSHORT, "Month Initial", each Text.Start([Month Name], 1) & Text.Repeat( Character.FromNumber(8203), Date.Month([Date]) ), type text),
                col_DayMonthNUM = Table.AddColumn(col_MonthNameINITIAL, "Day of Month", each Date.Day([Date]), type number),
            
                col_WeekNUM = Table.AddColumn(col_DayMonthNUM, "Week Number", each
                    if Number.RoundDown((Date.DayOfYear([Date])-(Date.DayOfWeek([Date], Day.Monday)+1)+10)/7)=0
                    then Number.RoundDown((Date.DayOfYear(#date(Date.Year([Date])-1,12,31))-(Date.DayOfWeek(#date(Date.Year([Date])-1,12,31), Day.Monday)+1)+10)/7)
                    else if (Number.RoundDown((Date.DayOfYear([Date])-(Date.DayOfWeek([Date], Day.Monday)+1)+10)/7)=53 and (Date.DayOfWeek(#date(Date.Year([Date]),12,31), Day.Monday)+1<4))
                    then 1 else Number.RoundDown((Date.DayOfYear([Date])-(Date.DayOfWeek([Date], Day.Monday)+1)+10)/7), type number),
                col_WeekSTART = Table.AddColumn(col_WeekNUM, "Start of Week", each Date.StartOfWeek([Date], Day.Monday), type date),
                col_WeekEND = Table.AddColumn(col_WeekSTART, "End of Week", each Date.EndOfWeek( [Date], Day.Monday), type date),
                col_CalendarWEEK = Table.AddColumn(col_WeekEND, "Week & Year", each "W" & Text.PadStart( Text.From( [Week Number] ), 2, "0") & " " & Text.From(Date.Year( Date.AddDays( Date.StartOfWeek([Date], Day.Monday), 3 ))), type text ),
                col_WeekYearINT = Table.AddColumn(col_CalendarWEEK, "WeeknYear", each Date.Year( Date.AddDays( Date.StartOfWeek([Date], Day.Monday), 3 )) * 100 + [Week Number],  Int64.Type),
                col_WeekOFFSET = Table.AddColumn(col_WeekYearINT, "CurrWeekOffset", each (Number.From(Date.StartOfWeek([Date], Day.Monday))-Number.From(Date.StartOfWeek(CurrentDate, Day.Monday)))/7, type number),
                col_isWeekComplete = Table.AddColumn(col_WeekOFFSET, "WeekCompleted", each Date.EndOfWeek( [Date], Day.Monday) < Date.From(Date.EndOfWeek(CurrentDate, Day.Monday)), type logical),
            
                col_DayWeekNUM = Table.AddColumn(col_isWeekComplete, "Day of Week Number", each Date.DayOfWeek([Date], Day.Monday) + WDStart, Int64.Type),
                col_DayNAME = Table.AddColumn(col_DayWeekNUM, "Day of Week Name", each Text.Proper( Date.ToText([Date], "dddd" )), type text),
                col_DayINITIAL = Table.AddColumn(col_DayNAME, "Day of Week Initial", each Text.Proper(Text.Start([Day of Week Name], 1)) & Text.Repeat( Character.FromNumber(8203), Date.DayOfWeek([Date], Day.Monday) + WDStart ), type text),
                col_DayYearNUM = Table.AddColumn(col_DayINITIAL, "Day of Year", each Date.DayOfYear([Date]), Int64.Type),
                col_DayMonthYearINT = Table.AddColumn(col_DayYearNUM, "DateInt", each [Year] * 10000 + [Month] * 100 + [Day of Month], type number),
                col_DayOFFSET = Table.AddColumn(col_DayMonthYearINT, "CurrDayOffset", each Number.From([Date]) - Number.From(CurrentDate), type number),
                col_isAfterToday = Table.AddColumn(col_DayOFFSET, "IsAfterToday", each not ([Date] <= Date.From(CurrentDate)), type logical),
                col_isWeekDay = Table.AddColumn(col_isAfterToday, "IsWeekDay", each if Date.DayOfWeek([Date], Day.Monday) > 4 then false else true, type logical),
                col_isHoliday = Table.AddColumn(col_isWeekDay, "IsHoliday", each if Holidays = null then "Unknown" else List.Contains( Holidays, [Date] ), if Holidays = null then type text else type logical),
                col_isBusinessDay = Table.AddColumn(col_isHoliday, "IsBusinessDay", each if [IsWeekDay] = true and [IsHoliday] <> true then true else false, type logical),
                col_DayTYPE = Table.AddColumn(col_isBusinessDay, "Day Type", each if [IsHoliday] = true then "Holiday" else if [IsWeekDay] = false then "Weekend" else if [IsWeekDay] = true then "Weekday" else null, type text),

                col_ISOYear = Table.AddColumn( col_DayTYPE, "ISO Year", each Date.Year( Date.AddDays( Date.StartOfWeek([Date], Day.Monday), 3 )), type number),
                col_ISOQuarterNUM = Table.AddColumn(col_ISOYear, "ISO QuarterNUM", each if [Week Number] >39 then 4 else if [Week Number] >26 then 3 else if [Week Number] >13 then 2 else 1, Int64.Type),
                col_ISOQuarterNAME = Table.AddColumn(col_ISOQuarterNUM, "ISO Quarter", each "Q" & Number.ToText([ISO QuarterNUM]), type text),
                col_ISOQuarterYearNAME = Table.AddColumn(col_ISOQuarterNAME, "ISO Quarter & Year", each "Q" & Number.ToText([ISO QuarterNUM]) & " " & Number.ToText([ISO Year]), type text),
                col_ISOQuarterYearINT = Table.AddColumn(col_ISOQuarterYearNAME, "ISO QuarterYearINT", each [ISO Year] * 10 + [ISO QuarterNUM], type number),

                // BufferTable = Table.Buffer(Table.Distinct( col_ISOQuarterYearINT[[ISO Year], [DateInt]])),
                // InsertISOday = Table.AddColumn(col_ISOQuarterYearINT, "ISO Day of Year", (OT) => Table.RowCount( Table.SelectRows( BufferTable, (IT) => IT[DateInt] <= OT[DateInt] and IT[ISO Year] = OT[ISO Year])),  Int64.Type),
                col_FY = Table.AddColumn(col_ISOQuarterYearINT, "Fiscal Year", each "FY" & (if [Month] >= FYStartMonth and FYStartMonth >1 then Text.From([Year] +1) else Text.From([Year])), type text),
                //col_FYs = Table.AddColumn(col_FY, "Fiscal Year short", each "FY" & (if [Month] >= FYStartMonth and FYStartMonth >1 then Text.PadEnd( Text.End( Text.From([Year] +1), 2), 2, "0") else Text.End( Text.From([Year]), 2)), type text),
                col_FQ = Table.AddColumn(col_FY, "Fiscal Quarter", each "FQ" & Text.From( Number.RoundUp( Date.Month( Date.AddMonths( [Date], - (FYStartMonth -1) )) / 3 )) & " " & (if [Month] >= FYStartMonth and FYStartMonth >1 then Text.From([Year] +1) else Text.From([Year])), type text),
                col_QtrYrINT = Table.AddColumn(col_FQ, "FQuarternYear", each (if [Month] >= FYStartMonth and FYStartMonth >1 then [Year] +1 else [Year]) * 10 + Number.RoundUp( Date.Month( Date.AddMonths( [Date], - (FYStartMonth -1) )) / 3 ), type number),
                col_FPNUM = Table.AddColumn(col_QtrYrINT, "Fiscal Period Number", each if [Month] >= FYStartMonth and FYStartMonth >1 then [Month] - (FYStartMonth-1) else if [Month] >= FYStartMonth and FYStartMonth =1 then [Month] else [Month] + (12-FYStartMonth+1), type number),
                col_FPYrINT = Table.AddColumn(col_FPNUM, "Fiscal Period", each "FP" & Text.PadStart( Text.From([Fiscal Period Number]), 2, "0") & " " & (if [Month] >= FYStartMonth and FYStartMonth >1 then Text.From([Year] +1) else Text.From([Year])), type text),
                col_FPNUMnYr = Table.AddColumn(col_FPYrINT , "FPeriodnYear", each (if [Month] >= FYStartMonth and FYStartMonth >1 then [Year] +1 else [Year]) * 100 + [Fiscal Period Number], type number),
                var_FiscalCalendarSTART = #date( Date.Year(StartDate)-1, FYStartMonth, 1 ),
                col_FiscalFirstDay = Table.AddColumn( col_FPNUMnYr, "FiscalFirstDay", each if [Month] >= FYStartMonth and FYStartMonth >1 then #date( Date.Year([Date])+1, FYStartMonth, 1) else #date( Date.Year([Date]), FYStartMonth, 1), type date ),

                var_Table = Table.FromList( List.Transform( {Number.From(var_FiscalCalendarSTART) .. Number.From(EndDate)}, Date.From), Splitter.SplitByNothing(), type table [DateFW = Date.Type]),
                col_FFD = Table.AddColumn( var_Table, "FiscalFirstDay", each if Date.Month([DateFW]) < FYStartMonth then #date(Date.Year([DateFW]), FYStartMonth, 1) else #date(Date.Year([DateFW]) + 1, FYStartMonth, 1)),
                col_FWSD = Table.AddColumn( col_FFD, "FWStartDate", each Date.AddYears(Date.StartOfWeek([DateFW], Day.Monday), 1)),
                tbl_Group1 = Table.Group( col_FWSD, {"FiscalFirstDay", "FWStartDate"}, {{"AllRows", each _, type table [DateFW = nullable date, FiscalFirstDay = date, FWStartDate = date]}}),
                tbl_Group2 = Table.Group( tbl_Group1, {"FiscalFirstDay"}, {{"AllRows2", each _, type table [FiscalFirstDay = date, FWStartDate = date, AllRows = table]}}),
                col_Index = Table.AddColumn( tbl_Group2, "Custom", each Table.AddIndexColumn([AllRows2], "Fiscal Week Number", 1, 1) )[[Custom]],
                cols_Expand1 = Table.ExpandTableColumn( col_Index, "Custom", {"FiscalFirstDay", "FWStartDate", "AllRows", "Fiscal Week Number"}, {"FiscalFirstDay", "FWStartDate", "AllRows", "Fiscal Week Number"}), 
                cols_Expand2 = Table.ExpandTableColumn( cols_Expand1, "AllRows", {"DateFW"}, {"DateFW"} )[[DateFW], [Fiscal Week Number]],
                join_Date_DateFW = Table.Join( col_FiscalFirstDay, {"Date"}, cols_Expand2, {"DateFW"}, JoinKind.LeftOuter, JoinAlgorithm.SortMerge ),
                var_FWLogicTest = List.Contains( {null}, FYStartMonthNum),
                txt_Replace = if var_FWLogicTest then Table.ReplaceValue(join_Date_DateFW, each [Fiscal Week Number], each if FYStartMonth =1 then [Week Number] else [Fiscal Week Number], Replacer.ReplaceValue, {"Fiscal Week Number"}) else join_Date_DateFW,
                col_FYW = Table.AddColumn( txt_Replace, "Fiscal Week", each if var_FWLogicTest then "F" & [#"Week & Year"] else if FYStartMonth =1 then "FW" & Text.PadStart( Text.From([Fiscal Week Number]), 2, "0") & Date.ToText([Date], " yyyy") else if Date.Month([Date]) < FYStartMonth then "FW" & Text.PadStart( Text.From([Fiscal Week Number]), 2, "0") & Date.ToText([Date], " yyyy") else "FW" & Text.PadStart(Text.From([Fiscal Week Number]), 2, "0") & " " & Text.From( Date.Year([Date])+1), type text),
                col_FWYearINT = Table.AddColumn(col_FYW, "FWeeknYear", each if var_FWLogicTest then [WeeknYear] else (if FYStartMonth =1 then Date.Year([Date]) else if Date.Month([Date]) < FYStartMonth then Date.Year([Date]) else Date.Year([Date])+1) * 100 + [Fiscal Week Number],  Int64.Type),
                
                rec_CurrentDate = Table.SelectRows(col_FWYearINT, each ([Date] = CurrentDate)),
                var_CurrISOYear = rec_CurrentDate{0}[ISO Year],
                var_CurrISOQtr = rec_CurrentDate{0}[ISO QuarterNUM],
                var_CurrYear = rec_CurrentDate{0}[Year],
                var_CurrMonth = rec_CurrentDate{0}[Month],
                var_FFD = rec_CurrentDate{0}[FiscalFirstDay],
                var_PFFD = Date.AddYears(var_FFD, -1),
                var_CurrFY = rec_CurrentDate{0}[Fiscal Year],
                var_CurrFQ = rec_CurrentDate{0}[FQuarternYear],
                var_CurrFP = rec_CurrentDate{0}[FPeriodnYear],
                var_CurrFW = rec_CurrentDate{0}[FWeeknYear],

                col_ISOYearOFFSET = Table.AddColumn(col_FWYearINT, "ISO CurrYearOffset", each [ISO Year] - var_CurrISOYear, type number),
                col_ISOQuarterOFFSET = Table.AddColumn(col_ISOYearOFFSET, "ISO CurrQuarterOffset", each ((4 * [ISO Year]) +  [ISO QuarterNUM]) - ((4 * var_CurrISOYear) + var_CurrISOQtr), type number),
                col_FiscalYearOFFSET = Table.AddColumn(col_ISOQuarterOFFSET, "Fiscal CurrYearOffset", each try (if [Month] >= FYStartMonth then [Year]+1 else [Year]) - (if var_CurrMonth >= FYStartMonth then var_CurrYear+1 else var_CurrYear) otherwise null, type number),
                col_isCurrFY = Table.AddColumn(col_FiscalYearOFFSET, "IsCurrentFY", each if [Fiscal Year] = var_CurrFY then true else false, type logical),
                col_isCurrFQ = Table.AddColumn(col_isCurrFY, "IsCurrentFQ", each if [FQuarternYear] = var_CurrFQ then true else false, type logical),
                col_isCurrFP = Table.AddColumn(col_isCurrFQ, "IsCurrentFP", each if [FPeriodnYear] = var_CurrFP then true else false, type logical),
                col_isCurrFW = Table.AddColumn(col_isCurrFP, "IsCurrentFW", each if [FWeeknYear] = col_ISOYearOFFSET then true else false, type logical),
                col_isPrevYTD = Table.AddColumn(col_isCurrFW, "IsPYTD", each if var_CurrYear-1 = [Year] and [Day of Year] <= rec_CurrentDate{0}[Day of Year] then true else false, type logical),
                    list_PrevFiscalYearDates = List.Buffer( Table.SelectRows( Table.ExpandTableColumn( Table.NestedJoin(
                        Table.AddIndexColumn( Table.RenameColumns( Table.TransformColumnTypes( Table.FromList( List.Dates( var_PFFD, Number.From(var_FFD-var_PFFD),#duration(1,0,0,0)), Splitter.SplitByNothing()),{{"Column1", type date}}), {{"Column1", "DateFY"}}), "Index", 1, 1), {"Index"}, 
                        Table.AddIndexColumn( Table.RenameColumns( Table.TransformColumnTypes( Table.FromList( List.Dates( Date.AddYears( var_PFFD, -1), Number.From( var_PFFD - Date.AddYears( var_PFFD, -1)),#duration(1,0,0,0)), Splitter.SplitByNothing()),{{"Column1", type date}}), {{"Column1", "DateFY"}}), "Index", 1, 1)
                        , {"Index"}, "Table", JoinKind.LeftOuter), "Table", {"DateFY"}, {"PrevDateFY"}), each [DateFY] <= CurrentDate)[PrevDateFY] ),
                col_isPrevFYTD = Table.AddColumn(col_isPrevYTD, "IsPFYTD", each if [Fiscal CurrYearOffset] = -1 and List.Contains(list_PrevFiscalYearDates, [Date] ) then true else false, type logical),
                col_NetWorkDays = if AddRelativeNetWorkdays = true then Table.AddColumn(col_isPrevFYTD, "Relative Networkdays", each fxNETWORKDAYS( StartDate, [Date], Holidays ), type number ) else col_isPrevFYTD,
                fxNETWORKDAYS = (StartDate, EndDate, optional Holidays as list) =>
                    let
                    list_Dates = List.Dates( StartDate, Number.From(EndDate-StartDate)+1, Duration.From(1) ),
                    DeleteHolidays = if Holidays = null then list_Dates else List.Difference( list_Dates, List.Transform(Holidays, Date.From )),
                    DeleteWeekends = List.Select( DeleteHolidays, each Date.DayOfWeek( _, Day.Monday) < 5 ),
                    CountDays = List.Count( DeleteWeekends)
                    in
                    CountDays,
                cols_RemoveToday = Table.RemoveColumns( if EndDate < CurrentDate then Table.SelectRows(col_NetWorkDays, each ([Date] <> CurrentDate)) else col_NetWorkDays, {"Day of Year", "FiscalFirstDay"}), 
                cols_Format = Table.TransformColumnTypes(cols_RemoveToday,{{"Year", Int64.Type}, {"QuarterNUM", Int64.Type}, {"MonthNUM", Int64.Type}, {"Day of Month", Int64.Type}, {"DateInt", Int64.Type}, {"Day of Week Number", Int64.Type}, {"ISO CurrYearOffset", Int64.Type}, {"ISO QuarterYearINT", Int64.Type}, {"ISO CurrQuarterOffset", Int64.Type}, {"Week Number", Int64.Type}, {"WeeknYear", Int64.Type}, {"MonthnYear", Int64.Type}, {"QuarterYearINT", Int64.Type}, {"FQuarternYear", Int64.Type}, {"Fiscal Period Number", Int64.Type}, {"FPeriodnYear", Int64.Type}, {"CurrWeekOffset", Int64.Type}, {"CurrMonthOffset", Int64.Type}, {"CurrQuarterOffset", Int64.Type}, {"CurrYearOffset", Int64.Type}, {"Fiscal CurrYearOffset", Int64.Type}, {"Fiscal Week Number", Int64.Type}}),
                cols_Reorder = Table.ReorderColumns(cols_Format,{"Date", "Year", "CurrYearOffset", "isYearComplete", "QuarterNUM", "Quarter", "Start of Quarter", "End of Quarter", "Quarter & Year", "QuarterYearINT", "CurrQuarterOffset", "isQuarterComplete", "MonthNUM", "Start of Month", "End of Month", "Month & Year", "MonthnYear", "CurrMonthOffset", "MonthCompleted", "Month Name", "Month Short", "Month Initial", "Day of Month", "Week Number", "Start of Week", "End of Week", "Week & Year", "WeeknYear", "CurrWeekOffset", "WeekCompleted", "Day of Week Number", "Day of Week Name", "Day of Week Initial", "DateInt", "CurrDayOffset", "IsAfterToday", "IsWeekDay", "IsHoliday", "IsBusinessDay", "Day Type", "ISO Year", "ISO CurrYearOffset", "ISO QuarterNUM", "ISO Quarter", "ISO Quarter & Year", "ISO QuarterYearINT", "ISO CurrQuarterOffset", "Fiscal Year", "Fiscal CurrYearOffset", "Fiscal Quarter", "FQuarternYear", "Fiscal Period Number", "Fiscal Period", "FPeriodnYear", "DateFW", "Fiscal Week Number", "Fiscal Week", "FWeeknYear", "IsCurrentFY", "IsCurrentFQ", "IsCurrentFP", "IsCurrentFW", "IsPYTD", "IsPFYTD"}),
                ListCols = if var_FWLogicTest then Table.RemoveColumns(cols_Reorder,{"ISO QuarterNUM", "Fiscal Year", "Fiscal Quarter", "FQuarternYear", "Fiscal Period Number", "Fiscal Period", "FPeriodnYear", "DateFW", "Fiscal Week Number", "Fiscal Week", "FWeeknYear", "Fiscal CurrYearOffset", "IsCurrentFQ", "IsCurrentFP", "IsCurrentFW"}) else Table.RemoveColumns(cols_Reorder,{"Fiscal Period Number", "DateFW", "Fiscal Week Number", "ISO QuarterNUM"})
            in
                ListCols
//in fxCalendar
```
