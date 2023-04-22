let
  fn =  // fnMonthlyCalendar
/* ------------------------------ 
  Author: Imran Haq - PBI QUERYOUS
  GitHub: https://github.com/PBIQueryous/M-Code/
  Description: Count number of months between two dates
  Credits: Rick de Goot (Guerilla BI)
  Link: https://gorilla.bi/power-query/date-table-with-monthly-increments/
  Youtube: https://www.youtube.com/watch?v=eqWLcCBxA08
  Site: https://gorilla.bi/
 ---------------------------------*/

// invoke function & define parameter inputs

    
    let
      invokeFn = 
        (
        Start_Year as number ,                  // input start year as integer
        End_Year as number                      // input end year as integer
        )=>
        
// ------------------------------------------------------------------
// function transformations
    let
      startYear = #date(Start_Year, 1, 1),
      endYear = #date(End_Year, 12, 31),
      monthList = 
        List.Generate(() => 
          startYear ,                             // Starting value (start of year input)                 
          each _ <= endYear,                      // Create only when <= end of year output (31st Dec)                  
          each Date.AddMonths(_, 1)),             // add months in between startYear and endYear in increments of 1

      build_Table = Table.FromList(
        monthList, 
        Splitter.SplitByNothing(),                // convert list to table
        type table                                // define table
          [
            Date = Date.Type                      // column "Date" as type date
          ],                          
        null, 
        ExtraValues.Error
      ),

      add_Records = Table.AddColumn(
        build_Table, 
        "_Table", 
        each [
          Year = Date.Year([Date]),                   // add column for year number                          
          Month = Date.MonthName([Date]),             // add column for month name                     
          MonthNUM = Date.Month([Date]),              // add column Month Number                       
          MonthYEAR = Date.ToText([Date], "MMM-yy")   // add column for short Month and Year, e.g. Jan 2023
          ], 
        type [
          Year = number,      // year as number
          Month = text,       // month as text
          MonthNUM = number,  // monthNum as number
          MonthYEAR = text    // monthYear as text
          ]
      ),  

      expandColumns = Table.ExpandRecordColumn(
        add_Records, 
        "_Table", 
        {"Year", "Month", "MonthNUM", "MonthYEAR"}, // expand records to columns
        {"Year", "Month", "MonthNUM", "MonthYEAR"}  // (re)name column headers
      )
    in
      expandColumns
      , 

// ------------------------------------------------------------------     
// change parameter metadata here
      fnType = type function (
        Start_Year as (
          type text
            meta 
            [
              Documentation.FieldCaption     = " Input Start Year: #(lf) (Year Integer) ", 
              Documentation.FieldDescription = " Input Start Year #(lf) eg: 2023 ",
              Documentation.SampleValues = {"2023"}
              // or Documentation.AllowedValues = {"Text1", "Text2", "Etc"} for multiple values in dropdown
              // Formatting.IsMultiLine = true, for text box with multiple-code lines (eg: for native queries)
              // Formatting.IsCode = true, formats text into coding style
            ]
        )
        ,
        End_Year as (
          type text
            meta 
            [
              Documentation.FieldCaption     = " Input End Year: #(lf) (Year Integer) ", 
              Documentation.FieldDescription = " Input End Year #(lf) eg: 2025 ",
              Documentation.SampleValues = {"2025"}
              // or Documentation.AllowedValues = {"Text1", "Text2", "Etc"} for multiple values in dropdown
              // Formatting.IsMultiLine = true, for text box with multiple-code lines (eg: for native queries)
              // Formatting.IsCode = true, formats text into coding style
            ]
        )
      ) as list,
// ------------------------------------------------------------------
// edit function metadata here
      documentation = 
      [  

          Documentation.Name                        = " fnMonthlyCalendar ", 
          Documentation.Description                 = " Generate a calendar in monthly increments between Start & End Year input ", 
          Documentation.LongDescription             = " Generate a calendar in monthly increments between Start & End Year input ", 
          Documentation.Category                    = " Dates ", 
          Documentation.Source                      = "  PBIQUERYOUS  ", 
          Documentation.Version                     = " 1.0 ", 
          Documentation.Author                      = " Imran Haq ", 
          Documentation.Examples = 
          {
            [
            Description = " Generate a calendar in monthly increments between Start & End Year input ",
            Code    = "    fnMonthlyCalendar( Start_Year , End_Year )     ", 
            Result  = "    Table
                      #(lf) ____________________________
                      #(lf) 
                      #(lf) 
                      "
            ]
          }
       
      ]
       ,
       
// ------------------------------------------------------------------
// Choose between Parameter Documentation or Function Documentation
      funtionDocumentation =      // -- function metadata
      Value.ReplaceType(invokeFn, Value.ReplaceMetadata(Value.Type(invokeFn), documentation)),
      
      parameterDocumentation =    // -- parameter metadata
      Value.ReplaceType(invokeFn, fnType) 
    in
// ------------------------------------------------------------------
// select one of the above steps and paste below
      funtionDocumentation      /* <-- Choose final documentation type */
in
  fn
