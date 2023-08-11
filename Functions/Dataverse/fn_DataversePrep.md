# fn_GetCustomDataverseObjects

``` ioke

let
  invokeFunction = (dataverseRootURL as text, dataversePrefix as text, optional dataverseTableName as text) =>
    let
      Source = CommonDataService.Database(dataverseRootURL, [CreateNavigationProperties = false]), 
      fn_getCols = 
        let
          fn = (tableName as any, prefix as text) =>
            let
              list_AllHeaders = Table.ColumnNames(tableName), 
              //-- get column names
              list_ColumnsToRemove = List.Select(list_AllHeaders, each not Text.StartsWith(_, prefix)), 
              //-- remove columns that don't have the prefix
              list_ColumnsToKeep = List.Select(list_AllHeaders, each Text.StartsWith(_, prefix) and not Text.Contains(_, "_base")), 
              //-- keep columns with the prefix and remove any (base) columns
              SELECT_COLS = Table.SelectColumns(tableName, list_ColumnsToKeep)
            //-- select columns
            in
          SELECT_COLS
        in
          fn, 
      vPrefix = dataversePrefix, 
      vTableName = dataverseTableName, 
      table_DataverseTables = Table.SelectRows(Source, each Text.StartsWith([Name], vPrefix)), 
      invoke_FunctionToCleanColumns = Table.SelectColumns(Table.AddColumn(table_DataverseTables, "CustomData", each fn_getCols([Data], vPrefix)), {"Schema", "Item", "Data", "CustomData"}), 
      import_CleanTable = invoke_FunctionToCleanColumns{[Schema = "dbo", Item = vTableName]}[CustomData], 
      finalStep = if dataverseTableName = null then invoke_FunctionToCleanColumns else import_CleanTable
    in
      finalStep
in
  invokeFunction

```
