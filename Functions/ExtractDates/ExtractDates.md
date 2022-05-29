```c#
= Date.FromText( "31122022",   [Format="ddMMyyyy"] )
// Returns #date(2022, 12, 31)
= Date.FromText( "12312022",   [Format="MMddyyyy"] )
// Returns #date(2022, 12, 31)
= Date.FromText( "20223112",   [Format="yyyyddMM"] )
// Returns #date(2022, 12, 31)
= Date.FromText( "12-31-2022", [Format="MM-dd-yyyy"] )
// Returns #date(2022, 12, 31)
= Date.FromText( "2022-31-12", [Format="yyyy-dd-MM"] )
// Returns #date(2022, 12, 31)
= Date.FromText( "31*12*2022", [Format="dd*MM*yyyy"] )
// Returns #date(2022, 12, 31)
= Date.FromText( "31.*12.*22", [Format="dd.*MM.*yy"] )
// Returns #date(2022, 12, 31)
```

```c#
= Date.FromText("30 Mrt 2022", [Format="dd MMM yyyy"])
// Returns an error, PQ does not recognize Mrt as March

= Date.FromText("30 Mrt 2022", [Format="dd MMM yyyy", Culture="nl-NL"])
// Returns #date( 2022, 3, 30). Mrt = March in Dutch

= Date.FromText("30 Maart 22", [Format="dd MMMM yy", Culture="nl-NL"])
// Returns #date( 2022, 3, 30). Maart = March in Dutch

= Date.FromText("30 juin 2022", [Format="dd MMM yyyy"])
// Returns an error, PQ does not recognize juin as June

= Date.FromText("30 juin 2022", [Format="dd MMM yyyy", Culture="fr-FR"])
// Returns #date( 2022, 6, 30 ), juin = June in French
```
