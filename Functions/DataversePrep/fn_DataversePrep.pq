let
  fn = (tableName as text, prefix as text) =>
    let
      dataverseDomain      = "companyName.crmX.dynamics.com",  
      //-- dataverse rootURL: eg "companyName.crmX.dynamics.com"
      
      Source               = CommonDataService.Database(dataverseDomain, [CreateNavigationProperties = false]),
      //-- import table without dataverse nested tables
      
      import               = Source{[Schema = "dbo", Item = tableName]}[Data],  
      //-- import table
      
      list_AllHeaders      = Table.ColumnNames(import),  
      //-- get column names
      
      list_ColumnsToRemove = List.Select(list_AllHeaders, each not Text.StartsWith(_, prefix)),  
      //-- remove columns that don't have the prefix
      
      list_ColumnsToKeep   = List.Select(list_AllHeaders, each Text.StartsWith(_, prefix) and not Text.Contains(_, "_base")),  
      //-- keep columns with the prefix and remove any (base) columns
      
      SELECT_COLS          = Table.SelectColumns(import, list_ColumnsToKeep) 
      //-- select columns
    
    in
      SELECT_COLS
in
  fn
