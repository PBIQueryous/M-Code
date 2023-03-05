# fn_CleanTextByCase
## clean text string by character transition, including underscores

```ioke

splitText = Table.AddColumn(
                        prevStep, "Custom", each 
                            Text.Combine( 
                            Splitter.SplitTextByCharacterTransition({"a".."z"},{"A".."Z"})
                            (Text.Replace([Column1], "_", ""))
                            , " "
                            ) 
                        )

```


## Using Transform Columns instead of Add Column


```ioke

= Table.TransformColumns(
                      col_ProgrammeDataSource,
                            {{"Aptem Program Status", each Text.Combine( 
                            Splitter.SplitTextByCharacterTransition({"a".."z"},{"A".."Z"})
                            (Text.Replace(_, "_", ""))
                            , " "
                            ), 
                            type text}})
                            
```
