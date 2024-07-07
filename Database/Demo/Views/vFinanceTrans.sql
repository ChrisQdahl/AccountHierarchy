CREATE VIEW [Demo].[vFinanceTrans]
AS
SELECT [CompanyId]
      ,[AccountId]
      ,[Posting Date] = Source.[PostingDate]
      ,[Amount]
FROM [Demo].[FinanceTrans] Source