= DateTime.From(Date.StartOfWeek(#date(Date.Year(DateTime.LocalNow()), 3, 31), Day.Sunday)) + #duration( 0, 1, 0, 0 )
