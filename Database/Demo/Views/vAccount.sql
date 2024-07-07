CREATE VIEW [Demo].[vAccount]
AS
SELECT [AccountId]
      ,[Account No] = Source.[AccountNo]
      ,[Account Name] = Source.[AccountName]
      ,[Account]
      ,[Income/Balance] = Source.[IncomeBalanceDesc]
FROM [Demo].[Account] Source