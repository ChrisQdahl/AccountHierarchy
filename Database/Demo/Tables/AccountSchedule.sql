CREATE TABLE [Demo].[AccountSchedule] (
    [AccountScheduleId] INT            IDENTITY (1, 1) NOT NULL,
    [ScheduleName]      NVARCHAR (20)  NOT NULL,
    [SortOrder]         INT            NOT NULL,
    [RowNo]             NVARCHAR (10)  NOT NULL,
    [Description]       NVARCHAR (100) NOT NULL,
    [Totaling]          NVARCHAR (250) NOT NULL,
    [TotalingType]      NVARCHAR (10)  NOT NULL,
    CONSTRAINT [PK_AccountSchedule] PRIMARY KEY CLUSTERED ([AccountScheduleId] ASC)
);



