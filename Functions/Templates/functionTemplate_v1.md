# Function Template with meta
### Function template with editable parameter/function metadata
##### blank template

```C#
let
  function1 =  // fnFunctionName                 
/* ------------------------------ 
  Author: Imran Haq - PBI QUERYOUS
  Description: 
 ---------------------------------*/

// invoke function & define parameter inputs
    let
      invokeFunction = (dataInput as text, optional separator as text) =>
        
// ------------------------------------------------------------------
// function transformations
        let    
          step1 = dataInput,
          step2 = step1,
          step3 = step2,
          step4 = step3
          ,
          functionOutput = step4
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
              Documentation.AllowedValues    = {"-", "/"}
            ]
        )
      ) as list,
// ------------------------------------------------------------------
// edit function metadata here
      documentation = 
      [  

          Documentation.Name = " function name ", 
          Documentation.Description = " Description ", 
          Documentation.LongDescription = " Long Description ", 
          Documentation.Category = " Function Category ", 
          Documentation.Source = "  PBIQUERYOUS  ", 
          Documentation.Version = " 1.0 ", 
          Documentation.Author = " Imran Haq ", 
          Documentation.Examples = 
          {
            [
            Description = "  description   ",
            Code    = " code ", 
            Result  = " result #(lf) new line
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
      parameterDocumentation      /* <-- Choose final documentation type */
in
  function1
```
