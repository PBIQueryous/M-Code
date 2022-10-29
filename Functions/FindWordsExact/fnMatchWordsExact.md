```JSONC

let
  Source =  (Column as any, WordList as any, optional InsertList) =>
// choose column, manually type list of words seperated by comma "word1,word2,word3", if no manual list, use external word list)
  let
    Checks      = if WordList = null then InsertList // checks if WordList is null, then returns a pre-defined list of your choice
                  else Text.Split(WordList, ","), 
    Values      = Text.Split(Column, " "),      // check againt each cell in the select column
    Result      = List.ContainsAny(Values, Checks)     // return result
  in
    Result
in
    Source
    
```
