let invokeCalendar = (Input_Calendar_Start_Year as text) =>
let
    _sqlServer =  "sql-lcgdna-prd-uks-01.database.windows.net",
    _azureDatabase = "sqldb_lcgdna_dwh_01",
    vCalendarStartYear = Input_Calendar_Start_Year,
    _isFoldingEnabled = [EnableFolding = true ],
    _runSQLQueryALL = "SELECT * FROM [ENT].[Dim_Calendar_Join] WHERE [Year Num] >=" & vCalendarStartYear,
    _runSQLQuery = 
    "SELECT [Key Date] as [Date]
      ,[Year Num]
      ,[Month Num]
      ,[Month Start]
      ,[Month End]
      ,[Month Name]
      ,[Month Short]
      ,[Month Initial]
      ,[Month Selection]
      ,[YearMonthID]
      ,[Fiscal Year]
      ,[Academic Year]
      ,[Fiscal Month Num]
      ,[Academic Month Num]
      ,[Year Month Int]
      ,[Fiscal Year Month Int]
      ,[Academic Year Month Int]
      ,[Fiscal Month Short]
      ,[Academic Month Short]
      ,[Month-Year]
      ,[Fiscal Month-Year]
      ,[Academic Month-Year]
      ,[Quarter Num]
      ,[Fiscal Quarter Num]
      ,[Academic Quarter Num]
      ,[Year Offset]
      ,[Fiscal Year Offset]
      ,[Academic Year Offset]
      ,[Month Offset]
      ,[Is in Year to Date]
      ,[Is Future]
      ,[Is Year Complete]
      ,[Is Financial Year Complete]
      ,[Is Academic Year Complete]
  FROM [ENT].[Dim_Calendar_Join]
  WHERE [Year Num] >=" & vCalendarStartYear // & _whereFilter_v2
,
    _sourceDB = Sql.Database( _sqlServer, _azureDatabase ),
    _nativeQuery = Value.NativeQuery( _sourceDB , _runSQLQueryALL , null , _isFoldingEnabled),
    _renameDate = Table.RenameColumns(_nativeQuery,{{"Key Date", "Date"}}),
    _formatDates = Table.TransformColumnTypes(_renameDate,{{"Date", type date}, {"Month Start", type date}, {"Month End", type date}}),
    _colsOrder = {"Date", "YearMonthID", "Fiscal Year", "Academic Year", "Year Num", "Month Name", "Month Short", "Month Num", "Month Start", "Month End", "Month Initial", "Month Selection", "Fiscal Month Num", "Academic Month Num", "Year Month Int", "Fiscal Year Month Int", "Academic Year Month Int", "Fiscal Month Short", "Academic Month Short", "Month-Year", "Fiscal Month-Year", "Academic Month-Year", "Fiscal Quarter Num", "Academic Quarter Num", "Year Offset", "Fiscal Year Offset", "Academic Year Offset", "Month Offset"},
    _inputTable = Table.ReorderColumns( _formatDates, _colsOrder ),
    _fiscalQuarterPrefix = Table.TransformColumns(_inputTable, {{"Fiscal Quarter Num", each "F" & _, type text}}),
    _academicQuarterPrefix = Table.TransformColumns(_fiscalQuarterPrefix, {{"Academic Quarter Num", each "A" & _, type text}}),
    _last15Months = Table.AddColumn(_academicQuarterPrefix, "Is Last 15 Months", each if [Month Offset] >= -15 then "Last 15 Months" else null, type text),
    _newStartsOnly = Table.AddColumn(_last15Months, "New Starts Only Filter", each if [Academic Year Offset] = 0 then "Show AY New Starts Only" else null, type text)
in
    _newStartsOnly

in invokeCalendar
