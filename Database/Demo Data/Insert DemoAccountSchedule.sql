TRUNCATE TABLE [Demo].[AccountSchedule];

INSERT [Demo].[AccountSchedule]
    ([ScheduleName],[SortOrder],[RowNo],[Description],[Totaling],[TotalingType])
VALUES
    ('PL',10000,'R1000','Turnover','10999..11460','Account'),
    ('PL',20000,'R1010','Turnover total','R1000','Group'),
    ('PL',30000,'R1020','Costs of goods sold','20000..20998','Account'),
    ('PL',40000,'R1030','Costs of goods sold','R1020','Group'),
    ('PL',50000,'R1040','CM I','R1010+R1030','SubTotal'),
    ('PL',60000,'R1050','Wages','22000..23998','Account'),
    ('PL',70000,'R1060','Other costs, wages','25000..25997','Account'),
    ('PL',80000,'R1070','Direct Wages total','R1050..R1060','Group'),
    ('PL',90000,'R1080','CM II','R1040+R1070','SubTotal'),
    ('PL',100000,'R1090','Property costs','29999..30998','Account'),
    ('PL',110000,'R1100','Insurance','31999..32900','Account'),
    ('PL',120000,'R1110','Consulting and advisory services','32999..33900','Account'),
    ('PL',120001,'R1110','Duplicate RowNo','33900|33901','Account'),
    ('PL',130000,'R1120','Conferences and courses','33999..34900','Account'),
    ('PL',140000,'R1130','Subscriptions','34999..35900','Account'),
    ('PL',150000,'R1140','Miscellaneous purchases','35999..36900','Account'),
    ('PL',160000,'R1150','Travel and transportation','36999..37900|36680','Account'),
    ('PL',170000,'R1160','Marketing','37999..39500','Account'),
    ('PL',180000,'R1170','Other expenses','39515..39900','Account'),
    ('PL',190000,'R1180','Total fixed costs','R1090..R1170','Group'),
    ('PL',200000,'R1190','EBITDA','R1080+R1180','SubTotal'),
    ('PL',210000,'R1200','Depreciation','39999..40997','Account'),
    ('PL',220000,'R1210','EBIT','R1190+R1200','SubTotal'),
    ('PL',230000,'R1220','Financing','40999..41997','Account'),
    ('PL',240000,'R1230','Profit before tax','R1210','SubTotal'),
    ('PL',250000,'R1240','Income tax','41999..42997','Account'),
    ('PL',260000,'R1250','Profit after tax','R1230+R1240','SubTotal'),
    ('BS',100,'R100','Balance','50100..50300','Account');