CREATE TABLE [Demo].[Account] (
    [AccountId]         INT            IDENTITY (1, 1) NOT NULL,
    [CompanyId]         INT            NOT NULL,
    [AccountNo]         NVARCHAR (20)  NOT NULL,
    [AccountName]       NVARCHAR (100) NOT NULL,
    [Account]           NVARCHAR (125) NOT NULL,
    [IncomeBalance]     TINYINT        NOT NULL,
    [IncomeBalanceDesc] NVARCHAR (20)  NOT NULL,
    CONSTRAINT [PK_Account] PRIMARY KEY CLUSTERED ([AccountId] ASC),
    CONSTRAINT [BK_Account] UNIQUE NONCLUSTERED ([CompanyId] ASC, [AccountNo] ASC)
);



