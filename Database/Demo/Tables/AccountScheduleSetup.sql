CREATE TABLE [Demo].[AccountScheduleSetup] (
    [ScheduleName]           NVARCHAR (20)  NOT NULL,
    [Description]            NVARCHAR (100) NULL,
    [IncludeIncomeAccounts]  BIT            NOT NULL,
    [IncludeBalanceAccounts] BIT            NOT NULL,
    CONSTRAINT [PK_AccountHierarchySetup] PRIMARY KEY CLUSTERED ([ScheduleName] ASC)
);



