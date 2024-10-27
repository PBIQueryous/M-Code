CREATE OR ALTER PROCEDURE USP.[usp_CreateDimCalendar]
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare the financial year start month (12 for December)
    DECLARE @financial_year_start_month INT = 12;
    DECLARE @current_year INT = YEAR(GETDATE());
    DECLARE @current_month INT = MONTH(GETDATE());
    DECLARE @current_date DATE = GETDATE();

    -- Calculate the adjusted month offset for financial quarter calculations
    DECLARE @adjusted_month_offset INT = @financial_year_start_month - 1;

    -- Calculate `n`, the financial offset for months
    DECLARE @n INT = CASE WHEN (@financial_year_start_month BETWEEN 1 AND 12) 
                            AND (@financial_year_start_month > 1) 
                         THEN @financial_year_start_month - 1 
                         ELSE 0 
                    END;

    -- Drop the table if it exists
    IF OBJECT_ID('[Test_DB].dbo.dim_calendar', 'U') IS NOT NULL
    BEGIN
        DROP TABLE [Test_DB].dbo.dim_calendar;
    END;


WITH date_series AS (
    SELECT 
    DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1, DATEFROMPARTS(YEAR(GETDATE()) - 3, 1, 1)) AS date_id
FROM sys.all_objects
)
, complete_date_range AS (
SELECT date_id FROM date_series
WHERE date_id <= DATEFROMPARTS(YEAR(GETDATE()) + 3, 12, 31)
)
, core_date_fields AS (
    SELECT 
          date_id
		, YEAR(date_id) AS year_num
		, MONTH(date_id) AS month_num
		, DAY(date_id) AS day_month_num
		, DATENAME(MONTH, date_id) AS month_name
		, LEFT(DATENAME(MONTH, date_id), 3) AS month_name_short
		, DATENAME(WEEKDAY, date_id) AS day_name
		, LEFT(DATENAME(WEEKDAY, date_id), 3) AS day_name_short
		, ((DATEPART(WEEKDAY, date_id) + @@DATEFIRST - 2) % 7) + 1 AS day_week_num
		, DATEPART(DAYOFYEAR, date_id) AS day_year_num
		, DATEPART(QUARTER, date_id) AS quarter_num
		, DATEFROMPARTS(YEAR(date_id), MONTH(date_id), 1) AS month_start
		, EOMONTH(date_id) AS month_end
		, LEFT(DATENAME(WEEKDAY, date_id), 1) AS day_initial
		, LEFT(DATENAME(MONTH, date_id), 1) AS month_initial

    FROM complete_date_range
)
, additional_date_fields AS(
	SELECT
		 date_id
        , year_num
        , year_num - @current_year AS year_offset -- Year, month, and day offsets
		, CASE WHEN date_id <= @current_date THEN 1 ELSE 0 END AS is_ytd
        , CASE WHEN date_id > @current_date THEN 1 ELSE 0 END AS is_frc
		, CASE WHEN DATEDIFF(MONTH, GETDATE(), date_id) < 0 THEN 1 ELSE 0 END AS is_cmtd
		-- financial Year calculation based on financial start month
        , CONCAT(
            RIGHT(YEAR(
                CASE 
                    WHEN month_num >= @financial_year_start_month THEN date_id 
                    ELSE DATEADD(YEAR, -1, date_id)
                END
            ), 2), 
            '/',
            RIGHT(YEAR(
                CASE 
                    WHEN month_num >= @financial_year_start_month THEN DATEADD(YEAR, 1, date_id) 
                    ELSE date_id 
                END
            ), 2)
        ) AS financial_year

		-- Financial year offset based on financial start
        , (CASE WHEN month_num >= @financial_year_start_month THEN year_num + 1 ELSE year_num END) - (CASE WHEN @current_month >= @financial_year_start_month THEN @current_year + 1 ELSE @current_year END) AS financial_year_offset		
        , month_num
        , month_name
        , month_name_short 
		, month_initial
		, month_start
        , month_end
		
        , DATEDIFF(MONTH, GETDATE(), date_id) AS month_offset
        , CASE -- Financial month number for financial year starting in December
            WHEN month_num >= @financial_year_start_month AND @financial_year_start_month > 1 THEN month_num - (@financial_year_start_month - 1)
            WHEN @financial_year_start_month = 1 THEN month_num
            ELSE month_num + (12 - @financial_year_start_month + 1)
        END AS financial_month_num
		, day_initial
        , day_name
        , day_name_short
        , day_year_num
		, day_month_num
        , day_week_num
		, DATEDIFF(DAY, GETDATE(), date_id) AS day_offset
		, CASE WHEN ((day_week_num + @@DATEFIRST - 2) % 7) + 1 BETWEEN 1 AND 5 THEN 1 ELSE 0 END AS is_weekday
        , CASE WHEN ((day_week_num + @@DATEFIRST - 2) % 7) + 1 BETWEEN 6 AND 7 THEN 1 ELSE 0 END AS is_weekend
        , quarter_num
		, CONCAT('Q', quarter_num) AS quarter_name
		, ((4 * YEAR(date_id)) + DATEPART(QUARTER, date_id)) - ((4 * YEAR(@current_date)) + DATEPART(QUARTER, @current_date)) AS quarter_offset
		, FLOOR(((12 + MONTH(date_id) - @financial_year_start_month) % 12) / 3 ) + 1 AS financial_quarter_num -- Financial quarter calculation based on financial start month	 
        , 'FQ' + CAST(FLOOR(((12 + MONTH(date_id) - @financial_year_start_month) % 12) / 3) + 1 AS VARCHAR(3)) AS financial_quarter_name -- Financial quarter calculation based on financial start month
		,	((4 * YEAR(DATEADD(MONTH, -@n, DATEADD(DAY, 1 - DAY([date_id]), [date_id])))) + DATEPART(QUARTER, DATEADD(MONTH, -@n, DATEADD(DAY, 1 - DAY([date_id]), [date_id]))))
				- ((4 * YEAR(DATEADD(MONTH, -@n, DATEADD(DAY, 1 - DAY(@current_date), @current_date)))) + DATEPART(QUARTER, DATEADD(MONTH, -@n, DATEADD(DAY, 1 - DAY(@current_date), @current_date)))
			) as financial_quarter_offset

		-- Week start and end calculations (Assuming Monday as week start)
        , DATEADD(DAY, - (day_week_num + @@DATEFIRST - 2) % 7, date_id) AS week_start
		, DATEADD(DAY, 6 - (day_week_num + @@DATEFIRST - 2) % 7, date_id) AS week_end
		
		-- Calculate week offset based on weeks between current_date and date_id
		, DATEDIFF(WEEK, DATEADD(DAY, - (DATEPART(WEEKDAY, @current_date) + @@DATEFIRST - 2) % 7, @current_date) , DATEADD(DAY, - (DATEPART(WEEKDAY, date_id) + @@DATEFIRST - 2) % 7, date_id)) AS week_offset
        



	FROM core_date_fields
)


	
SELECT 
	date_id
	, (year_num * 12) + month_num - 1 as date_int_key
	, (year_num * 10000)  + (month_num * 100)  + day_month_num  as date_int 
	, year_num
	-- Calendar Year Start Calculation (always January 1st)
    , year_start = DATEFROMPARTS(year_num, 1, 1)

    -- Calendar Year End Calculation (always December 31st)
    , year_end = EOMONTH(DATEFROMPARTS(year_num, 12, 1))
	, CASE WHEN year_offset = -1 THEN 1 ELSE 0 END AS is_previous_year
    , CASE WHEN year_offset = 0 THEN 1 ELSE 0 END AS is_current_year
	, CASE WHEN year_offset = 0 THEN 'Current CY' ELSE CAST(year_num AS VARCHAR) END AS year_selection
	, year_offset
	, is_ytd
	, is_frc
	, is_cmtd
	, DATEADD(DAY, 364 * -1, @current_date) AS py_date_id
	, DATEADD(DAY, 364 * -2, @current_date) AS py_minus_1_date_id
	, DATEADD(DAY, 30 * -1, @current_date) AS pm_date_id
	, DATEADD(DAY, 30 * -2, @current_date) AS pm_minus_1_date_id

	-- 2 weekly dates
    , CASE 
        WHEN (DATEPART(WEEK, [date_id]) % 2) = 1 
        THEN DATEADD(DAY, -(DATEPART(WEEKDAY, [date_id]) - 2) - 1, [date_id])  -- Subtracts one extra day
        ELSE DATEADD(DAY, -(DATEPART(WEEKDAY, DATEADD(DAY, -7*1, [date_id])) - 2) - 1, DATEADD(DAY, -7*1, [date_id]))  -- Subtracts one extra day
      END AS [2W Date]

	-- 2 monthly dates
    , EOMONTH(DATEADD(MONTH, -((MONTH([date_id]) - 1) % 2), [date_id])) AS [2M Date]

	-- 3 monthly dates
    , EOMONTH(DATEADD(MONTH, -((MONTH([date_id]) - 1) % 3), [date_id])) AS [3M Date]

	-- 6 monthly dates
    , EOMONTH(DATEADD(MONTH, -((MONTH([date_id]) - 1) % 6), [date_id])) AS [6M Date]
    
	-----
	, financial_year

    , financial_year_start = 
        CASE 
            WHEN month_num >= @financial_year_start_month
            THEN DATEFROMPARTS(year_num, @financial_year_start_month, 1)
            ELSE DATEFROMPARTS(year_num - 1, @financial_year_start_month, 1)
        END

    , financial_year_end = 
        CASE 
            WHEN month_num >= @financial_year_start_month
            THEN EOMONTH(DATEFROMPARTS(year_num + 1, @financial_year_start_month - 1, 1))
            ELSE EOMONTH(DATEFROMPARTS(year_num, @financial_year_start_month - 1, 1))
        END
	, CASE WHEN financial_year_offset = -1 THEN 1 ELSE 0 END AS is_previous_fy
    , CASE WHEN financial_year_offset = 0 THEN 1 ELSE 0 END AS is_current_fy
	, CASE WHEN financial_year_offset = 0 THEN 'Current FY' ELSE CAST(financial_year AS VARCHAR) END AS fy_selection
	, financial_year_offset
	, month_num 
    , month_name
    , month_name_short 
	, month_initial
	, month_start
    , month_end
	, FORMAT(date_id, 'MMM-yy') as month_year_short
	, FORMAT(date_id, 'MMM-yyyy') as month_year_long
	, (year_num * 100)  + (month_num) as month_year_int
	, CASE WHEN month_offset = 0 THEN 1 ELSE 0 END AS is_current_month
	, CASE WHEN month_offset = 0 THEN 'Current Month' ELSE month_name_short END AS current_month_selection
	, month_offset
	-----
	, financial_month_num
    , month_name as financial_month
    , month_name_short as financial_month_short
	, month_initial as financial_month_initial
	, month_start as financial_month_start
    , month_end as financial_month_end
	, FORMAT(date_id, 'MMM-yy') as financial_month_year_short
	, FORMAT(date_id, 'MMM-yyyy') as financial_month_year_long
	, (CAST(REPLACE(financial_year, '/','') AS INT) * 100)  + (financial_month_num) as financial_month_year_int
	, month_offset as financial_month_offset
	-----
	
	, day_initial
    , day_name
    , day_name_short
    , day_year_num
	, day_month_num
    , day_week_num
	, day_offset
	, is_weekday
	, is_weekend
	, quarter_num
	, quarter_name
	, (CAST(REPLACE(year_num, '/','') AS INT) * 100)  + (quarter_num) as quarter_year_int 
	, quarter_offset
	, financial_quarter_num
	, financial_quarter_name
	, (CAST(REPLACE(financial_year, '/','') AS INT) * 100)  + (financial_quarter_num) as financial_quarter_year_int
	, financial_quarter_offset
	, week_start
	, week_end
	, week_offset
	

INTO [Test_DB].dbo.dim_calendar
FROM additional_date_fields;
END;

-- EXEC USP.[usp_CreateDimCalendar] ;
-- SELECT * FROM [Test_DB].dbo.dim_calendar
