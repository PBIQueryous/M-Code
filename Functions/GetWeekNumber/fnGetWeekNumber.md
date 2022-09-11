```C#
let
  func = (Date as date, optional Return_type as number) =>
    let
        // For a detailled description about the options of the Return_types see the official documentation: 
        // https://support.microsoft.com/en-us/office/weeknum-function-e5c43a03-b4ab-426c-b411-b18c13c75340
        
        // PQ native Date.WeekFromYear starts to count from 0(Sunday) to 6(Saturday) as opposed to Excel from 1(Sunday) to 7(Saturday)
        ConvertedNumber =
            if Return_type = null then
                0
            else
                Record.Field(
                    [1 = 0, 2 = 1, 11 = 1, 12 = 2, 13 = 3, 14 = 4, 15 = 5, 16 = 6, 17 = 0, 21 = 21],
                    Text.From(Return_type)
                ),
        IsoWeek = // this function comes from r-k-b on Github: https://gist.github.com/r-k-b/18d898e5eed786c9240e3804b167a5ca
            let
                getDayOfWeek = (d as date) =>
                    let
                        result = 1 + Date.DayOfWeek(d, Day.Monday)
                    in
                        result,
                getNaiveWeek = (inDate as date) =>
                    let

                        // monday = 1, sunday = 7                         
                        weekday = getDayOfWeek(inDate),
                        weekdayOfJan4th = getDayOfWeek(#date(Date.Year(inDate), 1, 4)),
                        ordinal = Date.DayOfYear(inDate),
                        naiveWeek = Number.RoundDown((ordinal - weekday + 10) / 7)
                    in
                        naiveWeek,
                thisYear = Date.Year(Date),
                priorYear = thisYear - 1,
                nwn = getNaiveWeek(Date),
                lastWeekOfPriorYear = getNaiveWeek(#date(priorYear, 12, 28)),
                // http://stackoverflow.com/a/34092382/2014893                                              
                lastWeekOfThisYear = getNaiveWeek(#date(thisYear, 12, 28)),
                weekYear =
                    if nwn < 1 then
                        priorYear
                    else if nwn > lastWeekOfThisYear then
                        thisYear + 1
                    else
                        thisYear,
                weekNumber =
                    if nwn < 1 then
                        lastWeekOfPriorYear
                    else if nwn > lastWeekOfThisYear then
                        1
                    else
                        nwn
            in
                Number.RoundDown(weekNumber),
        Default = Date.WeekOfYear(Date, ConvertedNumber),
        Result = if Return_type = 21 then IsoWeek else Default
    in
        Result,
  documentation = [
Documentation.Name =  " Xls.WEEKNUM.pq ",
Documentation.Description = " Returns the week number of a specific date. For example, the week containing January 1 is the first week of the year, and is numbered week 1. Equivalent of the YEARFRAC-Function in Excel. ",
Documentation.LongDescription = " Returns the week number of a specific date. For example, the week containing January 1 is the first week of the year, and is numbered week 1. There are two systems used for this function:
System 1    The week containing January 1 is the first week of the year, and is numbered week 1.
System 2    The week containing the first Thursday of the year is the first week of the year, and is numbered as week 1. This system is the methodology specified in ISO 8601, which is commonly known as the European week numbering system. 
Equivalent of the YEARFRAC-Function in Excel. ",
Documentation.Category = " Xls.Date ",
Documentation.Source = " www.TheBIcountant.com - https://wp.me/p6lgsG-2ta . ",
Documentation.Version = " 1.0 ",
Documentation.Author = " Imke Feldmann ",
Documentation.Examples = {[Description =  "  ",
Code = " let
    Serial_number = #date(2012, 3, 9) , 
    Return_type = 2, 
    FunctionCall = Xls_WEEKNUM(Serial_number, Return_type)
in
    FunctionCall ",
Result = " 11 
  "]}],
  Custom = Value.ReplaceType(func, Value.ReplaceMetadata(Value.Type(func), documentation))
in
  Custom
```
