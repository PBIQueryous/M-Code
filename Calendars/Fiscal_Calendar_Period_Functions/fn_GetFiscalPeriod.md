# fn_GetFiscalPeriod
## Get Fiscal Period Number from Calendar Month Number

``` ioke

let
  function1 =  // fnGetFiscalPeriod                 
/* ------------------------------ 
  Author: Imran Haq - PBI QUERYOUS
  Description: Get Fiscal Period from Month Number column
 ---------------------------------*/

// invoke function & define parameter inputs
    let
      invokeFunction = (monthNum as any, fiscalMonthNum as nullable number) =>
        
// ------------------------------------------------------------------
// function transformations
      let    
        arg1 = monthNum >= fiscalMonthNum and fiscalMonthNum > 1,   // 1st argument
        res1 = monthNum - (fiscalMonthNum - 1),                     // 1st result
        arg2 = monthNum >= fiscalMonthNum and fiscalMonthNum = 1,   // 2nd argument
        res2 = monthNum,                                            // 2nd result
        res3 = monthNum + (12-fiscalMonthNum+1),                    // 3rd result
        result = if arg1 then res1 else if arg2 then res2 else res3 // final result
        in
        result

    , 

// ------------------------------------------------------------------     
// change parameter metadata here
      fnType = type function (
        monthNum as (
          type any
            meta 
            [
              Documentation.FieldCaption     = " Select column with Month Number ", 
              Documentation.FieldDescription = " Select a column #(cr,lf) eg: [Month Number] ",
              Documentation.SampleValues = {"[MonthNumber]"}
            ]
        ), 
        fiscalMonthNum as (
          type number
            meta 
            [
              Documentation.FieldCaption     = " Choose Fiscal Month Start ", 
              Documentation.FieldDescription = " Fiscal Month Start #(cr,lf) (eg: Aug = 8) ", 
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
