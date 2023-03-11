# retrieve columns internal name

```ioke

//This query will retrieve the columns internalname, display name and type.
let
    baseURL = "https://<sharepoint site>",
    listName = "<list name>",
    Source = Json.Document(Web.Contents(
        baseURL&"/_api/web/",
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
