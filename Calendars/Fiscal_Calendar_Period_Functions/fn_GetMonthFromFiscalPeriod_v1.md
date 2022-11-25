# fn_GetMonthFromFiscalPeriod_v1
## Get month number from Fiscal Period

``` ioke

let
  fn =  // fnGetMonthFromFP
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
      invokeFn = (dateColumn as any, fiscalMonthNumber as number) =>
        
// ------------------------------------------------------------------
// function transformations
        let
      fiscalMonthStart = List.Select({1 .. 12}, each _ = fiscalMonthNumber){0}? ?? 1,   // ensure valid number
      fiscalMonthCalc = 10 + fiscalMonthStart,                                          // calculation 1
      calculation = Number.Mod(dateColumn + fiscalMonthCalc , 12) + 1,                  // calculation 2
      Result = calculation                                                              // result
    in
     Result
     , 

// ------------------------------------------------------------------     
// change parameter metadata here
      fnType = type function (
        dateColumn as (
          type any
            meta 
            [
              Documentation.FieldCaption     = " Select Fiscal Period Column ", 
              Documentation.FieldDescription = " Select Fiscal Period Column (eg: [Fiscal Period]) ",
              Documentation.SampleValues = {"[Fiscal Period Column]"}
            ]
        ),
        fiscalMonthNumber as (
          type number
            meta 
            [
              Documentation.FieldCaption     = " Select Fiscal Month Start ", 
              Documentation.FieldDescription = " Fiscal Month { 1..12 } ",
              Documentation.AllowedValues = {1..12}
            ]
        )
      ) as list,
// ------------------------------------------------------------------
// edit function metadata here
      documentation = 
      [  

          Documentation.Name = " fnGetMonthFromFP ", 
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
