CREATE VIEW [Demo].[vAccountScheduleSetup]
AS
SELECT [ScheduleName]
      ,[Account Schedule] = Source.[Description]
      ,[Include Income Accounts] = Source.[IncludeIncomeAccounts]
      ,[Include Balance Accounts] = Source.[IncludeBalanceAccounts]
FROM [Demo].[AccountScheduleSetup] Source