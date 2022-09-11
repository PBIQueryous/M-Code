```c#
let
  function1 =  // fnDateFromPeriod                 
/* ------------------------------ 
  Author: Imran Haq - PBI QUERYOUS
  Description: 
 ---------------------------------*/

// invoke function & define parameter inputs
    let
      invokeFunction = (dataInput as any) =>
        
// ------------------------------------------------------------------
// function transformations
        let    
          step1 = dataInput,
          step2 = Number.From(Text.BeforeDelimiter(step1, "/")),
          step3 = Number.From(Text.AfterDelimiter(step1, "Q")),
          step4 =  if _quarter = 1 then 4
              else if _quarter = 2 then 7
              else if _quarter = 3 then 10
              else if _quarter = 4 then 1
              else  null,
          step5 = if _quarter = 4 then Date.From("1-" & Text.From(_fix) & "-" & Text.From(_year + 1))
              else Date.From("1-" & Text.From(_fix) & "-" & Text.From(_year))
          ,
// consolidate last transformation step          
          functionOutput = step5
        in
          functionOutput, 

// ------------------------------------------------------------------     
// change parameter metadata here
      fnType = type function (
        dataInput as (
          type text
            meta 
            [
              Documentation.FieldCaption     = " type text: #(lf) see example in field ", 
              Documentation.FieldDescription = " type a dummy integer date #(lf) eg: 31122022 ",
              Documentation.SampleValues = {31122022}
            ]
        ), 
        optional separator as (
          type text
            meta 
            [
              Documentation.FieldCaption     = " Choose Separator Type ", 
              Documentation.FieldDescription = " Recommended to use #(lf) forward slash / ", 
              Documentation.AllowedValues    = {"","-", "/"}
            ]
        )
      ) as list,
// ------------------------------------------------------------------
// edit function metadata here
      documentation = 
      [  

          Documentation.Name = " fnDateFromPeriod ", 
          Documentation.Description = " Converts Period YYYY/YYYY QQ to date format DD/MM/YYYY ", 
          Documentation.LongDescription = " Converts Period YYYY/YYYY QQ to date format DD/MM/YYYY ", 
          Documentation.Category = " Dates ", 
          Documentation.Source = "  PBIQUERYOUS  ", 
          Documentation.Version = " 1.0 ", 
          Documentation.Author = " Imran Haq ", 
          Documentation.Examples = 
          {
            [
            Description = "  description   ",
            Code    = " 2021/2022 Q4 ", 
            Result  = " result #(lf) 1/1/2022
                      #(lf) new line #(lf) 2 "
            ]
          }
       
      ]
       ,
       
// ------------------------------------------------------------------
// Choose between Parameter Documentation or Function Documentation
      funtionDocumentation =      // -- function metadata
      Value.ReplaceType(invokeFunction, Value.ReplaceMetadata(Value.Type(invokeFunction), documentation)),
      
      parameterDocumentation =    // -- parameter metadata
      Value.ReplaceType(invokeFunction, fnType) 
    in
// ------------------------------------------------------------------
// select one of the above steps and paste below
      funtionDocumentation      /* <-- Choose final documentation type */
in
  function1
```
