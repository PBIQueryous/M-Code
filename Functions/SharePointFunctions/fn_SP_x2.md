# basic API request

```ioke
//This is the basic API request that returns a XML document
let
    baseURL = "https://<sharepoint site>",
    listName = "<list name>",
    Source = Web.Contents(
        baseURL & "/_api/web/lists/getbytitle('" & listName & "')/items"
    )
in
    Source

```

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

##

```ioke

let
    baseURL = "https://<sharepoint site>",
    listName = "<list name>",
    Source = Web.Contents(
        baseURL & "/_api/web/lists/getbytitle('" & listName & "')/items", 
        [
            Query = 
                [
                     #"$top"="50", //This is the size of the batch
                     #"$expand" = "ItemEdit", //These is the column that requires to be expanded
                     #"$select" = "Id, ItemEdit/Title" //These are the columns we are requesting, expanded columns must include the parent column name.

                ],
            Headers=
                [
                    Accept="application/json;odata=nometadata" //changing headers return a JSON Document
                ]
        ]
    )
in
    Source

```
