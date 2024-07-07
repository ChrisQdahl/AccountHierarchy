CREATE VIEW [Demo].[vAccountHierarchy]
AS
SELECT [AccountHierarchyId]
      ,[ScheduleName]
      ,[CompanyId]
      ,[RowType]
      ,[Level 1] = Source.[Level1]
      ,[Level 2] = Source.[Level2]
      ,[Level 3] = Source.[Level3]
      ,[Level1Sort]
      ,[Level2Sort]
      ,[Level3Sort]
FROM [Demo].[AccountHierarchy] Source