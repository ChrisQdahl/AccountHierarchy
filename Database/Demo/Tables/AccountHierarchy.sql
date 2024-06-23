CREATE TABLE [Demo].[AccountHierarchy] (
    [AccountHierarchyId] INT            IDENTITY (1, 1) NOT NULL,
    [CompanyId]          INT            NOT NULL,
    [ScheduleName]       NVARCHAR (20)  NOT NULL,
    [RowType]            NVARCHAR (10)  NOT NULL,
    [AccountNo]          NVARCHAR (20)  NOT NULL,
    [Level1]             NVARCHAR (100) NOT NULL,
    [Level2]             NVARCHAR (100) NOT NULL,
    [Level3]             NVARCHAR (100) NOT NULL,
    [Level1Sort]         INT            NOT NULL,
    [Level2Sort]         INT            NOT NULL,
    [Level3Sort]         INT            NOT NULL,
    [Level1RowNo]        VARCHAR (10)   NOT NULL,
    [Level2RowNo]        VARCHAR (10)   NOT NULL,
    [Level3RowNo]        VARCHAR (10)   NOT NULL,
    CONSTRAINT [PK_AccountHierarchy] PRIMARY KEY CLUSTERED ([AccountHierarchyId] ASC)
);





