# fnLastNMonths
## Is date value within the last N Months

### version 1
```ioke
let
    fn = (inputDate as date, months as number, optional entireMonth as logical) =>

let
    dateColumn = inputDate,
    vToday = Date.From(DateTime.LocalNow()),
   monthTest = if (entireMonth = true) and (months > 0) then true else false,
    test = if monthTest then vToday > Date.AddMonths(Date.StartOfMonth( dateColumn ), months ) else vToday >= Date.AddMonths( dateColumn , months ),
    result = if test then 1 else 0
in
    result

in
    fn
```

### version 2

```ioke
let
    fn = (inputDate as date, months as number, optional entireMonth as logical) =>

let
    numberOfMonths = months *-1,
    dateColumn = inputDate,
    vToday = Date.From(DateTime.LocalNow()),
    monthTest = if (entireMonth = true) and (months > 0) then true else false,
    test = if monthTest then Date.AddMonths(Date.EndOfMonth(vToday), numberOfMonths) > dateColumn else Date.AddMonths(vToday, numberOfMonths) >= dateColumn,
    result = if test then 1 else 0
in
    result

in
    fn
```
