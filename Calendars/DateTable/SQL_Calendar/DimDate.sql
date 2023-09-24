BEGIN TRY
	DROP TABLE [dbo].[DimDate]
END TRY

BEGIN CATCH
	/*No Action*/
END CATCH

/*******************************************************************************************************************************************************/

CREATE TABLE
	[dbo].[DimDate]
	(	[DateKey] INT,
		[Date] DATETIME,
		[StandardDate] CHAR(10),
		[Day] VARCHAR(2),
		[DaySuffix] VARCHAR(4),
		[DayName] VARCHAR(9),
		[DayOfWeek] CHAR(1),
		[DayOfWeekInMonth] VARCHAR(2),
		[DayOfWeekInYear] VARCHAR(2),
		[DayOfQuarter] VARCHAR(3),
		[DayOfYear] VARCHAR(3),
		[WeekOfMonth] VARCHAR(1),
		[WeekOfQuarter] VARCHAR(2),
		[WeekOfYear] VARCHAR(2),
		[Month] VARCHAR(2),
		[MonthName] VARCHAR(9),
		[MonthOfQuarter] VARCHAR(2),
		[Quarter] CHAR(1),
		[QuarterName] VARCHAR(9),
		[Year] CHAR(4),
		[YearName] CHAR(7),
		[MonthYear] CHAR(10),
		[MMYYYY] CHAR(6),
		[FirstDayOfMonth] DATE,
		[LastDayOfMonth] DATE,
		[FirstDayOfQuarter] DATE,
		[LastDayOfQuarter] DATE,
		[FirstDayOfYear] DATE,
		[LastDayOfYear] DATE,
		[IsHoliday] BIT,
		[IsWeekday] BIT,
		[Holiday] VARCHAR(50)
	)
GO

/*******************************************************************************************************************************************************/

DECLARE @StartDate DATETIME = '01/01/2012'
DECLARE @EndDate DATETIME = '01/01/2014'
DECLARE
	@DayOfWeekInMonth INT,
	@DayOfWeekInYear INT,
	@DayOfQuarter INT,
	@WeekOfMonth INT,
	@CurrentYear INT,
	@CurrentMonth INT,
	@CurrentQuarter INT

/*Table to store the day of week count for the month and year*/
DECLARE @DayOfWeek TABLE (DOW INT, MonthCount INT, QuarterCount INT, YearCount INT)
INSERT INTO @DayOfWeek VALUES (1, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (2, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (3, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (4, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (5, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (6, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (7, 0, 0, 0)

DECLARE @CurrentDate AS DATETIME = @StartDate
SET @CurrentMonth = DATEPART(MM, @CurrentDate)
SET @CurrentYear = DATEPART(YY, @CurrentDate)
SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)

/*******************************************************************************************************************************************************/

WHILE @CurrentDate < @EndDate
BEGIN
 
	/*Begin day of week logic*/
	IF @CurrentMonth != DATEPART(MM, @CurrentDate) 
	BEGIN
		UPDATE @DayOfWeek
		SET MonthCount = 0
		SET @CurrentMonth = DATEPART(MM, @CurrentDate)
	END
	
	IF @CurrentQuarter != DATEPART(QQ, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET QuarterCount = 0
		SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)
	END
	
	IF @CurrentYear != DATEPART(YY, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET YearCount = 0
		SET @CurrentYear = DATEPART(YY, @CurrentDate)
	END

	UPDATE @DayOfWeek
	SET 
		MonthCount = MonthCount + 1,
		QuarterCount = QuarterCount + 1,
		YearCount = YearCount + 1
	WHERE DOW = DATEPART(DW, @CurrentDate)

	SELECT
		@DayOfWeekInMonth = MonthCount,
		@DayOfQuarter = QuarterCount,
		@DayOfWeekInYear = YearCount
	FROM @DayOfWeek
	WHERE DOW = DATEPART(DW, @CurrentDate)
	/*End day of week logic*/
	
	INSERT INTO [dbo].[DimDate]
	SELECT
		CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) + RIGHT('0' + CONVERT(VARCHAR, DATEPART(MM, @CurrentDate)), 2) + RIGHT('0' + CONVERT(VARCHAR, DATEPART(DD, @CurrentDate)), 2) AS DateKey,
		@CurrentDate AS Date,
		RIGHT('0' + CONVERT(VARCHAR, DATEPART(MM, @CurrentDate)), 2) + '/' + RIGHT('0' + CONVERT(VARCHAR, DATEPART(DD, @CurrentDate)), 2) + '/' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) AS StandardDate,
		DATEPART(DD, @CurrentDate) AS Day,
		CASE 
			WHEN DATEPART(DD,@CurrentDate) IN (11,12,13) THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'th'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 1 THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'st'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 2 THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'nd'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 3 THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'rd'
			ELSE CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'th' 
			END AS DaySuffix,
		DATENAME(DW, @CurrentDate) AS DayName,
		DATEPART(DW, @CurrentDate) AS DayOfWeek,
		@DayOfWeekInMonth AS DayOfWeekInMonth,
		@DayOfWeekInYear AS DayOfWeekInYear,
		@DayOfQuarter AS DayOfQuarter,
		DATEPART(DY, @CurrentDate) AS DayOfYear,
		DATEPART(WW, @CurrentDate) + 1 - DATEPART(WW, CONVERT(VARCHAR, DATEPART(MM, @CurrentDate)) + '/1/' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate))) AS WeekOfMonth,
		(DATEDIFF(DD, DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0), @CurrentDate) / 7) + 1 AS WeekOfQuarter,
		DATEPART(WW, @CurrentDate) AS WeekOfYear,
		DATEPART(MM, @CurrentDate) AS Month,
		DATENAME(MM, @CurrentDate) AS MonthName,
		CASE
			WHEN DATEPART(MM, @CurrentDate) IN (1, 4, 7, 10) THEN 1
			WHEN DATEPART(MM, @CurrentDate) IN (2, 5, 8, 11) THEN 2
			WHEN DATEPART(MM, @CurrentDate) IN (3, 6, 9, 12) THEN 3
			END AS MonthOfQuarter,
		DATEPART(QQ, @CurrentDate) AS Quarter,
		CASE DATEPART(QQ, @CurrentDate)
			WHEN 1 THEN 'First'
			WHEN 2 THEN 'Second'
			WHEN 3 THEN 'Third'
			WHEN 4 THEN 'Fourth'
			END AS QuarterName,
		DATEPART(YEAR, @CurrentDate) AS Year,
		'CY ' + CONVERT(VARCHAR, DATEPART(YEAR, @CurrentDate)) AS YearName,
		LEFT(DATENAME(MM, @CurrentDate), 3) + '-' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) AS MonthYear,
		RIGHT('0' + CONVERT(VARCHAR, DATEPART(MM, @CurrentDate)),2) + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) AS MMYYYY,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, @CurrentDate) - 1), @CurrentDate))) AS FirstDayOfMonth,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, (DATEADD(MM, 1, @CurrentDate)))), DATEADD(MM, 1, @CurrentDate)))) AS LastDayOfMonth,
		DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0) AS FirstDayOfQuarter,
		DATEADD(QQ, DATEDIFF(QQ, -1, @CurrentDate), -1) AS LastDayOfQuarter,
		CONVERT(DATETIME, '01/01/' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate))) AS FirstDayOfYear,
		CONVERT(DATETIME, '12/31/' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate))) AS LastDayOfYear,
		NULL AS IsHoliday,
		CASE DATEPART(DW, @CurrentDate)
			WHEN 1 THEN 0
			WHEN 2 THEN 1
			WHEN 3 THEN 1
			WHEN 4 THEN 1
			WHEN 5 THEN 1
			WHEN 6 THEN 1
			WHEN 7 THEN 0
			END AS IsWeekday,
		NULL AS Holiday

	SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END

/*******************************************************************************************************************************************************/

	/*Add HOLIDAYS*/
	/*THANKSGIVING - Fourth THURSDAY in November*/
	UPDATE [dbo].[DimDate]
		SET Holiday = 'Thanksgiving Day'
	WHERE
		[Month] = 11 
		AND [DayOfWeek] = 'Thursday' 
		AND DayOfWeekInMonth = 4

	/*CHRISTMAS*/
	UPDATE [dbo].[DimDate]
		SET Holiday = 'Christmas Day'
	WHERE [Month] = 12 AND [Day] = 25

	/*4th of July*/
	UPDATE [dbo].[DimDate]
		SET Holiday = 'Independance Day'
	WHERE [Month] = 7 AND [Day] = 4

	/*New Years Day*/
	UPDATE [dbo].[DimDate]
		SET Holiday = 'New Year''s Day'
	WHERE [Month] = 1 AND [Day] = 1

	/*Memorial Day - Last Monday in May*/
	UPDATE [dbo].[DimDate]
		SET Holiday = 'Memorial Day'
	FROM [dbo].[DimDate]
	WHERE DateKey IN 
		(
		SELECT
			MAX(DateKey)
		FROM [dbo].[DimDate]
		WHERE
			[MonthName] = 'May'
			AND [DayOfWeek] = 'Monday'
		GROUP BY
			[Year],
			[Month]
		)

	/*Labor Day - First Monday in September*/
	UPDATE [dbo].[DimDate]
		SET Holiday = 'Labor Day'
	FROM [dbo].[DimDate]
	WHERE DateKey IN 
		(
		SELECT
			MIN(DateKey)
		FROM [dbo].[DimDate]
		WHERE
			[MonthName] = 'September'
			AND [DayOfWeek] = 'Monday'
		GROUP BY
			[Year],
			[Month]
		)

	/*Valentine's Day*/
	UPDATE [dbo].[DimDate]
		SET Holiday = 'Valentine''s Day'
	WHERE
		[Month] = 2 
		AND [Day] = 14

	/*Saint Patrick's Day*/
	UPDATE [dbo].[DimDate]
		SET Holiday = 'Saint Patrick''s Day'
	WHERE
		[Month] = 3
		AND [Day] = 17

	/*Martin Luthor King Day - Third Monday in January starting in 1983*/
	UPDATE [dbo].[DimDate]
		SET Holiday = 'Martin Luthor King Jr Day'
	WHERE
		[Month] = 1
		AND [Dayofweek] = 'Monday'
		AND [Year] >= 1983
		AND DayOfWeekInMonth = 3

	/*President's Day - Third Monday in February*/
	UPDATE [dbo].[DimDate]
		SET Holiday = 'President''s Day'
	WHERE
		[Month] = 2
		AND [Dayofweek] = 'Monday'
		AND DayOfWeekInMonth = 3

	/*Mother's Day - Second Sunday of May*/
	UPDATE [dbo].[DimDate]
		SET Holiday = 'Mother''s Day'
	WHERE
		[Month] = 5
		AND [Dayofweek] = 'Sunday'
		AND DayOfWeekInMonth = 2

	/*Father's Day - Third Sunday of June*/
	UPDATE [dbo].[DimDate]
		SET Holiday = 'Father''s Day'
	WHERE
		[Month] = 6
		AND [Dayofweek] = 'Sunday'
		AND DayOfWeekInMonth = 3

	/*Halloween 10/31*/
	UPDATE [dbo].[DimDate]
		SET Holiday = 'Halloween'
	WHERE
		[Month] = 10
		AND [Day] = 31

	/*Election Day - The first Tuesday after the first Monday in November*/
	BEGIN
		DECLARE @Holidays TABLE (ID INT IDENTITY(1,1), DateID int, Week TINYINT, YEAR CHAR(4), DAY CHAR(2))

		INSERT INTO @Holidays(DateID, [Year],[Day])
		SELECT
			DateKey,
			[Year],
			[Day]
		FROM [dbo].[DimDate]
		WHERE
			[Month] = 11
			AND [Dayofweek] = 'Monday'
		ORDER BY
			YEAR,
			DAY

		DECLARE @CNTR INT, @POS INT, @STARTYEAR INT, @ENDYEAR INT, @MINDAY INT

		SELECT
			@CURRENTYEAR = MIN([Year])
			, @STARTYEAR = MIN([Year])
			, @ENDYEAR = MAX([Year])
		FROM @Holidays

		WHILE @CURRENTYEAR <= @ENDYEAR
		BEGIN
			SELECT @CNTR = COUNT([Year])
			FROM @Holidays
			WHERE [Year] = @CURRENTYEAR

			SET @POS = 1

			WHILE @POS <= @CNTR
			BEGIN
				SELECT @MINDAY = MIN(DAY)
				FROM @Holidays
				WHERE
					[Year] = @CURRENTYEAR
					AND [Week] IS NULL

				UPDATE @Holidays
					SET [Week] = @POS
				WHERE
					[Year] = @CURRENTYEAR
					AND [Day] = @MINDAY

				SELECT @POS = @POS + 1
			END

			SELECT @CURRENTYEAR = @CURRENTYEAR + 1
		END

		UPDATE [dbo].[DimDate]
			SET Holiday = 'Election Day'				
		FROM [dbo].[DimDate] DT
			JOIN @Holidays HL ON (HL.DateID + 1) = DT.DateKey
		WHERE
			[Week] = 1
	END
	
	UPDATE [dbo].[DimDate]
		SET IsHoliday = CASE WHEN Holiday IS NULL THEN 0 WHEN Holiday IS NOT NULL THEN 1 END

/*******************************************************************************************************************************************************/
		
SELECT * FROM [dbo].[DimDate]


/*Add Fiscal date columns to DimDate*/
ALTER TABLE [dbo].[DimDate] ADD
	[FiscalDayOfYear] VARCHAR(3),
	[FiscalWeekOfYear] VARCHAR(3),
	[FiscalMonth] VARCHAR(2), 
	[FiscalQuarter] CHAR(1),
	[FiscalQuarterName] VARCHAR(9),
	[FiscalYear] CHAR(4),
	[FiscalYearName] CHAR(7),
	[FiscalMonthYear] CHAR(10),
	[FiscalMMYYYY] CHAR(6),
	[FiscalFirstDayOfMonth] DATE,
	[FiscalLastDayOfMonth] DATE,
	[FiscalFirstDayOfQuarter] DATE,
	[FiscalLastDayOfQuarter] DATE,
	[FiscalFirstDayOfYear] DATE,
	[FiscalLastDayOfYear] DATE
	GO

/*******************************************************************************************************************************************************
The following section needs to be populated for defining the fiscal calendar
*******************************************************************************************************************************************************/

DECLARE
	@dtFiscalYearStart SMALLDATETIME = 'January 01, 1995',
	@FiscalYear INT = 1995,
	@LastYear INT = 2025,
	@FirstLeapYearInPeriod INT = 1996

/*******************************************************************************************************************************************************/

DECLARE
	@iTemp INT,
	@LeapWeek INT,
	@CurrentDate DATETIME,
	@FiscalDayOfYear INT,
	@FiscalWeekOfYear INT,
	@FiscalMonth INT,
	@FiscalQuarter INT,
	@FiscalQuarterName VARCHAR(10),
	@FiscalYearName VARCHAR(7),
	@LeapYear INT,
	@FiscalFirstDayOfYear DATE,
	@FiscalFirstDayOfQuarter DATE,
	@FiscalFirstDayOfMonth DATE,
	@FiscalLastDayOfYear DATE,
	@FiscalLastDayOfQuarter DATE,
	@FiscalLastDayOfMonth DATE

/*Holds the years that have 455 in last quarter*/
DECLARE @LeapTable TABLE (leapyear INT)

/*TABLE to contain the fiscal year calendar*/
DECLARE @tb TABLE(
	PeriodDate DATETIME,
	[FiscalDayOfYear] VARCHAR(3),
	[FiscalWeekOfYear] VARCHAR(3),
	[FiscalMonth] VARCHAR(2), 
	[FiscalQuarter] VARCHAR(1),
	[FiscalQuarterName] VARCHAR(9),
	[FiscalYear] VARCHAR(4),
	[FiscalYearName] VARCHAR(7),
	[FiscalMonthYear] VARCHAR(10),
	[FiscalMMYYYY] VARCHAR(6),
	[FiscalFirstDayOfMonth] DATE,
	[FiscalLastDayOfMonth] DATE,
	[FiscalFirstDayOfQuarter] DATE,
	[FiscalLastDayOfQuarter] DATE,
	[FiscalFirstDayOfYear] DATE,
	[FiscalLastDayOfYear] DATE)

/*Populate the table with all leap years*/
SET @LeapYear = @FirstLeapYearInPeriod
WHILE (@LeapYear < @LastYear)
	BEGIN
		INSERT INTO @leapTable VALUES (@LeapYear)
		SET @LeapYear = @LeapYear + 5
	END

/*Initiate parameters before loop*/
SET @CurrentDate = @dtFiscalYearStart
SET @FiscalDayOfYear = 1
SET @FiscalWeekOfYear = 1
SET @FiscalMonth = 1
SET @FiscalQuarter = 1
SET @FiscalWeekOfYear = 1

IF (EXISTS (SELECT * FROM @LeapTable WHERE @FiscalYear = leapyear))
	BEGIN
		SET @LeapWeek = 1
	END
	ELSE
	BEGIN
		SET @LeapWeek = 0
	END

/*******************************************************************************************************************************************************/

/* Loop on days in interval*/
WHILE (DATEPART(yy,@CurrentDate) <= @LastYear)
BEGIN
	
/*SET fiscal Month*/
	SELECT @FiscalMonth = CASE 
		/*Use this section for a 4-5-4 calendar.  Every leap year the result will be a 4-5-5*/
		WHEN @FiscalWeekOfYear BETWEEN 1 AND 4 THEN 1 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 5 AND 9 THEN 2 /*5 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 10 AND 13 THEN 3 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 14 AND 17 THEN 4 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 18 AND 22 THEN 5 /*5 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 23 AND 26 THEN 6 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 27 AND 30 THEN 7 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 31 AND 35 THEN 8 /*5 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 36 AND 39 THEN 9 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 40 AND 43 THEN 10 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 44 AND (48+@LeapWeek) THEN 11 /*5 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN (49+@LeapWeek) AND (52+@LeapWeek) THEN 12 /*4 weeks (5 weeks on leap year)*/
		
		/*Use this section for a 4-4-5 calendar.  Every leap year the result will be a 4-5-5*/
		/*
		WHEN @FiscalWeekOfYear BETWEEN 1 AND 4 THEN 1 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 5 AND 8 THEN 2 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 9 AND 13 THEN 3 /*5 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 14 AND 17 THEN 4 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 18 AND 21 THEN 5 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 22 AND 26 THEN 6 /*5 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 27 AND 30 THEN 7 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 31 AND 34 THEN 8 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 35 AND 39 THEN 9 /*5 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 40 AND 43 THEN 10 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 44 AND (47+@leapWeek) THEN 11 /*4 weeks (5 weeks on leap year)*/
		WHEN @FiscalWeekOfYear BETWEEN (48+@leapWeek) AND (52+@leapWeek) THEN 12 /*5 weeks*/
		*/
	END

	/*SET Fiscal Quarter*/
	SELECT @FiscalQuarter = CASE 
		WHEN @FiscalMonth BETWEEN 1 AND 3 THEN 1
		WHEN @FiscalMonth BETWEEN 4 AND 6 THEN 2
		WHEN @FiscalMonth BETWEEN 7 AND 9 THEN 3
		WHEN @FiscalMonth BETWEEN 10 AND 12 THEN 4
	END
	
	SELECT @FiscalQuarterName = CASE 
		WHEN @FiscalMonth BETWEEN 1 AND 3 THEN 'First'
		WHEN @FiscalMonth BETWEEN 4 AND 6 THEN 'Second'
		WHEN @FiscalMonth BETWEEN 7 AND 9 THEN 'Third'
		WHEN @FiscalMonth BETWEEN 10 AND 12 THEN 'Fourth'
	END
	
	/*Set Fiscal Year Name*/
	SELECT @FiscalYearName = 'FY ' + CONVERT(VARCHAR, @FiscalYear)

	INSERT INTO @tb (PeriodDate, FiscalDayOfYear, FiscalWeekOfYear, fiscalMonth, FiscalQuarter, FiscalQuarterName, FiscalYear, FiscalYearName) VALUES 
	(@CurrentDate, @FiscalDayOfYear, @FiscalWeekOfYear, @FiscalMonth, @FiscalQuarter, @FiscalQuarterName, @FiscalYear, @FiscalYearName)

	/*SET next day*/
	SET @CurrentDate = DATEADD(dd, 1, @CurrentDate)
	SET @FiscalDayOfYear = @FiscalDayOfYear + 1
	SET @FiscalWeekOfYear = ((@FiscalDayOfYear-1) / 7) + 1


	IF (@FiscalWeekOfYear > (52+@LeapWeek))
	BEGIN
		/*Reset a new year*/
		SET @FiscalDayOfYear = 1
		SET @FiscalWeekOfYear = 1
		SET @FiscalYear = @FiscalYear + 1
		IF ( EXISTS (SELECT * FROM @leapTable WHERE @FiscalYear = leapyear))
		BEGIN
			SET @LeapWeek = 1
		END
		ELSE
		BEGIN
			SET @LeapWeek = 0
		END
	END
END

/*******************************************************************************************************************************************************/

/*Set first and last days of the fiscal months*/
UPDATE @tb
SET
	FiscalFirstDayOfMonth = minmax.StartDate,
	FiscalLastDayOfMonth = minmax.EndDate
FROM
@tb t,
	(
	SELECT FiscalMonth, FiscalQuarter, FiscalYear, MIN(PeriodDate) AS StartDate, MAX(PeriodDate) AS EndDate
	FROM @tb
	GROUP BY FiscalMonth, FiscalQuarter, FiscalYear
	) minmax
WHERE
	t.FiscalMonth = minmax.FiscalMonth AND
	t.FiscalQuarter = minmax.FiscalQuarter AND
	t.FiscalYear = minmax.FiscalYear 

/*Set first and last days of the fiscal quarters*/
UPDATE @tb
SET
	FiscalFirstDayOfQuarter = minmax.StartDate,
	FiscalLastDayOfQuarter = minmax.EndDate
FROM
@tb t,
	(
	SELECT FiscalQuarter, FiscalYear, min(PeriodDate) as StartDate, max(PeriodDate) as EndDate
	FROM @tb
	GROUP BY FiscalQuarter, FiscalYear
	) minmax
WHERE
	t.FiscalQuarter = minmax.FiscalQuarter AND
	t.FiscalYear = minmax.FiscalYear 

/*Set first and last days of the fiscal years*/
UPDATE @tb
SET
	FiscalFirstDayOfYear = minmax.StartDate,
	FiscalLastDayOfYear = minmax.EndDate
FROM
@tb t,
	(
	SELECT FiscalYear, min(PeriodDate) as StartDate, max(PeriodDate) as EndDate
	FROM @tb
	GROUP BY FiscalYear
	) minmax
WHERE
	t.FiscalYear = minmax.FiscalYear 

/*Set FiscalYearMonth*/
UPDATE @tb
SET
	FiscalMonthYear = 
		CASE FiscalMonth
		WHEN 1 THEN 'Jan'
		WHEN 2 THEN 'Feb'
		WHEN 3 THEN 'Mar'
		WHEN 4 THEN 'Apr'
		WHEN 5 THEN 'May'
		WHEN 6 THEN 'Jun'
		WHEN 7 THEN 'Jul'
		WHEN 8 THEN 'Aug'
		WHEN 9 THEN 'Sep'
		WHEN 10 THEN 'Oct'
		WHEN 11 THEN 'Nov'
		WHEN 12 THEN 'Dec'
		END + '-' + CONVERT(VARCHAR, FiscalYear)

/*Set FiscalMMYYYY*/
UPDATE @tb
SET
	FiscalMMYYYY = RIGHT('0' + CONVERT(VARCHAR, FiscalMonth),2) + CONVERT(VARCHAR, FiscalYear)

/*******************************************************************************************************************************************************/

UPDATE [dbo].[DimDate]
	SET
	FiscalDayOfYear = a.FiscalDayOfYear
	, FiscalWeekOfYear = a.FiscalWeekOfYear
	, FiscalMonth = a.FiscalMonth
	, FiscalQuarter = a.FiscalQuarter
	, FiscalQuarterName = a.FiscalQuarterName
	, FiscalYear = a.FiscalYear
	, FiscalYearName = a.FiscalYearName
	, FiscalMonthYear = a.FiscalMonthYear
	, FiscalMMYYYY = a.FiscalMMYYYY
	, FiscalFirstDayOfMonth = a.FiscalFirstDayOfMonth
	, FiscalLastDayOfMonth = a.FiscalLastDayOfMonth
	, FiscalFirstDayOfQuarter = a.FiscalFirstDayOfQuarter
	, FiscalLastDayOfQuarter = a.FiscalLastDayOfQuarter
	, FiscalFirstDayOfYear = a.FiscalFirstDayOfYear
	, FiscalLastDayOfYear = a.FiscalLastDayOfYear
FROM @tb a
	INNER JOIN [dbo].[DimDate] b ON a.PeriodDate = b.[Date]

/*******************************************************************************************************************************************************/

SELECT 
	*
FROM [dbo].[DimDate]