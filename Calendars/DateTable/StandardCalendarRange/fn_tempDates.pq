v_Today = Date.From( DateTime.LocalNow() ),
    v_Year = Date.Year( DateTime.LocalNow() ),
    v_Month = Date.Month( DateTime.LocalNow() ),
    FYStartMonth = 4,
    AYStartMonth = 8,
    col_Year = Table.AddColumn( col_rename , "YearNUM", each Date.Year([Date]), type number),
    // calendar month num
    col_MonthNUM = Table.AddColumn(
            col_Year, 
            "MonthNUM", 
            each Date.Month([Date]), 
            type number
          ),
    col_YearMonthID = Table.AddColumn(col_MonthNUM, "YearMonthID", each [YearNUM] * 12 + [MonthNUM], Int64.Type),
    col_FiscalYear = Table.AddColumn( col_YearMonthID , "Fiscal Year" , each
if ([MonthNUM] >= FYStartMonth and FYStartMonth > 1) then Text.End(Text.From([YearNUM] + 0), 2) & "/" & Text.End(Text.From([YearNUM] + 1), 2) else Text.End(Text.From([YearNUM] - 1), 2) & "/" & Text.End(Text.From([YearNUM] + 0), 2), type text),
    col_AcademicYear = Table.AddColumn( col_FiscalYear , "Academic Year" , each
if ([MonthNUM] >= AYStartMonth and AYStartMonth > 1) then Text.End(Text.From([YearNUM] + 0), 2) & "/" & Text.End(Text.From([YearNUM] + 1), 2) else Text.End(Text.From([YearNUM] - 1), 2) & "/" & Text.End(Text.From([YearNUM] + 0), 2), type text),
    col_FiscalMonthNUM = Table.AddColumn(col_AcademicYear, "FiscalMonthNUM", each if ( [MonthNUM] >= FYStartMonth and FYStartMonth > 1 ) then ( [MonthNUM] - (FYStartMonth - 1 )) else if ([MonthNUM] >= FYStartMonth and FYStartMonth = 1 ) then ([MonthNUM] + (12 - FYStartMonth + 1 ) ) else ([MonthNUM] + (12 - FYStartMonth + 1 )), Int64.Type),
    col_AcademicMonthNUM = Table.AddColumn(col_FiscalMonthNUM, "AcademicMonthNUM", each if ( [MonthNUM] >= AYStartMonth and AYStartMonth > 1 ) then ( [MonthNUM] - (AYStartMonth - 1 )) else if ([MonthNUM] >= AYStartMonth and AYStartMonth = 1 ) then ([MonthNUM] + (12 - AYStartMonth + 1 ) ) else ([MonthNUM] + (12 - AYStartMonth + 1 )), Int64.Type),
    // calendar month and year as integer key (20230001)
    col_MonthYearINT = Table.AddColumn(
            col_AcademicMonthNUM, 
            "YearMonthINT", 
            each [YearNUM] * 100 + [MonthNUM], 
            type number
          ),
    col_FiscalYearMonthINT = Table.AddColumn(
            col_MonthYearINT, 
            "FiscalYearMonthINT", 
            each [YearNUM] * 100 + [FiscalMonthNUM], 
            type number
          ),
    col_AcademicYearMonthINT = Table.AddColumn(
            col_FiscalYearMonthINT, 
            "AcademicYearMonthINT", 
            each [YearNUM] * 100 + [AcademicMonthNUM], 
            type number
          ),
    col_FiscalMonthShort = Table.DuplicateColumn(col_AcademicYearMonthINT, "Month Short", "Fiscal Month Short"),
    col_AcademicMonthShort = Table.DuplicateColumn(col_FiscalMonthShort, "Fiscal Month Short", "Academic Month Short"),
    col_MonthYear = Table.AddColumn( col_AcademicMonthShort , "Month-Year" , each
if ([MonthNUM] >= AYStartMonth and AYStartMonth > 1) then [Month Short] & "-" & Text.End(Text.From([YearNUM]), 2) else  [Month Short] & "-" & Text.End(Text.From([YearNUM]), 2), type text),
    col_FiscalMonthYear = Table.DuplicateColumn(col_MonthYear, "Month-Year", "Fiscal Month-Year"),
    col_AcademicMonthYear = Table.DuplicateColumn(col_FiscalMonthYear, "Month-Year", "Academic Month-Year"),
    col_FiscalQuarterNUM = Table.AddColumn(col_AcademicMonthYear, "FiscalQuarterNUM", each "Q" & Text.From( Number.RoundUp(Date.Month(Date.AddMonths([Date], - (FYStartMonth - 1))) / 3)), Text.Type),
    col_AcademicQuarterNUM = Table.AddColumn(col_FiscalQuarterNUM, "AcademicQuarterNUM", each "Q" & Text.From( Number.RoundUp(Date.Month(Date.AddMonths([Date], - (AYStartMonth - 1))) / 3)), Text.Type),
    col_YearOFFSET = Table.AddColumn(
            col_AcademicQuarterNUM, 
            "YearOFFSET", 
            each Date.Year([Date]) - v_Year, 
            type number
          ),
    col_FiscalYearOFFSET = Table.AddColumn(
            col_YearOFFSET, 
            "FiscalYearOFFSET", 
            each
              (if [MonthNUM] >= FYStartMonth then [YearNUM] + 1 else [YearNUM])
                - (if v_Month >= FYStartMonth then v_Year + 1 else v_Year), 
            type number
          ),
    col_AcademicYearOFFSET = Table.AddColumn(
            col_FiscalYearOFFSET, 
            "AcademicYearOFFSET", 
            each
              (if [MonthNUM] >= AYStartMonth then [YearNUM] + 1 else [YearNUM])
                - (if v_Month >= AYStartMonth then v_Year + 1 else v_Year), 
            type number
          ),
    // calendar month offset
    col_MonthOFFSET = Table.AddColumn(
            col_AcademicYearOFFSET, 
            "MonthOFFSET", 
            each ((12 * Date.Year([Date])) + Date.Month([Date]))
              - (
                (12 * v_Year)
                  + v_Month
              ), 
            type number
          ),
    // is current calendar year complete as boolean
          col_isYTD = Table.AddColumn(
            col_MonthOFFSET, 
            "IsInYearToDate", 
            each Date.IsInYearToDate([Date]) , 
            type logical
          ),
    col_isFuture = Table.AddColumn(
            col_isYTD, 
            "isFuture", 
            each not Date.IsInYearToDate([Date])  , 
            type logical
          ),
    col_isYearComplete = Table.AddColumn(col_isFuture, "isYearComplete", each if [YearOFFSET] < 0 then true else false, type logical),
    col_isFYComplete = Table.AddColumn(col_isYearComplete, "isFYComplete", each if [FiscalYearOFFSET] < 0 then true else false, type logical),
    col_isAYComplete = Table.AddColumn(col_isFYComplete, "IsAYComplete", each if [AcademicYearOFFSET] < 0 then true else false, type logical),
    col_isCFY = Table.AddColumn(col_isAYComplete, "isCFY", each if [FiscalYearOFFSET] = 0 then true else false , type logical),
    col_isCAY = Table.AddColumn(col_isCFY, "isAFY", each if [AcademicYearOFFSET] = 0 then true else false, type logical)
in
    col_isCAY
