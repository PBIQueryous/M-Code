# fn_GetMonthFromFiscalPeriod
## Get calendar month number from fiscal period number

``` ioke

let
  function1 =  // fnGetCalendarMonth                 
/* ------------------------------ 
  Author: Imran Haq - PBI QUERYOUS
  Description: Get Calendar Month Number from Fiscal Period Number
 ---------------------------------*/

// invoke function & define parameter inputs
    let
      invokeFunction = (fiscalPeriod as any, fiscalStart as number) =>
        
// ------------------------------------------------------------------
// function transformations
      let    
        fiscalMonth = if fiscalStart = null then 1 else fiscalStart,    // if null then 1 else fiscal month number
        columnName = fiscalPeriod,                                      // fiscal month column
        calc = (12-fiscalMonth)+1,                                      // calculation
        x = Number.Abs(columnName + fiscalMonth) - 1,                   
        y = Number.Abs(columnName + fiscalMonth) - 13,
        z = if columnName <= calc then x else y                         // if FiscalPeriod <= Calculation then x else y
      in 
      z
    , 

// ------------------------------------------------------------------     
// change parameter metadata here
      fnType = type function (
        fiscalPeriod as (
          type any
            meta 
            [
              Documentation.FieldCaption     = " Choose column with Fiscal Month number ", 
              Documentation.FieldDescription = " Select a column #(cr,lf) eg: [Fiscal Month] ",
              Documentation.SampleValues = {"[FiscalMonth]"}
            ]
        ), 
        fiscalStart as (
          type number
            meta 
            [
              Documentation.FieldCaption     = " Choose Fiscal Month Start ", 
              Documentation.FieldDescription = " Fiscal Month Start #(cr,lf) Choose a month number ", 
              Documentation.AllowedValues    = {1..12}
            ]
        )
      ) as list,
// ------------------------------------------------------------------
// edit function metadata here
      documentation = 
      [  

          Documentation.Name = " fnGetCalendarMonth ", 
          Documentation.Description = " Retrieves correct calendar month based on a fiscal period number  ", 
          Documentation.LongDescription = " Retrieves correct calendar month based on a fiscal period number ", 
          Documentation.Category = " Fiscal Calendar Category ", 
          Documentation.Source = "  PBIQUERYOUS  ", 
          Documentation.Version = " 1.0 ", 
          Documentation.Author = " Imran Haq ", 
          Documentation.Examples = 
          {
            [
            Description = "  ColumnName = [Column1]; Fiscal Month Start = 4   ",
            Code    = " 
            let #(cr,lf)    
              fiscalMonth = if fiscalStart = null then 1 else fiscalStart, #(cr,lf)
              columnName = fiscalPeriod, #(cr,lf)
              calc = (12-fiscalMonth)+1, #(cr,lf)
              x = Number.Abs(columnName + fiscalMonth) - 1, #(cr,lf)
              y = Number.Abs(columnName + fiscalMonth) - 13, #(cr,lf)
              z = if columnName <= calc then x else y #(cr,lf)
            in  #(cr,lf)
            z 
            ", 
            Result  = " fnGetCalendarMonth([Column1], 4) "
            ]
          }
       
      ]
       ,
       
// ------------------------------------------------------------------
// Choose between Parameter Documentation or Function Documentation
      functionDocumentation =      // -- function metadata
      Value.ReplaceType(invokeFunction, Value.ReplaceMetadata(Value.Type(invokeFunction), documentation)),
      
      parameterDocumentation =    // -- parameter metadata
      Value.ReplaceType(invokeFunction, fnType) 
    in
// ------------------------------------------------------------------
// select one of the above steps and paste below
      parameterDocumentation      /* <-- Choose final documentation type */
in
  function1

```
