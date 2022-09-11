```C#
let
  func = (StartDate as date, Days as number, optional Holidays as list) =>                                                                    
let
/* Debug parameters
    StartDate = #date(2008, 10, 1),
    Days = 151,
    //Holidays = {#date(2008,11,26), #date(2008,12,4), #date(2009,1,21)},                                                                     
*/
    Holidays_ = if Holidays = null then 0 else List.Count(Holidays),
    // Create a list of days that span the max possible period                                                          
    ListOfDates =
        if Days >= 0 then
            List.Dates(
                StartDate,
                Number.RoundUp((Days + Holidays_) * (7 / 5) + 2, 0),
                #duration(1, 0, 0, 0)
            )
        else
            let
                EarliestStartDate = Date.From(
                    Number.From(
                        Date.AddDays(StartDate, Number.RoundUp((Days - Holidays_) * (7 / 5) - 2, 0))
                    )
                ),
                Result = List.Dates(
                    EarliestStartDate,
                    Number.From(StartDate - EarliestStartDate),
                    #duration(1, 0, 0, 0)
                )
            in
                Result,
    // if the optional Holidays parameter is used: Keep only those dates in the list that don't occur in the list of Holidays;                                                                                                                          
    // otherwise continue with previous table                                         
    DeleteHolidays = if Holidays = null then ListOfDates else List.Difference(ListOfDates, Holidays),
    // Select only the first 5 days of the week                                             
    // The 1 in the 2nd parameter of Date.DayOfWeek makes sure that Monday will be taken as first day of the week                                                                                                             
    DeleteWeekends = List.Select(DeleteHolidays, each Date.DayOfWeek(_, 1) < 5),
    // Count the number of days (items in the list)                                               
    CountDays =
        if Days >= 0 then
            DeleteWeekends{Days}
        else
            DeleteWeekends{List.Count(DeleteWeekends) + Days},
    //   CountDays = if Days >= 0 then List.Last(DeleteHolidays) else List.First(DeleteHolidays),                                                                                             
    Result = if CountDays = null then StartDate else CountDays
in
    Result,
  documentation = [
Documentation.Name =  " Xls_WORKDAY ",
Documentation.Description = " Returns a number that represents a date that is the indicated number of working days before or after a date (the starting date). ",
Documentation.LongDescription = " Returns a number that represents a date that is the indicated number of working days before or after a date (the starting date). Working days exclude weekends and any dates identified as holidays. ",
Documentation.Category = " Xls.Date ",
Documentation.Source = " www.TheBIcountant.com - https://wp.me/p6lgsG-2sW ",
Documentation.Version = " 1.0 ",
Documentation.Author = " Imke Feldmann ",
Documentation.Examples = {[Description =  "  ",
Code = " let
    StartDate = #date(2008, 10, 1),
    Days = 151,
    Holidays = {#date(2008,11,26), #date(2008,12,4), #date(2009,1,21)},
    Result = Xls_WORKDAY(StartDate, Days, Holidays)
    
in
    Result ",
Result = " #date(2009,5,5) 
  "]}],
  Custom = Value.ReplaceType(func, Value.ReplaceMetadata(Value.Type(func), documentation))
in
  Custom
```
