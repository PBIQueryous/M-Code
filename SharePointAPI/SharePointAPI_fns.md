# SharePointAPI

## Step1:

```ioke
https://<sharepoint site>/_api/web/lists/getbytitle('<list name>')/items
```

## Step2:

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

## Step3:

```ioke
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

## Step4:

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


## Step5: 

```ioke
//This query will retrieve the columns internalname, display name and type.
let
    baseURL = "https://<sharepoint site>",
    listName = "<list name>",
    Source = Json.Document(Web.Contents(
        baseURL&"_api/web/",
        [
            RelativePath = "lists/GetByTitle('"&listName&"')/Fields?$select=Title,InternalName,TypeAsString"           ,
            Headers = [
                Accept = "application/json;odata=nometadata"
            ]
        ]
    )),
    value = Source[value],
    #"Converted to Table" = Table.FromList(value, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"InternalName", "Title", "TypeAsString"}, {"Internal Name","Title", "Type"}),
    #"Sorted Rows" = Table.Sort(#"Expanded Column1",{{"Title", Order.Ascending}})
in
    #"Sorted Rows"
```

## Step6:

```ioke
//This query will retrieve the binaries of the SharePoint document list.
let
    //baseURL = "https://<sharepoint site>",
    //listName = "<list name>",
    Source = Json.Document(Web.Contents(baseURL & "/_api/web/lists/getbytitle('" & listName & "')/items", [Query=[
                     #"$top"="1000", //This is the size of the batch
                     #"$expand" = "File", //This is the column that requires to be expanded
                     #"$select" = "Id,File/ServerRelativeUrl" //This are the columns we are requesting, expanded columns must include the parent column name.

                ], Headers=[Accept="application/json;odata=nometadata"]]))[value],
    #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"Id", "File"}, {"Id", "File"}),
    #"Expanded File" = Table.ExpandRecordColumn(#"Expanded Column1", "File", {"ServerRelativeUrl"}, {"ServerRelativeUrl"}),
    #"Get Binary fx" = (serverRelativeUrl as text) => let
            binaryFx =
                Web.Contents(baseURL & "_api/web/GetFileByServerRelativeUrl('"& serverRelativeUrl &"')/$value")
        in
            binaryFx,
    #"Invoked Custom Function" = Table.AddColumn(#"Expanded File", "Query1", each #"Get Binary fx"([ServerRelativeUrl]))
in
    #"Invoked Custom Function"
```

## Steo7:

```ioke
//This query will return paginated results

//This approach permits refresh from Power BI service. 
//Big thanks to Rob Reily and googlogmobi for their entries that made this possible. 

//https://www.linkedin.com/pulse/loading-data-paged-related-from-ms-graph-api-power-bi-rob-reilly/
//https://community.powerbi.com/t5/Power-Query/Dynamic-data-sources-aren-t-refreshed-in-the-Power-BI-service/td-p/1563630

let 
    baseURL = "https://<sharepoint site>",
    listName = "<list name>",
    GetPages = (Path)=>
        let
            Source = Json.Document(
                Web.Contents(
                    baseURL, 
                    [
                        RelativePath = Path,
                        Headers=[
                            Accept="application/json;odata=nometadata"
                        ]
                    ]
                )
            ),
            ll= Source[value],
            Next = Text.Replace(Source[odata.nextLink], baseURL, ""),
            result = try @ll & Function.InvokeAfter(()=> @GetPages(Next) , #duration(0,0,0,0.1)) otherwise @ll
        in
        result,
    
        Fullset = GetPages("/_api/web/lists/getbytitle('"&listName&"')/items?"
            &"&$select=Id,ItemEdit/Title" //These are the columns we are requesting, expanded columns must include the parent column name.
            &"&$expand=ItemEdit" // Include here the columns that require to be expanded
        ),
    #"Converted to Table" = Table.FromList(Fullset, Splitter.SplitByNothing(), null, null, ExtraValues.Error)
in 
    #"Converted to Table"
```
