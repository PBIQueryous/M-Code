# Function Template
### function template with steps to edit parameter and function metadata

```c#
let
  customFunction =  // fnReplaceBlanksRemoveNulls                 
/* ------------------------------ 
  Author: Imran Haq - PBI QUERYOUS
  Description: fnReplaceBlanksRemoveNulls
 ---------------------------------*/

// 1.0: invoke function & define parameter inputs
    let
      invokeFunction = (inputTable as table) =>
        
// ------------------------------------------------------------------
// 2.0: function transformations
    let
      source = inputTable, 
      headers = Table.ColumnNames(source), 
      replacer = Table.ReplaceValue(source, "", null, Replacer.ReplaceValue, headers), 
      cleanser = Table.SelectColumns(
        Table.SelectRows(
          replacer, 
          each not List.IsEmpty(List.RemoveMatchingItems(Record.FieldValues(_), {"", null}))
        ), 
        List.Select(
          Table.ColumnNames(replacer), 
          each List.NonNullCount(Table.Column(replacer, _)) <> 0
        )
      )
    in
      cleanser
    , 

// ------------------------------------------------------------------     
// 3.0: change parameter metadata here
      fnType = type function (
        // 3.0.1: first parameter
        dataInput as (
          type text
            meta 
            [
              Documentation.FieldCaption     = " Select Query: #(lf) Or input previous step ", 
              Documentation.FieldDescription = " Select Query/Step: #(cr,lf) Or input previous step ",
              Documentation.SampleValues = {"Table/Step"}
            ]
        )
       
        // 3.0.2: second parameter
        /* ,
         optional separator as (
          type text
            meta 
            [
              Documentation.FieldCaption     = " Choose Separator Type ", 
              Documentation.FieldDescription = " Recommended to use #(lf) forward slash / ", 
              Documentation.AllowedValues    = {"-", "/"}
            ]
        )
      )  */
   // 3.1: parameter return type   
    ) as list,
// ------------------------------------------------------------------
// 4.0: edit function metadata here
      documentation = 
      [  

          Documentation.Name = " fnReplaceBlanksRemoveNulls ", 
          Documentation.Description = " Replaces blanks and removes null rows and columns ", 
          Documentation.LongDescription = " Replaces blanks and removes null rows and columns ", 
          Documentation.Category = " ETL Category ", 
          Documentation.Source = "  PBIQUERYOUS  ", 
          Documentation.Version = " 1.0 ", 
          Documentation.Author = " Imran Haq ", 
          Documentation.Examples = 
          {
            [
            Description = "  Replaces blanks and removes null rows and columns   ",
            Code    = " fnReplaceBlanksRemoveNulls( prevStep ) ", 
            Result  = 
"
 1. Takes previous step
 2. Replaces blanks with nulls
 3. Removes null rows and columns
 
"

            ]
            /* ,
            [
            Description = "  description   ",
            Code    = " code ", 
            Result  = " result #(cr,lf) new line
                      #(cr,lf) new line #(cr,lf) 2 "
            ] */
          }
       
      ]
       ,
       
// ------------------------------------------------------------------
// 5.0: Choose between Parameter Documentation or Function Documentation
      functionDocumentation =      // -- function metadata
      Value.ReplaceType(invokeFunction, Value.ReplaceMetadata(Value.Type(invokeFunction), documentation)),
      
      parameterDocumentation =    // -- parameter metadata
      Value.ReplaceType(invokeFunction, fnType) 
    in
// ------------------------------------------------------------------
// select one of the above steps and paste below
      functionDocumentation      /* <-- Choose final documentation type */
in
  customFunction
  ```
