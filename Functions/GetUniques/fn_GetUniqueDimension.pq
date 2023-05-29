let
  fn = (tableInput as table) as table =>
    let
      sourceInput = tableInput, 
      headerName = Table.ColumnNames(sourceInput){0}, 
      dataPrep = Table.Sort(
        Table.SelectRows(Table.Distinct(sourceInput), each not List.IsEmpty(List.RemoveMatchingItems(Record.FieldValues(_), {"", null}))), 
        {{headerName, Order.Ascending}}
      )
    in
      dataPrep
in
  fn
