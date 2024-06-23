-- =============================================
-- Author:      CKS
-- Create date: 20240625
-- Description: Takes [AccountSchedule], [Account] and [AccountScheduleSetup] as input.
--                  Creates Many:Many relationship between Accounts and SubTotals in [AccountMapping].
--                  Creates Account-Grouping and SubTotals in [AccountHierarchy].
--
-- Assumptions:
--  - Any given AccountNo is used in the same way across Companies.
--      - For example, a single account number can't be turnover in one company and COGS in another.
--
-- Input:
--      1. [AccountSchedule]
--          - Any input can work, but make sure to transform your input to the stated ColumnNames and Datatypes.
--          - No Primary Key or Uniqueness is assumed in the code.
--      2. [Account]
--          - Dimension-table holding all Accounts (AccountNo and Income/Balance flag needed)
--          - Can include same AccountNo from multiple Companies
--      3. [AccountScheduleSetup]
--          - Specifies which ScheduleNames should be processed along with which Account Type(s) they each should include (Income and/or Balance).
-- =============================================
CREATE PROCEDURE [Demo].[Update_AccountHierarchy]
AS
BEGIN
/* ##### #AccountSchedule ##### */
    DROP TABLE IF EXISTS #AccountSchedule;

    /* ##### Pre-Execution Cleanup ##### */
    SELECT [ScheduleName] = Schedule.[ScheduleName]
          ,[SortOrder] = Schedule.[SortOrder] 
          ,[RowNo] = Schedule.[RowNo]
          ,[RowType] = Schedule.[TotalingType]
          ,[Description] = Schedule.[Description]
          ,[Totaling] = REPLACE(REPLACE(REPLACE(REPLACE(Schedule.[Totaling], '...', '.'), '..', '.'), '+', '|'), ' ', '') -- To avoid common typos and simplify subsequent code.
    INTO #AccountSchedule
    FROM [Demo].[AccountSchedule] Schedule
    INNER JOIN [Demo].[AccountScheduleSetup] Setup -- Only Schedules specified in Setup will be processed.
        ON Setup.[ScheduleName] = Schedule.[ScheduleName];

/* ##### Unique Account and RowNo (for use with interval specifications) ##### */
    /* ##### AccountNo ##### */
    DROP TABLE IF EXISTS #AccountNo;
    
    SELECT [AccountNo] = A.[AccountNo]
          ,[SortableAccountNo] = RIGHT(CONCAT('00000000000000000000', A.[AccountNo]), 20)  -- Added to be able to sort Int AccountNo correctly and still allow non-numeric AccountNo.
          ,[IncomeBalance] = A.[IncomeBalance]
    INTO #AccountNo
    FROM [Demo].[Account] A
    GROUP BY A.[AccountNo]
            ,A.[IncomeBalance];

    /* ##### RowNo ##### */
    DROP TABLE IF EXISTS #RowNo;

    SELECT [ScheduleName]
          ,[RowNo]
    INTO #RowNo
    FROM #AccountSchedule AccSch
    GROUP BY [ScheduleName]
            ,[RowNo];

/* ##### Creating tables that will hold the Logic-Output ##### */ -- COLLATE added in case TempDb and Current DB has different collations
    /* ##### Account ##### */
    DROP TABLE IF EXISTS #Account;

    CREATE TABLE #Account (
        [Id] INT IDENTITY(1,1),
        [ScheduleName] NVARCHAR(20) COLLATE database_default,
        [SortOrder] INT,
        [RowNo] NVARCHAR(10) COLLATE database_default,
        [RowType] NVARCHAR(10) COLLATE database_default,
        [Description] NVARCHAR(100) COLLATE database_default,
        [AccountNo] NVARCHAR(20) COLLATE database_default
        );

    /* ##### Group / SubTotal ##### */
    DROP TABLE IF EXISTS #Group_SubTotal; 

    CREATE TABLE #Group_SubTotal (
        [Id] INT IDENTITY(1,1),
        [ScheduleName] NVARCHAR(20) COLLATE database_default,
        [SortOrder] INT,
        [RowNo] NVARCHAR(10) COLLATE database_default,
        [RowType] NVARCHAR(10) COLLATE database_default,
        [Description] NVARCHAR(100) COLLATE database_default,
        [ChildRowNo] NVARCHAR(10) COLLATE database_default
        );

/* ##### Defining Cursor and Variables for Looping the AccountSchedule Input ##### */
    DECLARE @ScheduleName NVARCHAR(20),
            @SortOrder INT,
            @RowNo NVARCHAR(10),
            @RowType NVARCHAR(10),
            @Description NVARCHAR(100),
            @Totaling NVARCHAR(250);

    DECLARE AccountScheduleCursor CURSOR FOR
    SELECT [ScheduleName]
          ,[SortOrder]
          ,[RowNo]
          ,[RowType]
          ,[Description]
          ,[Totaling]
    FROM #AccountSchedule;

    OPEN AccountScheduleCursor;

    FETCH NEXT FROM AccountScheduleCursor
        INTO @ScheduleName, @SortOrder, @RowNo, @RowType, @Description, @Totaling;

/* ##### Finding all Accounts and Rows included in the Totaling ##### */
    WHILE @@FETCH_STATUS = 0 BEGIN
    /* ##### Account ##### */
        IF @RowType = 'Account' BEGIN
            INSERT #Account (
                [ScheduleName],
                [SortOrder],[RowNo],
                [RowType],[Description],[AccountNo]
                )
            SELECT [ScheduleName] = @ScheduleName
                  ,[SortOrder] = @SortOrder
                  ,[RowNo] = @RowNo
                  ,[RowType] = @RowType
                  ,[Description] = @Description
                  ,[AccountNo] = ANo.[AccountNo]
            FROM (
                SELECT [FromAccountNo] = RIGHT(CONCAT('00000000000000000000', CASE
                            WHEN [value] LIKE '%.%' THEN LEFT([value], CHARINDEX('.', [value]) - 1)
                            ELSE [value]
                            END), 20)
                       ,[ToAccountNo] = RIGHT(CONCAT('00000000000000000000', CASE
                            WHEN [value] LIKE '%.%' THEN RIGHT([value], CHARINDEX('.', REVERSE([value])) - 1)
                            ELSE [value]
                            END), 20)
                FROM STRING_SPLIT(@Totaling, '|')
                ) A
            INNER JOIN [Demo].[AccountScheduleSetup] Setup
                ON Setup.[ScheduleName] = @ScheduleName
            INNER JOIN #AccountNo ANo
                ON ANo.[SortableAccountNo] BETWEEN A.[FromAccountNo] AND A.[ToAccountNo]
                AND (
                       (ANo.[IncomeBalance] = 0 AND Setup.[IncludeIncomeAccounts]  = 1)
                    OR (ANo.[IncomeBalance] = 1 AND Setup.[IncludeBalanceAccounts] = 1)
                    );
        END;
    /* ##### Group / SubTotal ##### */
        ELSE IF @RowType IN ('Group', 'SubTotal') BEGIN
            INSERT #Group_SubTotal (
                [ScheduleName],
                [SortOrder],[RowNo],
                [RowType],[Description],[ChildRowNo]
                )
            SELECT [ScheduleName] = @ScheduleName
                  ,[SortOrder] = @SortOrder
                  ,[RowNo] = @RowNo
                  ,[RowType] = @RowType
                  ,[Description] = @Description
                  ,[ChildRowNo] = RNo.[RowNo]
            FROM (
                SELECT [FromRowNo] = CASE
                            WHEN [value] LIKE '%.%' THEN LEFT([value], CHARINDEX('.', [value]) - 1)
                            ELSE [value]
                            END
                       ,[ToRowNo] = CASE
                            WHEN [value] LIKE '%.%' THEN RIGHT([value], CHARINDEX('.', REVERSE([value])) - 1)
                            ELSE [value]
                            END
                FROM STRING_SPLIT(@Totaling, '|')
                ) R
            INNER JOIN #RowNo RNo
                ON RNo.[ScheduleName] = @ScheduleName
                AND RNo.[RowNo] BETWEEN R.[FromRowNo] AND R.[ToRowNo];
        END;

        FETCH NEXT FROM AccountScheduleCursor
            INTO @ScheduleName, @SortOrder, @RowNo, @RowType, @Description, @Totaling;
    END;

    CLOSE AccountScheduleCursor;  
    DEALLOCATE AccountScheduleCursor;

/* ######################### [AccountHierarchy] ######################### */
    TRUNCATE TABLE [Demo].[AccountHierarchy];

    /* ##### SubTotal ##### */
    INSERT [Demo].[AccountHierarchy] (
        [ScheduleName],
        [CompanyId],[RowType],[AccountNo],
        [Level1],[Level2],[Level3],
        [Level1Sort],[Level2Sort],[Level3Sort],
        [Level1RowNo],[Level2RowNo],[Level3RowNo]
        )
    SELECT [ScheduleName]
          ,[CompanyId] = 0  -- Shared Chart of Accounts
          ,[RowType] = [RowType]
          ,[AccountNo] = 'SubTotal'
          ,[Level1] = [Description]
          ,[Level2] = [Description]
          ,[Level3] = [Description]
          ,[Level1Sort] = [SortOrder]
          ,[Level2Sort] = [SortOrder]
          ,[Level3Sort] = [SortOrder]
          ,[Level1RowNo] = [RowNo]
          ,[Level2RowNo] = [RowNo]
          ,[Level3RowNo] = [RowNo]
    FROM #AccountSchedule
    WHERE [RowType] = 'SubTotal';

    /* ##### Account incl. (up to) 3 levels of Grouping ##### */
    INSERT [Demo].[AccountHierarchy] (
        [ScheduleName],
        [CompanyId],[RowType],[AccountNo],
        [Level1],[Level2],[Level3],
        [Level1Sort],[Level2Sort],[Level3Sort],
        [Level1RowNo],[Level2RowNo],[Level3RowNo]
        )
    SELECT [ScheduleName] = A.[ScheduleName]
          ,[CompanyId] = 0  -- Shared Chart of Accounts
          ,[RowType] = A.[RowType]
          ,[AccountNo] = A.[AccountNo]
          ,[Level1] = COALESCE(G2.[Description], G1.[Description], A.[Description])
          ,[Level2] = COALESCE(G1.[Description], A.[Description])
          ,[Level3] = A.[Description]
          ,[Level1Sort] = COALESCE(G2.[SortOrder], G1.[SortOrder], A.[SortOrder])
          ,[Level2Sort] = COALESCE(G1.[SortOrder], A.[SortOrder])
          ,[Level3Sort] = A.[SortOrder]
          ,[Level1RowNo] = COALESCE(G2.[RowNo], G1.[RowNo], A.[RowNo])
          ,[Level2RowNo] = COALESCE(G1.[RowNo], A.[RowNo])
          ,[Level3RowNo] = A.[RowNo]
    FROM #Account A
    LEFT JOIN #Group_SubTotal G1
        ON G1.[ScheduleName] = A.[ScheduleName]
        AND G1.[RowType] = 'Group'
        AND G1.[ChildRowNo] = A.[RowNo]
    LEFT JOIN #Group_SubTotal G2
        ON G2.[ScheduleName] = G1.[ScheduleName]
        AND G2.[RowType] = 'Group'
        AND G2.[ChildRowNo] = G1.[RowNo];

/* ######################### [AccountMapping] ######################### */
-- Many-to-Many Mapping-table between AccountHierarchy and Account Dimension
--      All Accounts are mapped to themselves
--      All relevant Accounts are also mapped to a given SubTotal
    
    /* ##### MappingSource ##### */
    DROP TABLE IF EXISTS #MappingSource; 

    CREATE TABLE #MappingSource (
        [ScheduleName] NVARCHAR(20) COLLATE database_default,
        [LevelNo] INT,
        [RowNo] NVARCHAR(10) COLLATE database_default,
        [ParentRowNo] NVARCHAR(10) COLLATE database_default,
        [ChildRowNo] NVARCHAR(10) COLLATE database_default
        );

    /* ##### Initiating with "Ground Level" ##### */
    INSERT #MappingSource (
        [ScheduleName],
        [LevelNo],[RowNo],
        [ParentRowNo],[ChildRowNo]
        )
    SELECT [ScheduleName] = G.[ScheduleName]
          ,[LevelNo] = 0
          ,[RowNo] = G.[RowNo]
          ,[ParentRowNo] = G.[RowNo]
          ,[ChildRowNo] = G.[ChildRowNo]
    FROM #Group_SubTotal G
    WHERE G.[RowType] = 'SubTotal';

    DECLARE @RowCount INT = 1,  -- Initiating RowCount to 1 to get into Loop
            @LevelNo INT = 1;

    /* ##### Looping until all Parent-Child references have been resolved ##### */
    WHILE @RowCount > 0 BEGIN   
        INSERT #MappingSource (
            [ScheduleName],
            [LevelNo],[RowNo],
            [ParentRowNo],[ChildRowNo]
            )
        SELECT [ScheduleName] = G.[ScheduleName] 
              ,[LevelNo] = @LevelNo
              ,[RowNo] = G.[RowNo]
              ,[ParentRowNo] = G1.[RowNo]
              ,[ChildRowNo] = G1.[ChildRowNo]
        FROM #MappingSource G
        INNER JOIN #Group_SubTotal G1
            ON G1.[ScheduleName] = G.[ScheduleName] 
            AND G1.[RowNo] = G.[ChildRowNo]
        WHERE G.[LevelNo] = @LevelNo - 1;

        SET @RowCount = @@ROWCOUNT;

        SET @LevelNo = @LevelNo + 1;
    END;

    TRUNCATE TABLE [Demo].[AccountMapping];

    /* ##### Insert Account-Account -Mapping ##### */
    INSERT [Demo].[AccountMapping] (
        [AccountHierarchyId],[AccountId]
        )
    SELECT [AccountHierarchyId] = AH.[AccountHierarchyId]
          ,[AccountId] = A.[AccountId]
    FROM [Demo].[AccountHierarchy] AH
    INNER JOIN [Demo].[Account] A
        ON A.[AccountNo] = AH.[AccountNo]
    WHERE AH.[RowType] = 'Account';

    /* ##### Insert SubTotal-Account -Mapping ##### */
    INSERT [Demo].[AccountMapping] (
        [AccountHierarchyId],[AccountId]
        )
    SELECT [AccountHierarchyId] = AH.[AccountHierarchyId]
          ,[AccountId] = A.[AccountId]
    FROM #MappingSource M
    INNER JOIN [Demo].[AccountHierarchy] AH
        ON AH.[ScheduleName] = M.[ScheduleName]
        AND AH.[Level3RowNo] = M.[RowNo]
    INNER JOIN [Demo].[AccountHierarchy] AM
        ON AM.[ScheduleName] = M.[ScheduleName]
        AND AM.[Level3RowNo] = M.[ChildRowNo]
    INNER JOIN [Demo].[Account] A
        ON A.[AccountNo] = AM.[AccountNo]
    WHERE AM.[RowType] = 'Account';
END