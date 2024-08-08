= DateTime.From(Date.StartOfWeek(#date(Date.Year(DateTime.LocalNow()), 10, 31), Day.Sunday)) + #duration( 0, 2, 0, 0 )
