CREATE PROCEDURE [dbo].[TageAdvanced_IMP] as 

SET NOCOUNT ON

SET LANGUAGE German
SET DATEFIRST 1;

IF EXISTS (
    SELECT * FROM sysobjects WHERE id = object_id(N'GetEasterHolidays') 
    AND xtype IN (N'FN', N'IF', N'TF')
)
    DROP FUNCTION [dbo].[GetEasterHolidays]
GO

CREATE OR ALTER FUNCTION [dbo].[GetEasterHolidays](@year INT) 
RETURNS TABLE
WITH SCHEMABINDING
AS 
RETURN 

	(

		WITH x AS 

		(

		SELECT [DateKey] = CONVERT(DATE, RTRIM(@year) + '0' + RTRIM([Month]) 
			+ RIGHT('0' + RTRIM([Day]),2))
			FROM (SELECT [Month], [Day] = DaysToSunday + 28 - (31 * ([Month] / 4))
			FROM (SELECT [Month] = 3 + (DaysToSunday + 40) / 44, DaysToSunday
			FROM (SELECT DaysToSunday = paschal - ((@year + @year / 4 + paschal - 13) % 7)
			FROM (SELECT paschal = epact - (epact / 28)
			FROM (SELECT epact = (24 + 19 * (@year % 19)) % 30) 
			AS epact) AS paschal) AS dts) AS m) AS d
		)

		SELECT [DateKey], HolidayNames = 'Ostersonntag' FROM x
		UNION ALL SELECT DATEADD(DAY,-2,[DateKey]), 'Karfreitag'   FROM x
		UNION ALL SELECT DATEADD(DAY, 1,[DateKey]), 'Ostermontag' FROM x
		UNION ALL SELECT DATEADD(DAY, 39,[DateKey]), 'Christi Himmelfahrt' FROM x
		UNION ALL SELECT DATEADD(DAY, 50,[DateKey]), 'Pfingstmontag' FROM x
		UNION ALL SELECT DATEADD(DAY, 60,[DateKey]), 'Fronleichnam' FROM x

);
GO

IF OBJECT_ID('tempdb..#TageAdvanced') IS NOT NULL DROP TABLE #TageAdvanced
CREATE TABLE #TageAdvanced (
	[DateKey] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[Day] [tinyint] NOT NULL,
	[Weekday] [tinyint] NOT NULL,
	[WeekDayName] [varchar](10) NOT NULL,
	[WeekDayName_FirstLetter] [char](1) NOT NULL,
	[WeekDayName_TwoLetter] [char](2) NULL,
	[DOWInMonth] [tinyint] NOT NULL,
	[DayOfYear] [smallint] NOT NULL,
	[WeekOfMonth] [tinyint] NOT NULL,
	[WeekOfYear] [tinyint] NOT NULL,
	[Month] [tinyint] NOT NULL,
	[MonthName] [varchar](10) NOT NULL,
	[Quarter] [tinyint] NOT NULL,
	[QuarterName] [varchar](20) NOT NULL,
	[Year] [int] NOT NULL,
	[IsWeekend] [bit] NOT NULL,
	[IsHoliday] [bit] NOT NULL,
	[HolidayName] [varchar](50) NULL,
	[FirstDateofYear] [date] NULL,
	[LastDateofYear] [date] NULL,
	[FirstDateofQuater] [date] NULL,
	[LastDateofQuater] [date] NULL,
	[FirstDateofMonth] [date] NULL,
	[LastDateofMonth] [date] NULL,
	[FirstDateofWeek] [date] NULL,
	[LastDateofWeek] [date] NULL,
	[CurrentYear] [smallint] NULL,
	[CurrentQuater] [smallint] NULL,
	[CurrentMonth] [smallint] NULL,
	[CurrentWeek] [smallint] NULL,
	[CurrentDay] [smallint] NULL)
GO
DECLARE @CurrentDate DATE = (Select Left(Min([COPSYS_ID]),8) from [dbo].[Tage] where Right([COPSYS_ID],2) = '04')
DECLARE @EndDate DATE = (Select Left(Max([COPSYS_ID]),8) from [dbo].[Tage] where Right([COPSYS_ID],2) = '04')

WHILE @CurrentDate < @EndDate
BEGIN
   INSERT INTO #TageAdvanced (
      [DateKey],
      [Date],
      [Day],
      [Weekday],
      [WeekDayName],
      [WeekDayName_FirstLetter],
	  [WeekDayName_TwoLetter],
      [DOWInMonth],
      [DayOfYear],
      [WeekOfMonth],
      [WeekOfYear],
      [Month],
      [MonthName],
      [Quarter],
      [QuarterName],
      [Year],
      [IsWeekend],
      [IsHoliday],
	  [HolidayName],
      [FirstDateofYear],
      [LastDateofYear],
      [FirstDateofQuater],
      [LastDateofQuater],
      [FirstDateofMonth],
      [LastDateofMonth],
      [FirstDateofWeek],
      [LastDateofWeek]
      )
   SELECT DateKey = YEAR(@CurrentDate) * 10000 + MONTH(@CurrentDate) * 100 + DAY(@CurrentDate),
      DATE = @CurrentDate,
      Day = DAY(@CurrentDate),
      WEEKDAY = DATEPART(dw, @CurrentDate),
      WeekDayName = DATENAME(dw, @CurrentDate),
      WeekDayName_FirstLetter = LEFT(DATENAME(dw, @CurrentDate), 1),
	  WeekDayName_FirstLetter = LEFT(DATENAME(dw, @CurrentDate), 2),
      [DOWInMonth] = DAY(@CurrentDate),
      [DayOfYear] = DATENAME(dy, @CurrentDate),
      [WeekOfMonth] = DATEPART(WEEK, @CurrentDate) - DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM, 0, @CurrentDate), 0)) + 1,
      [WeekOfYear] = DATEPART(wk, @CurrentDate),
      [Month] = MONTH(@CurrentDate),
      [MonthName] = DATENAME(mm, @CurrentDate),
      [Quarter] = DATEPART(q, @CurrentDate),
      [QuarterName] = CASE 
         WHEN DATENAME(qq, @CurrentDate) = 1
            THEN 'Erstes Qurtal'
         WHEN DATENAME(qq, @CurrentDate) = 2
            THEN 'Zweites Quartal'
         WHEN DATENAME(qq, @CurrentDate) = 3
            THEN 'Drittes Quartal'
         WHEN DATENAME(qq, @CurrentDate) = 4
            THEN 'Viertes Quartal'
         END,
      [Year] = YEAR(@CurrentDate),
      [IsWeekend] = CASE 
         WHEN DATENAME(dw, @CurrentDate) = 'Sonntag'
            OR DATENAME(dw, @CurrentDate) = 'Samstag'
            THEN 1
         ELSE 0
         END,
      [IsHoliday] = 
	  	  Case WHEN CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-01-01' AS DATE) = @CurrentDate THEN 1
		WHEN CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-05-01' AS DATE) = @CurrentDate Then 1
		WHEN CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-10-03' AS DATE) = @CurrentDate Then 1
		WHEN CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-11-01' AS DATE) = @CurrentDate Then 1
		WHEN CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-12-25' AS DATE) = @CurrentDate Then 1
		WHEN CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-12-26' AS DATE) = @CurrentDate Then 1
		ELSE 0 END,
	  [HolidayName] = 
	  Case WHEN CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-01-01' AS DATE) = @CurrentDate THEN 'Neujahr'
		WHEN CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-05-01' AS DATE) = @CurrentDate Then 'Tag der Arbeit'
		WHEN CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-10-03' AS DATE) = @CurrentDate Then 'Tag der Deutschen Einheit'
		WHEN CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-11-01' AS DATE) = @CurrentDate Then 'Allerheiligen'
		WHEN CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-12-25' AS DATE) = @CurrentDate Then 'Weihnachtstag'
		WHEN CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-12-26' AS DATE) = @CurrentDate Then 'Zweiter Weihnachtsfeiertag'
		ELSE NULL END,
      [FirstDateofYear] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-01-01' AS DATE),
      [LastDateofYear] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-12-31' AS DATE),
      [FirstDateofQuater] = DATEADD(qq, DATEDIFF(qq, 0, GETDATE()), 0),
      [LastDateofQuater] = DATEADD(dd, - 1, DATEADD(qq, DATEDIFF(qq, 0, GETDATE()) + 1, 0)),
      [FirstDateofMonth] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-' + CAST(MONTH(@CurrentDate) AS VARCHAR(2)) + '-01' AS DATE),
      [LastDateofMonth] = EOMONTH(@CurrentDate),
      [FirstDateofWeek] = DATEADD(dd, - (DATEPART(dw, @CurrentDate) - 1), @CurrentDate),
      [LastDateofWeek] = DATEADD(dd, 7 - (DATEPART(dw, @CurrentDate)), @CurrentDate)

	
   SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END


;WITH TageAdvancedCTE AS 
    (

      SELECT d.[DateKey], d.[IsHoliday], d.[HolidayName], h.HolidayNames
        FROM #TageAdvanced AS d
        CROSS APPLY dbo.GetEasterHolidays(d.[Year]) AS h
        WHERE d.[DateKey] = cast(convert(char(8), h.[DateKey], 112) as int)

    )

UPDATE TageAdvancedCTE SET [IsHoliday] = 1, [HolidayName] = HolidayNames;

--Update current date information
UPDATE #TageAdvanced
SET CurrentYear = DATEDIFF(yy, GETDATE(), DATE),
   CurrentQuater = DATEDIFF(q, GETDATE(), DATE),
   CurrentMonth = DATEDIFF(m, GETDATE(), DATE),
   CurrentWeek = DATEDIFF(ww, GETDATE(), DATE),
   CurrentDay = DATEDIFF(dd, GETDATE(), DATE)

Select [COPSYS_ID]
,[COPSYS_ORDER]
,[COPSYS_PID]
,[COPSYS_DIM_NAME]
,[Datum]
,[Day]
,[Weekday]
,[WeekDayName]
,[WeekDayName_FirstLetter]
,[WeekDayName_TwoLetter]
,[DOWInMonth]
,[DayOfYear]
,[WeekOfMonth]
,[WeekOfYear]
,[Month]
,[MonthName]
,[Quarter]
,[QuarterName]
,[Year]
,[IsWeekend]
,[IsHoliday]
,ISNULL([HolidayName],'Kein Feiertag')
,[FirstDateofYear]
,[LastDateofYear]
,[FirstDateofQuater]
,[LastDateofQuater]
,[FirstDateofMonth]
,[LastDateofMonth]
,[FirstDateofWeek]
,[LastDateofWeek]
,[CurrentYear]
,[CurrentQuater]
,[CurrentMonth]
,[CurrentWeek]
,[CurrentDay]

from [dbo].[Tage] Tage
inner join #TageAdvanced TageAdvanced
on Tage.Datum = TageAdvanced.Date

SET LANGUAGE English
SET DATEFIRST 7;
