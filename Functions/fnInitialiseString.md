```C#
let fn =
  (columnInput) =>

let
  initials = Text.Combine(List.Transform( Splitter.SplitTextByDelimiter(" ", QuoteStyle.None)(columnInput) , each Text.Start(_, 1))),
  lastword = List.Reverse(  Splitter.SplitTextByDelimiter(" ", QuoteStyle.None)(columnInput)){0},
  combine = Text.Combine( { Text.From(initials), Text.From(lastword) } , "-")

in
  combine

in
  fn
  ```
