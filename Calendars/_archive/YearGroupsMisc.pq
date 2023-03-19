= Table.AddColumn(
  col_Last15Months, 
  "AcademicYear Group", 
  each 
    let
      cond1 = [Academic CurrYearOffset] <= - 2, 
      prev = List.Max(
        Table.SelectRows(col_Last15Months, each ([Academic CurrYearOffset] <= - 2))[Academic Year]
      )
        & "-", 
      cond2 = [Academic CurrYearOffset] >= 2, 
      future = List.Max(
        Table.SelectRows(col_Last15Months, each ([Academic CurrYearOffset] >= 2))[Academic Year]
      )
        & "+", 
      result = if cond1 then prev else if cond2 then future else [Academic Year]
    in
      result, 
  type text
)
