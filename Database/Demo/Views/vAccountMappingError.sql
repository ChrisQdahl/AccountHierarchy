CREATE VIEW [Demo].[vAccountMappingError]
AS
SELECT [AccountScheduleId]
      ,[Error] = Source.[ErrorDesc]
FROM [Demo].[AccountMappingError] Source