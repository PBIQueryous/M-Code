# fnCountMonths
## Count number of motnhs between two dates

```ioke

let
  fn =  // fnCountMonths
/* ------------------------------ 
  Author: Imran Haq - PBI QUERYOUS
  GitHub: https://github.com/PBIQueryous/M-Code/
  Description: Count number of months between two dates
  Credits: 
  Link: 
  Site: 
 ---------------------------------*/

// invoke function & define parameter inputs

    
    let
      invokeFn = (StartDate as date , EndDate as date)=>
        
// ------------------------------------------------------------------
// function transformations
        let
MonthsList =
            List.Generate(
                () => [ DateValue = Date.From( StartDate ) ],
                each [DateValue] <= Date.From( EndDate ),
                each [ DateValue = Date.AddMonths( [DateValue] , 1 ) ],
                each [DateValue]
            ),
    MonthsCount = Int64.From( List.Count( MonthsList ))
in
    MonthsCount
      , 

// ------------------------------------------------------------------     
// change parameter metadata here
      fnType = type function (
        StartDate as (
          type text
            meta 
            [
              Documentation.FieldCaption     = " Select Column: #(lf) Date Column ", 
              Documentation.FieldDescription = " Select Date Column #(lf) eg: Start Date ",
              Documentation.SampleValues = {"23/01/2023"}
              // or Documentation.AllowedValues = {"Text1", "Text2", "Etc"} for multiple values in dropdown
              // Formatting.IsMultiLine = true, for text box with multiple-code lines (eg: for native queries)
              // Formatting.IsCode = true, formats text into coding style
            ]
        )
        ,
        EndDate as (
          type text
            meta 
            [
              Documentation.FieldCaption     = " Select Column: #(lf) Date Column ", 
              Documentation.FieldDescription = " Select Date Column #(lf) eg: End Date ",
              Documentation.SampleValues = {"31/12/2023"}
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

          Documentation.Name = " fnCountMonths ", 
          Documentation.Description = " Count number of months between two dates ", 
          Documentation.LongDescription = " Count number of months between two dates ", 
          Documentation.Category = " Dates ", 
          Documentation.Source = "  PBIQUERYOUS  ", 
          Documentation.Version = " 1.0 ", 
          Documentation.Author = " Imran Haq ", 
          Documentation.Examples = 
          {
            [
            Description = "  Count number of months between two dates   ",
            Code    = "    fnCountMonths( StartDate , EndDate )     ", 
            Result  = "    Table
                      #(lf) ____________________________
                      #(lf) 01/01/2023 | 01/03/2023 | 3
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

```
