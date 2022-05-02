# fnSpacesTrim
### PowerQuery function
##### Function to trim leading spaces, trailing spaces and/or double (or more) spaces

```C#
let
  fn =  // fnSpacesTrim                 
/* ------------------------------ 
  Author: Imran Haq - PBI QUERYOUS
  GitHub: https://github.com/PBIQueryous/M-Code/tree/main/Functions
  Description: Cleans leading/trailing and double spaces
  Credits: John Macdougall MVP
  Link: https://www.howtoexcel.org/replicate-trim/
  Site: https://www.howtoexcel.org/blog/
 ---------------------------------*/

// invoke function & define parameter inputs
    let
      invokeFn = (TextToTrim) =>
        
// ------------------------------------------------------------------
// function transformations
        let
      ReplacedText = Text.Replace(TextToTrim, "  ", " "),
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
        TextToTrim as (
          type text
            meta 
            [
              Documentation.FieldCaption     = " Select Column: #(lf) Trim Text in Column ", 
              Documentation.FieldDescription = " Select Column to Trim #(lf) eg: Column1 ",
              Documentation.SampleValues = {"Column1"}
            ]
        )
      ) as list,
// ------------------------------------------------------------------
// edit function metadata here
      documentation = 
      [  

          Documentation.Name = " fnCleanSpaces ", 
          Documentation.Description = " Cleans leading/trailing and double spaces ", 
          Documentation.LongDescription = " Cleans leading/trailing and double spaces ", 
          Documentation.Category = " Trim (columns) ", 
          Documentation.Source = "  PBIQUERYOUS  ", 
          Documentation.Version = " 1.0 ", 
          Documentation.Author = " Imran Haq ", 
          Documentation.Examples = 
          {
            [
            Description = "  Cleans leading/trailing and double spaces   ",
            Code    = "    leading   and  trailing spaces     ", 
            Result  = "    leading and trailing spaces
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
