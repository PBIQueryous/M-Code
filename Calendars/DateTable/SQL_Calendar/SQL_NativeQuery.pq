let
    Source = Sql.Databases("localhost\mssqlserver01"),
    #"Contoso 100K" = Source{[Name="Contoso 100K"]}[Data],
    Custom1 = 
        let
    vList = "[2019,2020]",
    vStartDate = "20160101",
    isEnabled = [EnableFolding = true ],
    vRunQuery = Value.NativeQuery( #"Contoso 100K" , 
                "SELECT * FROM Data.Date WHERE [Date] > @StartDate 
                    and [Year] IN (select value from OPENJSON(@yearList))" , 
    [StartDate= vStartDate, yearList = vList ] , isEnabled )
        in
        vRunQuery
in
    Custom1
