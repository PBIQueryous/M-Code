# SharePointAPI

If this is your first time working with APIs in Power BI, I recommend you check the article "Power Query Web.Contents cheat sheet walkthrough".

When working with #PowerBI and #SharePoint, if you run into long load or time-out issues, it's probably time to start using SharePoint's API, as it is a better alternative. Using SP's API can dramatically reduce load times from several minutes to seconds, making it less prone to time-outs.  

SP's API's better performance comes from two factors: the ability to batch responses and request only the required columns; yes, it is a bit more complex, and you will have to deal directly with M, but remember #MisForMagic, and it is always fun. 

There are a few key advantages to using the SharePoint API to connect to SharePoint data in Power BI instead of using the SharePoint list connector. These advantages include the following:

More control over the data: Using the SharePoint API allows users more control over the data they access. This is because the API will enable users to specify the SharePoint list or library they want to access and the columns they want to use. In contrast, the SharePoint list connector automatically pulls in all the data from a SharePoint list or library.

Improved performance: The SharePoint API allows users to select only the data they want to use. It can be faster and more efficient than the SharePoint list connector. This is because the connector will pull in all the data from the SharePoint list or library, which can take longer and use more resources.

More flexibility: The SharePoint API allows users to access data from multiple SharePoint lists and libraries within a single Power BI dataset. This can be useful for combining data from different sources and creating more complex reports and dashboards. In contrast, the SharePoint list connector will only allow users to access data from one SharePoint list or library at a time.

There are a few potential disadvantages to using the SharePoint API to connect to SharePoint data in Power BI instead of using the SharePoint list connector. These disadvantages include:

Higher technical knowledge required: The SharePoint API requires more technical expertise than the SharePoint list connector. This is because the API requires users to specify the exact endpoint they want to access, which can be complex and requires a good understanding of how the API works. In contrast, the SharePoint list connector is more user-friendly and requires less technical knowledge.

More setup required: Because the SharePoint API requires users to specify the endpoint and columns they want to access, it requires more configuration than the SharePoint list connector. This can be time-consuming and may not be worth it for users who only need to access a small amount of data.

Sharepoint API how to use.
To connect Power BI to SharePoint through the API, users must ensure they have the necessary permissions to access the SharePoint data. 

Once you've confirmed having the necessary permissions, you can follow the steps below to connect Power BI to SharePoint through the API:

1. Open Power BI and select the "Get Data" option from the toolbar.

2. In the "Get Data" window, select the "Web" option from the "Other" category.


3. Enter the URL for the SharePoint API endpoint in the "Web Address" field and click "OK." This URL should be in the format of:

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
5. The SharePoint data will then be loaded into Power BI, but you might notice that the data was loaded in XML format. This might be all right for some people, but I am used to dealing with JSON; this is why we will modify the headers. 


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

5. That was the basic Sharepoint API request; now, let's modify this request. 

We will include additional query parameters to our requests in the following query; the first query, "$top," specifies the batch size.

The second query, "$expand," is where we specify the columns that need to be expanded; the reason is that in SharePoint, some columns are returned as records, and we need to instruct the API that we will require some information from the record. 

In the last query, "$select," we specify the columns we want in the response; if the column comes from an expanded column, then we need to include the "parent" record as a prefix. 

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

Internal column names.
The display name of a column is the name that is shown to users when they view the list or library.  The internal name of a column is the name that is used internally by SharePoint to identify the column. It is the name that is used in the list's underlying database and in the list's schema. 

It is important to understand the difference between the display name and the internal name because the internal name is used when you are working with the list or library programmatically, such as when you are working with SP's API. 

This code will come in handy to get the internal name of SP columns:

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

In conclusion, using the SharePoint API to connect to SharePoint data in Power BI offers several benefits, including more control over the data, improved performance, and flexibility. However, it also requires more technical knowledge and setup compared to using the SharePoint list connector. Carefully consider the trade-offs and whether the benefits of using the API outweigh the costs before deciding which option is right for you. 

Retrieving binary files using SharePoint API.
It is possible to retrieve binary content from a SharePoint Document library via the API. This is done by first retrieving the ServerRelativeUrl property and then using the endpoint “GetFileByServerRelativeUrl.

I have not yet try the performance of this method versus the SharePoint folder connector, but it may come in handy for someone.

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

Paging SharePoint results. 
This query was a challenge, although I successfully created a query that could page through SharePoint APIs using the List.Generate function, I was not able to make it refresh in the service because of a dynamic source error. Fortunately, after digging for many hours I was able to find one LinkedIn post and one community question that showed me the way of doing this:

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
