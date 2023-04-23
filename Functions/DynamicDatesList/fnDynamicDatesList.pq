//-- generate list of dates dynamically in relation to number of payments
    col_ListOfDates = Table.AddColumn(
    cols_Select, 
    "ListOfDates", 
    each 
      let
        zeroPay = [Payments] - 0, // number of payments
        startDate = Date.StartOfMonth([Start Date]),  // start date
        // if number of payments is 0 then return zeroPay variable, otherwise number of payments -1 (less one to compensate for list.generate function
        endDate = Date.EndOfMonth(                    // end date
          Date.AddMonths(startDate, (if [Payments] = 0 then zeroPay else [Payments] - 1))
        ), 
        // generate list of dates between start and end date, incrementally by 1 month
        x3 = List.Generate(() => startDate, each _ <= endDate, each Date.AddMonths(_, 1)), 
        x4 = Table.FromList(
          x3, 
          Splitter.SplitByNothing(), 
          type table [PaymentMonth = Date.Type], 
          null, 
          ExtraValues.Error
        ), 
        
        // insert achievement value against achievement date within the nested table
        x5 = Table.AddColumn(
          x4, 
          "Achievement Value", 
          // NT is the INNER NESTED TABLE
          // if Achievement Payment Month = the PaymentMonth in the Nested Table then inject the Ach Value against it
          (NT) => if [Achievement Payment Month] = NT[PaymentMonth] then [Ach Value] else 0
        )
      in
        x5
  ), 
  expand_ListOfDates = Table.ExpandTableColumn(
    col_ListOfDates, 
    "ListOfDates", 
    {"PaymentMonth", "Achievement Value"}, 
    {"PaymentMonth", "Achievement Value"}
  ),
    cols_Format = Table.TransformColumnTypes(
    expand_ListOfDates, 
    {{"PaymentMonth", type date}, {"Achievement Value", type number}}
  ),
