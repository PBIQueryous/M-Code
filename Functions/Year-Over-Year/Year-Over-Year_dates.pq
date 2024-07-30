let
  previous_step = col_like_for_like, 
  add_records_tbl = Table.AddColumn(
    previous_step, 
    "lfl_records", 
    each 
      let
        col_records = [
          PY_like_for_like         = Date.AddDays([Date], - 364), 
          PY_minus_1_like_for_like = Date.AddDays([Date], - (364 * 2))
        ]
      in
        col_records, 
    type [PY_like_for_like = Date.Type, PY_minus_1_like_for_like = Date.Type]
  ), 
  get_headers = Record.FieldNames(add_records_tbl[lfl_records]{0}), 
  exp_record_fields = Table.ExpandRecordColumn(
    add_records_tbl, 
    "lfl_records", 
    get_headers, 
    get_headers
  )
in
  exp_record_fields
