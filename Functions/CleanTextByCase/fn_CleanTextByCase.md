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
