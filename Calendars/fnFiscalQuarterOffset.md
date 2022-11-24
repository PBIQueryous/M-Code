# fnFiscalQuarterOFFSET

``` ioke
= let
  fxAddFiscalQuarterOffset = (Date as date, FiscalYearStartMonth as number) as number =>
    let
      CurrentDate = Date.From(DateTime.LocalNow()), 
      n = 
        if List.Contains({1 .. 12}, FiscalYearStartMonth) and FiscalYearStartMonth > 1 then
          FiscalYearStartMonth - 1
        else
          0, 
      FiscalQuarterOffset = (
        (4 * Date.Year(Date.AddMonths(Date.StartOfMonth(Date), - n)))
          + Date.QuarterOfYear(Date.AddMonths(Date.StartOfMonth(Date), - n))
      )
        - (
          (4 * Date.Year(Date.AddMonths(Date.StartOfMonth(CurrentDate), - n)))
            + Date.QuarterOfYear(Date.AddMonths(Date.StartOfMonth(CurrentDate), - n))
        )
    in
      FiscalQuarterOffset, 
  Documentation = [
    Documentation.Name = " fxAddFiscalQuarterOffset", 
    Documentation.Description = " Add a fiscal quarter offset", 
    Documentation.LongDescription = " M function to add a fiscal quarter offset to your date table", 
    Documentation.Category = " Table", 
    Documentation.Version = " 0.01: Initial version", 
    Documentation.Source = " local", 
    Documentation.Author = " Melissa de Korte", 
    Documentation.Examples = {
      [
        Description = " ", 
        Code
          = " Required paramters: #(lf)
        (Date) The field that contains the unique date value for each date in the date table #(lf) 
        (FiscalYearStartMonth) Month number the fiscal year starts, January if omitted", 
        Result = " "
      ]
    }
  ]
in
  Value.ReplaceType(
    fxAddFiscalQuarterOffset, 
    Value.ReplaceMetadata(Value.Type(fxAddFiscalQuarterOffset), Documentation)
  )

```
