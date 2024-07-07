CREATE VIEW [Demo].[vAccountSchedule]
AS
SELECT [AccountScheduleId]
      ,[ScheduleName]
      ,[Sort Order] = Source.[SortOrder]
      ,[Row No] = Source.[RowNo]
      ,[Description]
      ,[Totaling]
      ,[Totaling Type] = Source.[TotalingType]
FROM [Demo].[AccountSchedule] Source