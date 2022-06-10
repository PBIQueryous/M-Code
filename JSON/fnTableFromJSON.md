## Table.FromRecords for JSON file
```js
(URL as text) =>
let
    MyJsonRecord = Json.Document(Web.Contents(URL)),
    MyJsonTable= Table.FromRecords( { MyJsonRecord } )
in
    MyJsonTable
