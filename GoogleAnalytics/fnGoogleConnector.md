# Google Analytics
### fnGoogleConnector
get data from Google analytics, (un)comment out variables

```C#
let 
fnGetGAData = (   //fnGetGAData: see code to check dimensions/measures
        
            AccountId as text, // Account GUID
            PropertyId as text, // Property GUID
            ViewId as text // View GUID
        )   =>
let
    Source = GoogleAnalytics.Accounts(),
    Account = Source{[Id=AccountId]}[Data],
    Property = Account{[Id=PropertyId]}[Data],
    View = Property{[Id=ViewId]}[Data],
    
    //** DIMENSIONS **//
    // Date Dimension
    vDate = {Cube.AddAndExpandDimensionColumn, "ga:date", {"ga:date"}, {"Date"}},
    vUserType = {Cube.AddAndExpandDimensionColumn, "ga:userType", {"ga:userType"}, {"User Type"}},
    vGender = {Cube.AddAndExpandDimensionColumn, "ga:userGender", {"ga:userGender"}, {"Gender"}},
    vAge = {Cube.AddAndExpandDimensionColumn, "ga:userAgeBracket", {"ga:userAgeBracket"}, {"Age"}},
    vSocialNetwork = {Cube.AddAndExpandDimensionColumn, "ga:socialNetwork", {"ga:socialNetwork"}, {"Social Network"}},
    
    //** MEASURES **//
    // PageViews Measure
    vPageViews = {Cube.AddMeasureColumn, "Pageviews", "ga:pageviews"},
    // NewUsers Measures
    vNewUsers = {Cube.AddMeasureColumn, "New Users", "ga:newUsers"},
    // Hits Measures (Users)
    vUsers = {Cube.AddMeasureColumn, "Users", "ga:users"},
    
    //** CREATE QUERY **//
    addDimensions = Cube.Transform(View,
    //You have to susbstitute this part with a your new query (dimensions, metrics) and create a new function for each query. Just create the query as a simple table and copy it here.
        {
            // vSocialNetwork,
            // vAge,
            // vGender,
            // vUserType,
            vDate,
            vPageViews,
            vUsers,
            vNewUsers
            
        })
in
    addDimensions
in fnGetGAData
```
