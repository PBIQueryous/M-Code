# fnGetCalendarMonth
### PowerQuery function
##### Function to retrieve Calendar Month for a list of Fiscal Periods ordered by Fiscal Start Month

```C#

let
  fn =  // fnFiscalPeriodToMonth
/* ------------------------------ 
  Author: Imran Haq - PBI QUERYOUS
  GitHub: https://github.com/PBIQueryous/M-Code/
  Description: Takes Fiscal Period and Converts to Month Number
  Credits: Gilbert Quevauvilliers
  Link: https://gqbi.wordpress.com/2016/09/13/power-bi-how-to-easily-create-dynamic-date-tabledimension-with-fiscal-attributes-using-power-query/comment-page-1/
  Site: https://gqbi.wordpress.com/
 ---------------------------------*/

// invoke function & define parameter inputs
    let
      invokeFn = (fiscalMonthNumber as number, dateColumn as any) =>
        
// ------------------------------------------------------------------
// function transformations
        let
      fiscalMonthStart = fiscalMonthNumber,
      fiscalMonthCalc = 10 + fiscalMonthStart,
      calculation = Number.Mod(dateColumn + fiscalMonthCalc , 12) + 1, 
      Result = calculation
    in
     Result
     , 

// ------------------------------------------------------------------     
// change parameter metadata here
      fnType = type function (
        exampleInput as (
          type number
            meta 
            [
              Documentation.FieldCaption     = " Fiscal Month Number ", 
              Documentation.FieldDescription = " Input Fiscal Month Start Number ",
              Documentation.SampleValues = {"123"}
            ]
        ),
        column1 as (
          type any
            meta 
            [
              Documentation.FieldCaption     = " Select Fiscal Period Column ", 
              Documentation.FieldDescription = " Select Fiscal Period Column (eg: [Column1]) ",
              Documentation.SampleValues = {"[Column1]"}
            ]
        )
      ) as list,
// ------------------------------------------------------------------
// edit function metadata here
      documentation = 
      [  

          Documentation.Name = " fnFiscalPeriodToMonth ", 
          Documentation.Description = " Takes Fiscal Period and Converts to Month Number ", 
          Documentation.LongDescription = " Takes Fiscal Period and Converts to Month Number ", 
          Documentation.Category = " Fiscal Date ", 
          Documentation.Source = "  PBIQUERYOUS  ", 
          Documentation.Version = " 1.0 ", 
          Documentation.Author = " Imran Haq ", 
          Documentation.Examples = 
          {
            [
            Description = "  ExampleDescription   ",
            Code    = "    = Number.Mod(dateColumn + fiscalMonthCalc , 12)+1     ", 
            Result  = "    ExampleOutput
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
      parameterDocumentation      /* <-- Choose final documentation type */
in
  fn

```
