TRUNCATE TABLE [Demo].[AccountScheduleSetup];

INSERT [Demo].[AccountScheduleSetup]
    ([ScheduleName],[Description],[IncludeIncomeAccounts],[IncludeBalanceAccounts])
VALUES
    ('PL', 'Profit & Loss Statement', 1, 0),
    ('BS', 'Balance Sheet Statement', 0, 1),
    ('CF', 'Cash Flow Statement', 1, 1);