# fnName
### PowerQuery function
##### description

```C#
let
  fn =  // fnName
/* ------------------------------ 
  Author: Imran Haq - PBI QUERYOUS
  GitHub: https://github.com/PBIQueryous/M-Code/
  Description: 
  Credits: 
  Link: 
  Site: 
 ---------------------------------*/

// invoke function & define parameter inputs
    let
      invokeFn = (exampleInput) =>
        
// ------------------------------------------------------------------
// function transformations
        let
      ReplacedText = Text.Replace(exampleInput, "  ", " "),
      Result =
        if not (Text.Contains(ReplacedText, "  ")) then
          ReplacedText
        else
          @invokeFn(ReplacedText)
    in
      Text.Trim(Result), 

// ------------------------------------------------------------------     
// change parameter metadata here
      fnType = type function (
        exampleInput as (
          type text
            meta 
            [
              Documentation.FieldCaption     = " Select Column: #(lf) Trim Text in Column ", 
              Documentation.FieldDescription = " Select Column to Trim #(lf) eg: Column1 ",
              Documentation.SampleValues = {"Column1"}
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

          Documentation.Name = " fnName ", 
          Documentation.Description = " ExampleDescription ", 
          Documentation.LongDescription = " ExampleDescription ", 
          Documentation.Category = " Trim (columns) ", 
          Documentation.Source = "  PBIQUERYOUS  ", 
          Documentation.Version = " 1.0 ", 
          Documentation.Author = " Imran Haq ", 
          Documentation.Examples = 
          {
            [
            Description = "  ExampleDescription   ",
            Code    = "    ExampleInput     ", 
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
      funtionDocumentation      /* <-- Choose final documentation type */
in
  fn
```
