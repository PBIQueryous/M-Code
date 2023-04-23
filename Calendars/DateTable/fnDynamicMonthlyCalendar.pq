let
  fxDate = (Day as text, Start.Date as date, optional End.Date as date) as table =>
    let
      Dayofmonth = if Day = "All" or Day = "all" then - 2 else if Day = "last" or Day = "Last" then - 1 else Number.FromText(Day),
      StartDate = if Dayofmonth = - 2 then Start.Date else #date(Date.Year(Start.Date), Date.Month(Start.Date), 1),
      EndDate1 = if End.Date = null then DateTime.Date(DateTime.LocalNow()) else End.Date,
      //End.Date = DateTime.Date(DateTime.LocalNow()),                                                
      CYear = Date.Year(EndDate1),
      EndDate = if Dayofmonth = - 2 then EndDate1 else Date.AddDays(Date.EndOfMonth(EndDate1), 1),
      DayBetween = if Dayofmonth = - 2 then 1 else 31,
      NumberOfDays = Duration.Days(EndDate - StartDate) / DayBetween,
      NOM = if Dayofmonth = - 2 then 1 else 0,
      Dates = List.Dates(StartDate, NumberOfDays + NOM, #duration(DayBetween, 0, 0, 0)),
      CTTable = Table.FromList(Dates, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
      RenameC = Table.RenameColumns(CTTable, {{"Column1", "Date"}}),
      ChangeT1 = Table.TransformColumnTypes(RenameC, {{"Date", type date}}),
      AddSDAM = Table.AddColumn(
        ChangeT1,
        "Selected Day Of Month",
        each if Dayofmonth = - 1 then Date.EndOfMonth([Date]) else if Dayofmonth = - 2 then [Date] else Date.AddDays([Date], - 1 * (Date.Day([Date]) - Dayofmonth))
      ),
      AddMMYY = Table.AddColumn(AddSDAM, "Month-Year", each Text.Combine({Date.ToText([Date], "MMM"), "-", Date.ToText([Date], "yy")}), type text),
      RemoveDateC = Table.RemoveColumns(AddMMYY, {"Date"}),
      AddYear = Table.AddColumn(RemoveDateC, "Year", each Date.Year(Date.From([Selected Day Of Month])), Int64.Type),
      AddMonth = Table.AddColumn(AddYear, "Month Number", each Date.Month(Date.From([Selected Day Of Month])), Int64.Type),
      AddMonthN = Table.AddColumn(AddMonth, "Month Name", each Date.MonthName(Date.From([Selected Day Of Month])), type text),
      AddYMNo = Table.AddColumn(
        AddMonthN,
        "Year Month Number",
        each Text.Combine({Date.ToText(Date.From([Selected Day Of Month]), "yyyy"), Date.ToText(Date.From([Selected Day Of Month]), "MM")}),
        type text
      ),
      ChangeT2 = Table.TransformColumnTypes(AddYMNo, {{"Year Month Number", Int64.Type}}),
      SortByDay = Table.Sort(ChangeT2, {{"Selected Day Of Month", Order.Ascending}}),
      ChangeT3 = Table.TransformColumnTypes(SortByDay, {{"Selected Day Of Month", type date}}),
      QuarterNo = Table.AddColumn(ChangeT3, "Quarter", each Date.QuarterOfYear([Selected Day Of Month]), Int64.Type),
      YearQ = Table.AddColumn(QuarterNo, "Year & Quarter", each Text.Combine({Text.From(Date.Year([Selected Day Of Month]), "en-AU"), " Q", Text.From([Quarter], "en-AU")})),
      DayofWeek = Table.AddColumn(YearQ, "Day of Week", each Date.DayOfWeek([Selected Day Of Month]), Int64.Type),
      Dayname = Table.AddColumn(DayofWeek, "Day Of Week Name", each Text.Proper(Date.ToText([Selected Day Of Month], "dddd")), type text),
      StartMonth = Table.AddColumn(Dayname, "First day of month", each Date.StartOfMonth([Selected Day Of Month]), type date),
      LastDay = Table.AddColumn(StartMonth, "Last day of month", each Date.EndOfMonth([Selected Day Of Month]), type date),
      WeekofYear = Table.AddColumn(StartMonth, "Week Of Year", each Date.WeekOfYear([Selected Day Of Month], Day.Monday), Int64.Type),
      DateName = Table.RenameColumns(WeekofYear, {{"Selected Day Of Month", "Date"}})
    in
      DateName,
  Documentation = [
    Documentation.Name = "fxDate",
    Documentation.LongDescription = "Date table function to create a calendar table with a selected day of the month",
    Documentation.Author = "Vahid DM",
    Documentation.Category = "Table",
    Documentation.Version = "0.00",
    Documentation.Examples = {
      [
        Description = "https://www.vahiddm.com/post/creating-calendat-table-with-3-steps ",
        Code
          = " Parameters: #(lf)
     Day: you can enter one of the below items in this field to create your table: #(lf)
      All: If you want to have a calendar table with all dates  #(lf)
      Last: If you want to create a filtered data table with dates of the last day of #(lf)
       each month#(lf)
      number: you can enter a number from 1 to 31 in this field to have a filtered  #(lf)
       data table with the list of the selected day for each month #(lf)
     Start.Date: The first date on the Calendar table #(lf)
     End.Date: This field is an Optional field and has 2 options: #(lf)
      select a date: the date chosen in this field will be the maximum date in your #(lf) 
       calendar table#(lf)
      leave it blank: if you leave this field blank, you will have a Dynamic Calendar #(lf) 
      Table that will use the current date as the End date. #(lf)
     If you Select:[Day.Of.Month]=15,[Start.Date]=20/03/2021,[End.Date]=14/06/2021
     "

      ,
        Result = "{15/03/2021, 15/04/2021,15/05/2021,15/06/2021} "
      ]
    }
  ]
in
  Value.ReplaceType(fxDate, Value.ReplaceMetadata(Value.Type(fxDate), Documentation))
