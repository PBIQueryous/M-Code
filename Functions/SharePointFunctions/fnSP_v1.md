
# OscarMartinez
## paginated results

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
            &"&$select=Id,FileDirRef,FSObjType,ItemEdit/Title" //These are the columns we are requesting, expanded columns must include the parent column name.
            &"&$expand=ItemEdit" // Include here the columns that require to be expanded
            &"&$filter=startswith(FileDirRef,'/teams/SharePointSite/Shared Documents/Folder Route 1/Folder route 2') and FSObjType eq 0"  //This will filter the query to a specific folder to get files only excluding folder items.
        ),
    #"Converted to Table" = Table.FromList(Fullset, Splitter.SplitByNothing(), null, null, ExtraValues.Error)
in 
    #"Converted to Table"
    
    
 ```
 
 ## binary files
 
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
