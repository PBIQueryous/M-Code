# fnPowerTrim
### function to trim spaces and/or special characters

```c#
let
  fn =  // fnPowerTrim                 
/* ------------------------------ 
  Author: Imran Haq - PBI QUERYOUS
  GitHub: https://github.com/PBIQueryous/M-Code/tree/main/Functions
  Description: Trims spaces and special Characters
  Credits: Ivan Bondarenko
  Link: https://gist.github.com/IvanBond/de5d947421fbfaaf0e8e45c628b01836
  Site: 
 ---------------------------------*/

// invoke function & define parameter inputs
    let
      invokeFn = (inputText as text, optional specialChar as text) =>
        
// ------------------------------------------------------------------
// function transformations
        
            let
              char         = if specialChar = null then " " else specialChar, 
              split        = Text.Split(inputText, char), 
              removeblanks = List.Select(split, each _ <> ""),
              result       = Text.Combine(removeblanks, char)
            in
              result
            , 

// ------------------------------------------------------------------     
// change parameter metadata here
      fnType = type function (
        inputText as (type text meta 
            [
              Documentation.FieldCaption     = " Trim Text in Column ",
              Documentation.FieldDescription     = " Text to Trim: #(lf) Selected Column "
            ]
          ),
        optional specialChar as (
          type text
            meta 
            [
              Documentation.FieldCaption     = " Select Special Character: #(lf) Choose from Dropdown ", 
              Documentation.FieldDescription = " Special Character #(lf) eg: space, colon, semi-colon, hyphen ",
              Documentation.AllowedValues = {" ", ":", ";" ,"-", "_", ","}
            ]
        )
      ) as list,
// ------------------------------------------------------------------
// edit function metadata here
      documentation = 
      [  

          Documentation.Name = " fnPowerTrim ", 
          Documentation.Description = " Cleans leading/trailing and double spaces and optional special character ", 
          Documentation.LongDescription = " Cleans leading/trailing and double spaces and optional special character ", 
          Documentation.Category = " Trim (columns) ", 
          Documentation.Source = "  PBIQUERYOUS  ", 
          Documentation.Version = " 2.4 ", 
          Documentation.Author = " Imran Haq ", 
          Documentation.Examples = 
          {
            [
            Description = "  Cleans leading/trailing and double spaces and optional special character   ",
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
      parameterDocumentation      /* <-- Choose final documentation type */
in
  fn
  ```
