# basic API request

``` ioke
//This is the basic API request that returns a JSON Document
let
    baseURL = "https://<sharepoint site>",
    listName = "<list name>",
    Source = Web.Contents(
        baseURL & "/_api/web/lists/getbytitle('" & listName & "')/items", 
        [
            Headers=
                [
                    Accept="application/json;odata=nometadata" //changing headers return a JSON Document
                ]
        ]
    )
in
    Source
```
