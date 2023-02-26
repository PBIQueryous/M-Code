# fn Find Words & Text Strings

## fn_ExactWordMatch
```ioke
let
  customFunction =  // fn_ExactWordMatch                 
/* ------------------------------ 
  Author: Imran Haq - PBI QUERYOUS
  Description: fn_ExactWordMatch
 ---------------------------------*/

// 1.0: invoke function & define parameter inputs
    let
      invokeFunction = (Column as any, WordList as any, optional InsertList as any) =>
        
// ------------------------------------------------------------------
// 2.0: function transformations
    let
    // checks if WordList is null, then returns a pre-defined list of your choice
    // SplitText , ListExactWords
    ListExactWords = "" & WordList & "",
    ListWords      = 
      if InsertList <> null then InsertList     // check first for predefined list
      else if WordList = null then InsertList   // if no manual word list exists then use predefined list
      else Text.Split( ListExactWords, ","),           // otherwise use manaul input list and separate by comma
    
    ColumnValues = Text.Split(Column, " "), // check selected column, split words by space, check exact match words
    
    Result      = List.ContainsAny( ColumnValues , ListWords )     // check if any of the listed words appear in the column
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

          Documentation.Name = " fn_ExactWordMatch ", 
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
    2a. fn_ExactWordMatch( [ColumName], {""Germany,France""}, null )
    2b. fn_ExactWordMatch( [ColumName], {""Russia,United Kingdom""}, ListOfWords )
    2c. fn_ExactWordMatch( [ColumName], null, ListOfWords )

 
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
```

## fn_SubstringsMatch
```ioke
let
  customFunction =  // fn_SubstringMatch                 
/* ------------------------------ 
  Author: Imran Haq
  AKA: PBI QUERYOUS
  Description: fn_SubstringMatch
 ---------------------------------*/

// 1.0: invoke function & define parameter inputs
    let
      invokeFunction = (Column as any, WordList as any, optional InsertList as any) =>
        
// ------------------------------------------------------------------
// 2.0: function transformations
let
// checks if WordList is null, then returns a pre-defined list of your choice  
      ListWords =                                                                        
      // define list of text strings to check for
      if InsertList <> null then InsertList       // check for predefined list  
      else if WordList = null                     // if predefined list is null then check manually list of strings
      then InsertList                             // if manual word list is empty, return predefined list
      else Text.Split(WordList, ","),             // finally use manual list and split by comma separator
      
      Result =  // function proper                               
      
      List.AnyTrue( 
        List.Transform(
          ListWords,                              // use above defined list
          (substring) =>                          // convert to substring parameter
            Text.Contains(
              (Column),                           // selected column
              substring,                          // substring list
              Comparer.OrdinalIgnoreCase          // case insensitive
            )                   
        )
      )
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
              Documentation.FieldCaption     = " Type manual list of substrings ", 
              Documentation.FieldDescription = " Words #(lf) Separated by comma, no spaces, no speech marks ", 
              Documentation.SampleValues    = {"{ ""Word1"", ""Word2"", ""Word3""} "}
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

          Documentation.Name = " fn_SubstringMatch ", 
          Documentation.Description = " Finds matches of list of substrings in each cell ", 
          Documentation.LongDescription = " Finds matches of list of substrings in each cell ", 
          Documentation.Category = " ETL Category ", 
          Documentation.Source = "  PBIQUERYOUS  ", 
          Documentation.Version = " 1.0 ", 
          Documentation.Author = " Imran Haq ", 
          Documentation.Examples = 
          {
            [
            Description = "  Finds exact matches of list of words in each cell   ",
            Code    = " fn_SubstringMatch( [ColumName], Manual Text as List, Pre-defined List ) ", 
            Result  = 
"
 1. Create New Function Step
 2. Type function and complete parameters
    2a. fn_SubstringMatch( [ColumName], {""United"",""Fra""}, null )
    2b. fn_SubstringMatch( [ColumName], {""States"",""Ameri""}, ListOfWords )
    2c. fn_SubstringMatch( [ColumName], null, ListOfWords )

 
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
```

## fn_ExactPhrasesMatch
```ioke
let
  customFunction =  // fn_ExactPhraseMatch                 
/* ------------------------------ 
  Author: Imran Haq - PBI QUERYOUS
  Description: fn_ExactPhraseMatch
 ---------------------------------*/

// 1.0: invoke function & define parameter inputs
    let
      invokeFunction = (Column as any, WordList as any, optional InsertList as any) =>
        
// ------------------------------------------------------------------
// 2.0: function transformations
    let
    // checks if WordList is null, then returns a pre-defined list of your choice

    ListExactWords = "" & WordList & "",
    ListWords      = 
      if InsertList <> null then InsertList     // check first for predefined list
      else if WordList = null then InsertList   // if no manual word list exists then use predefined list
      else Text.Split( ListExactWords, ","),    // otherwise use manaul input list and separate by comma
    
    ColumnValues = Text.Split(Column, ","),     // check selected column, split words by space, check exact match words
    
    // List.ContainsAny( {"Country of the World", "France"} , { [Country] } )
    Result      = List.ContainsAny( ListWords , ColumnValues )     // check if any of the listed words appear in the column
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

          Documentation.Name = " fn_ExactPhrase ", 
          Documentation.Description = " Finds exact matches of complete text phrase in each cell ", 
          Documentation.LongDescription = " Finds exact matches of complete text phrase in each cell ", 
          Documentation.Category = " ETL Category ", 
          Documentation.Source = "  PBIQUERYOUS  ", 
          Documentation.Version = " 1.0 ", 
          Documentation.Author = " Imran Haq ", 
          Documentation.Examples = 
          {
            [
            Description = "  Finds exact matches of complete text phrase in each cell   ",
            Code    = " fnMatchExactWords( [ColumName], ""Phrase1,Phrase2,Phrase3"", null ) ", 
            Result  = 
"
 1. Create New Function Step
 2. Type function and complete parameters
    2a. fn_ExactPhraseMatch( [ColumName], {""Germany,France""}, null )
    2b. fn_ExactPhraseMatch( [ColumName], {""Russia,United Kingdom""}, ListOfWords )
    2c. fn_ExactPhraseMatch( [ColumName], null, ListOfWords )

 
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
```
