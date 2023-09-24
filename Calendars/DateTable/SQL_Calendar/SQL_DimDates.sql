DECLARE @StartDate  date = '2000-01-01';
DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 30, @StartDate));
DECLARE @AYMonthStart int = 8;
DECLARE @FYMonthStart int = 4;
DECLARE @vToday  date = getDate();
DECLARE @vYear int = YEAR(getDate());
DECLARE @vMonth int = MONTH(getDate());

SET DATEFIRST 1, LANGUAGE british;
;WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
),
src AS
(
  SELECT
    DateKey         = CONVERT(DATE, d),
    DayNum          = DATEPART(DAY,       d),
    DayName      = DATENAME(WEEKDAY,   d),
    WeekNum         = DATEPART(WEEK,      d),
    ISOWeek      = DATEPART(ISO_WEEK,  d),
    DayNumWeek    = DATEPART(WEEKDAY,   d),
    MonthNum        = DATEPART(MONTH,     d),
    MonthName    = DATENAME(MONTH,     d),
    MonthShort    = DATENAME(MONTH,     d),
    QuarterNum      = DATEPART(Quarter,   d),
    YearNum         = DATEPART(YEAR,      d),
    MonthStart = DATEFROMPARTS(YEAR(d), MONTH(d), 1),
    YearEnd   = DATEFROMPARTS(YEAR(d), 12, 31),
    DayNumOfYear    = DATEPART(DAYOFYEAR, d)
  FROM d
),
DimDates AS
(
  SELECT
    DateKey AS [Date], 
    DayNum,
    YearNum,
    YearMonthID = [YearNum] * 12 + [MonthNum],
    [YearMonthINT] =  [YearNum] * 100 + [MonthNum],
    [Month-Year] = FORMAT( DateKey, 'MMM-yy'),

    [Fiscal Year] = 
        case
            when [MonthNum] >= @FYMonthStart
            then (right(convert(nvarchar(max), [YearNum] + 0), 2) + '/') + right(convert(nvarchar(max), [YearNum] + 1), 2)
            else (right(convert(nvarchar(max), [YearNum] - 1), 2) + '/') + right(convert(nvarchar(max), [YearNum] + 0), 2)
        end,
        [FiscalYearStart] = 
        case
            when [MonthNum] >= @FYMonthStart
            then DATEFROMPARTS( [YearNum] + 0,  @FYMonthStart , 1 )
            else DATEFROMPARTS( [YearNum] - 1,  @FYMonthStart , 1 )
        end,
        [FiscalYearEnd] = 
        case
            when [MonthNum] >= @FYMonthStart
            then EOMONTH(DATEFROMPARTS( [YearNum] + 1,  @FYMonthStart -1 , 1 ))
            else EOMONTH(DATEFROMPARTS( [YearNum] - 0,  @FYMonthStart -1 , 1 ))
        end,

    [Academic Year] =
        case
            when [MonthNum] >= @AYMonthStart
            then (right(convert(nvarchar(max), [YearNum] + 0), 2) + '/') + right(convert(nvarchar(max), [YearNum] + 1), 2)
            else (right(convert(nvarchar(max), [YearNum] - 1), 2) + '/') + right(convert(nvarchar(max), [YearNum] + 0), 2)
        end,
        [AcademicYearStart] = 
        case
            when [MonthNum] >= @AYMonthStart
             then DATEFROMPARTS( [YearNum] + 0,  @AYMonthStart , 1 )
            else DATEFROMPARTS( [YearNum] - 1,  @AYMonthStart , 1 )
        end,
        [AcademicYearEnd] = 
        case
            when [MonthNum] >= @AYMonthStart
            then EOMONTH(DATEFROMPARTS( [YearNum] + 1,  @AYMonthStart -1 , 1 ))
            else EOMONTH(DATEFROMPARTS( [YearNum] - 0,  @AYMonthStart -1 , 1 ))
        end,
    DayNumSuffix        = CONVERT(char(2), CASE WHEN DayNum / 10 = 1 THEN 'th' ELSE 
                            CASE RIGHT(DayNum, 1) WHEN '1' THEN 'st' WHEN '2' THEN 'nd' 
                            WHEN '3' THEN 'rd' ELSE 'th' END END),
    DayDateProper        = CONVERT(char(4), CASE WHEN DayNum / 10 = 1 THEN CONCAT( DayNum, 'th') ELSE 
                            CASE RIGHT(DayNum, 1) WHEN '1' THEN CONCAT(DayNum, 'st') WHEN '2' THEN CONCAT(DayNum, 'nd' )
                            WHEN '3' THEN CONCAT(DayNum, 'rd') ELSE CONCAT(DayNum, 'th') END END),
    DayName,
    DayNameShort = LEFT(DATENAME(WEEKDAY, DateKey), 3),
    DayNumWeek,
    DayNumWeekInMonth = CONVERT(tinyint, ROW_NUMBER() OVER 
                            (PARTITION BY MonthStart, DayNumWeek ORDER BY DateKey)),
    DayNumOfYear,
    IsWeekend           = CASE WHEN DayNumWeek IN (CASE @@DATEFIRST WHEN 1 THEN 6 WHEN 7 THEN 1 END,7) 
                            THEN 1 ELSE 0 END,
    WeekNum,
    ISOWeek,
    FirstOfWeek      = DATEADD(DAY, 1 - DayNumWeek, DateKey),
    LastOfWeek       = DATEADD(DAY, 6, DATEADD(DAY, 1 - DayNumWeek, DateKey)),
    WeekNumOfMonth      = CONVERT(tinyint, DENSE_RANK() OVER 
                            (PARTITION BY YearNum, MonthNum ORDER BY WeekNum)),
    MonthNum,
    MonthName,
    MonthShort = LEFT(DATENAME(MONTH, DateKey), 3),
    [Fiscal Month-Year] = FORMAT( DateKey, 'MMM-yy'),
    [Academic Month-Year] = FORMAT( DateKey, 'MMM-yy'),
    [FiscalMonthNUM] =
        case
        when ( [MonthNum] >= @FYMonthStart AND @FYMonthStart > 1 )
        then ( [MonthNum] - (@FYMonthStart - 1))
        when ( [MonthNum] >= @FYMonthStart AND @FYMonthStart = 1 )
        then ( [MonthNum] + (12 - @FYMonthStart + 1))
        else ( [MonthNum] + (12 - @FYMonthStart + 1))
    end,
    [AcademiclMonthNUM] =
        case
        when ( [MonthNum] >= @AYMonthStart AND @AYMonthStart > 1 )
        then ( [MonthNum] - (@AYMonthStart - 1))
        when ( [MonthNum] >= @AYMonthStart AND @AYMonthStart = 1 )
        then ( [MonthNum] + (12 - @AYMonthStart + 1))
        else ( [MonthNum] + (12 - @AYMonthStart + 1))
    end,
    FiscalMonthShort = LEFT(DATENAME(MONTH, DateKey), 3),
    AcademicMonthShort = LEFT(DATENAME(MONTH, DateKey), 3),
    MonthStart,
    MonthEnd      = MAX(DateKey) OVER (PARTITION BY YearNum, MonthNum),
    MonthStartNext = DATEADD(MONTH, 1, MonthStart),
    MonthEndNext  = DATEADD(DAY, -1, DATEADD(MONTH, 2, MonthStart)),
    QuarterNum,
    QuarterStart   = MIN(DateKey) OVER (PARTITION BY YearNum, QuarterNum),
    QuarterEnd    = MAX(DateKey) OVER (PARTITION BY YearNum, QuarterNum),
    [FiscalQuarterNUM] = 'Q' + convert(nvarchar(max), ceiling(convert(decimal(38,6), datepart("m", dateadd("m", (@FYMonthStart - 1), DateKey))) / convert(decimal(38,6), 3))) , 
     [AcademicQuarterNUM] = 'Q' + convert(nvarchar(max), ceiling(convert(decimal(38,6), datepart("m", dateadd("m", (@AYMonthStart - 1), DateKey))) / convert(decimal(38,6), 3))) , 
    [YearOFFSET] = datepart("yyyy", DateKey) - @vYear ,
    [FiscalYearOFFSET] =
            (case
                    when ([MonthNum] >= @FYMonthStart)
                    then [YearNum] + 1
                    else [YearNum]
            end)
                - 
                (case when (@vMonth >= @FYMonthStart) then @vYear + 1 else @vYear end), 
    [IsFYComplete] = 
    case when 
     (case
                    when ([MonthNum] >= @FYMonthStart)
                    then [YearNum] + 1
                    else [YearNum]
            end)
                - 
                (case when (@vMonth >= @FYMonthStart) then @vYear + 1 else @vYear end) < 0 then 1 else 0 
    end,
    [AcademicYearOffset] = 
            (case
                    when ([MonthNum] >= @AYMonthStart)
                    then [YearNum] + 1
                    else [YearNum]
            end)
                - 
                (case when (@vMonth >= @AYMonthStart) then @vYear + 1 else @vYear end),
    [IsAYComplete] = 
    case when 
        (case
                    when ([MonthNum] >= @AYMonthStart)
                    then [YearNum] + 1
                    else [YearNum]
            end)
                - 
                (case when (@vMonth >= @AYMonthStart) then @vYear + 1 else @vYear end) < 0 then 1 else 0
    end ,
     [MonthOFFSET] = (12 * datepart("yyyy", DateKey) + datepart("m", DateKey)) - ( (12 * @vYear) + @vMonth ),
     [IsYTD] = 
            case
            when DateKey <= getdate()
            then 1
            else 0
        end,
    [IsMonthComplete] = 
        case when 
        DateKey < DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0) then 1 else 0 end,

    ISOYear          = YearNum - CASE WHEN MonthNum = 1 AND ISOWeek > 51 THEN 1 
                            WHEN MonthNum = 12 AND ISOWeek = 1  THEN -1 ELSE 0 END,      
    YearStart      = DATEFROMPARTS(YearNum, 1,  1),
    YearEnd,
    IsLeapYear          = CONVERT(bit, CASE WHEN (YearNum % 400 = 0) 
                            OR (YearNum % 4 = 0 AND YearNum % 100 <> 0) 
                            THEN 1 ELSE 0 END),
    Has53Weeks          = CASE WHEN DATEPART(WEEK,     YearEnd) = 53 THEN 1 ELSE 0 END,
    Has53ISOWeeks       = CASE WHEN DATEPART(ISO_WEEK, YearEnd) = 53 THEN 1 ELSE 0 END,
    DateFormat_MMYYYY              = CONVERT(char(2), CONVERT(char(8), DateKey, 101))
                          + CONVERT(char(4), YearNum),
    DateFormat_DDMMYYYY            = CONVERT(char(10), DateKey, 105),
    DateFormat_DDMMYY            = CONVERT(char(10), DateKey, 3),
    DateFormat_YYYMMDD            = CONVERT(char(8),  DateKey, 112)
  FROM src
)
-- SELECT * FROM DimDates WHERE [IsFYComplete] = 1
--  ORDER BY [Date] DESC OPTION (MAXRECURSION 0) ;


SELECT * INTO dbo.DimDates FROM DimDates
  ORDER BY [Date]
  OPTION (MAXRECURSION 0);

GO
ALTER TABLE dbo.DimDates ALTER COLUMN [Date] date NOT NULL;
GO
ALTER TABLE dbo.DimDates ADD CONSTRAINT PK_DimDates PRIMARY KEY CLUSTERED([Date]);
GO
