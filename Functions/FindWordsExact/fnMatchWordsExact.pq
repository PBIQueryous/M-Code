
let
  customFunction =  // fnMatchExactWords                 
/* ------------------------------ 
  Author: Imran Haq - PBI QUERYOUS
  Description: fnMatchExactWords
 ---------------------------------*/

// 1.0: invoke function & define parameter inputs
    let
      invokeFunction = (Column as any, WordList as any, optional InsertList as any) =>
        
// ------------------------------------------------------------------
// 2.0: function transformations
    let
    // checks if WordList is null, then returns a pre-defined list of your choice
    ListWords      = if InsertList <> null then InsertList else if WordList = null then InsertList else Text.Split(WordList, ","), 
    
    ColumnValues      = Text.Split(Column, " "),      // check againt each cell in the select column
    
    Result      = List.ContainsAny(ColumnValues, ListWords)     // return result
  in
    Result
    , 

// ------------------------------------------------------------------     
// 3.0: change parameter metadata here
      fnType = type function (
        // 3.0.1: first parameter
        Column as (
          type any
            meta 
            [
              Documentation.FieldCaption     = " Select Column: #(lf) Column from Table ", 
              Documentation.FieldDescription = " Select Table Column: #(cr,lf) Column from Table ",
              Documentation.SampleValues = {"[ColumnName]"}
            ]
        )
       
        // 3.0.2: second parameter
        ,
         WordList as (
          type list
            meta 
            [
              Documentation.FieldCaption     = " Type manual list of words ", 
              Documentation.FieldDescription = " Words #(lf) Separated by comma, no spaces, no speech marks ", 
              Documentation.SampleValues    = {"Word1, Word2, Word3"}
            ]
        )
      

      // 3.0.3: third parameter
        ,
         optional InsertList as (
          type list
            meta 
            [
              Documentation.FieldCaption     = " pre-defined list object ", 
              Documentation.FieldDescription = " List object #(lf) { 'Word1', 'Word2'} ", 
              Documentation.SampleValues    = {"{ Word1, Word2, Word3 }"}
            ]
        )
      

   // 3.1: parameter return type   
    ) as list,
// ------------------------------------------------------------------
// 4.0: edit function metadata here
      documentation = 
      [  

          Documentation.Name = " fnMatchExactWords ", 
          Documentation.Description = " Finds exact matches of list of words in each cell ", 
          Documentation.LongDescription = " Finds exact matches of list of words in each cell ", 
          Documentation.Category = " ETL Category ", 
          Documentation.Source = "  PBIQUERYOUS  ", 
          Documentation.Version = " 1.0 ", 
          Documentation.Author = " Imran Haq ", 
          Documentation.Examples = 
          {
            [
            Description = "  Finds exact matches of list of words in each cell   ",
            Code    = " fnMatchExactWords( [ColumName], WordList, null ) ", 
            Result  = 
"
 1. Create New Function Step
 2. Type function and complete parameters
    2a. fnMatchExactWords( [ColumName], {Canada,Germany}, null )
    2b. fnMatchExactWords( [ColumName], {Canada,Germany}, ListOfWords )
    2c. fnMatchExactWords( [ColumName], null, ListOfWords )

 
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
      Value.ReplaceType(invokeFunction, Value.ReplaceMetadata( Value.Type(invokeFunction), documentation)),
      
      parameterDocumentation =    // -- parameter metadata
      Value.ReplaceType(invokeFunction, fnType),
      
      replaceMeta =               // -- both metas
        Value.ReplaceType(
          Value.ReplaceType( invokeFunction, fnType ),
          Value.ReplaceMetadata( Value.Type(invokeFunction), documentation)
        ) 
    in
// ------------------------------------------------------------------
// select one of the above steps and paste below
      replaceMeta      /* <-- Choose final documentation type */
      
in
  customFunction
    
