# fnIntervalDivision

```ioke
let
  customFunction = ( input as any, interval as number, divisor as number) =>
    let
      formula  = Number.RoundAwayFromZero( input / interval, 0 ) * interval, // calculation
      result   = (formula / divisor)     // final result
    in
      result
in
  customFunction
```
