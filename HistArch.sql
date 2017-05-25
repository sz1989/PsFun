/*
--- Sqls to Reset make sure filegroup: HIST exist
ALTER TABLE dbo.[setamper] SET (SYSTEM_VERSIONING = OFF);
drop table history.setamper;

CREATE TABLE [history].[setamper](
	[enddate] [datetime2](3) NOT NULL,
	[ipm_as_of_date] [datetime2](3) NULL,
	[cycle_dt] [datetime2](3) NULL,
	[sp_aa_coeff] [float] NULL,
	[sp_a_coeff] [float] NULL,
	[sp_bbb_coeff] [float] NULL,
	[sp_bb_coeff] [float] NULL,
	[earn_close_dt] [datetime2](3) NULL,
	[fsa_name] [varchar](40) NULL,
	[fsa_num] [char](2) NULL,
	[uk_num] [char](2) NULL,
	[dflt_min_smkt_irr] [float] NULL,
	[dflt_min_smkt_daily_capac] [money] NULL,
	[dflt_min_smkt_rate_bp] [float] NULL,
	[min_smkt_prem] [money] NULL,
	[cusip_fee] [money] NULL,
	[cycle_sched_dt] [datetime2](3) NULL,
	[cycle_run_dt] [datetime2](3) NULL,
	[amg_pv_cycle_dt] [datetime2](3) NULL,
	[cycle_completion_flg] [char](1) NULL,
	[muni_load_dt] [datetime2](3) NULL,
	[wf_open_month] [date] NULL,
	[mac_dflt_min_smkt_irr] [float] NULL,
	[mac_dflt_min_smkt_rate_bp] [float] NULL,
	[acct_locked_dt] [datetime2](3) NULL,
	[updated_by_id] [varchar](32) NULL,
	[current_login] [nvarchar](128) NULL,
	[SysStartTime] [datetime2](3) NOT NULL,
	[SysEndTime] [datetime2](3) NOT NULL
);
CREATE CLUSTERED INDEX [ix_setamper_history] ON [history].[setamper]
([SysEndTime] ASC,	[SysStartTime] ASC);

INSERT INTO history.setamper SELECT * FROM dbo._setamper;
ALTER TABLE dbo.[setamper] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [history].[setamper], DATA_CONSISTENCY_CHECK=ON));

begin tran;
drop PARTITION SCHEME sch_Partition_setamper_By_SysEndTime;
drop PARTITION FUNCTION fn_Partition_setamper_By_SysEndTime;
commit;
*/

/* ----- sqls to create partition needs to create filegroup: HIST ----------*/
BEGIN TRAN;    
/*Create partition function*/  
CREATE PARTITION FUNCTION [fn_Partition_setamper_By_SysEndTime] (datetime2(3))   
                    AS RANGE LEFT FOR VALUES (N'2016-10-31T23:59:59.999',N'2016-11-30T23:59:59.999',N'2016-12-31T23:59:59.999') ;
  
/*Create partition scheme*/  
CREATE PARTITION SCHEME [sch_Partition_setamper_By_SysEndTime] AS PARTITION [fn_Partition_setamper_By_SysEndTime]   
                        TO ([HIST], [HIST], [HIST], [HIST]);  
                        
/*Re-create index to be partition-aligned with the partitioning schema*/  
CREATE CLUSTERED INDEX [ix_setamper_history] ON [history].[setamper]
(  [SysEndTime] ASC,  [SysStartTime] ASC  )  
            WITH   
                        (PAD_INDEX = OFF  
                        , STATISTICS_NORECOMPUTE = OFF  
                        , SORT_IN_TEMPDB = OFF  
                        , DROP_EXISTING = ON  
                        , ONLINE = OFF  
                        , ALLOW_ROW_LOCKS = ON  
                        , ALLOW_PAGE_LOCKS = ON  
                        , DATA_COMPRESSION = PAGE)  
            ON [sch_Partition_setamper_By_SysEndTime] ([SysEndTime]);
COMMIT;  
/*
*/

/*------- sql to create staging schema ----------- */
USE [das]
GO
CREATE SCHEMA [staging]
GO
*/

/*
BEGIN TRANSACTION  
-- drop table [staging].[setamper]
 /*(1)  Create staging table */  
CREATE TABLE [staging].[setamper]  
(  
    [enddate] [datetime2](3) NOT NULL,
    [ipm_as_of_date] [datetime2](3) NULL,
    [cycle_dt] [datetime2](3) NULL,
    [sp_aa_coeff] [float] NULL,
    [sp_a_coeff] [float] NULL,
    [sp_bbb_coeff] [float] NULL,
    [sp_bb_coeff] [float] NULL,
    [earn_close_dt] [datetime2](3) NULL,
    [fsa_name] [varchar](40) NULL,
    [fsa_num] [char](2) NULL,
    [uk_num] [char](2) NULL,
    [dflt_min_smkt_irr] [float] NULL,
    [dflt_min_smkt_daily_capac] [money] NULL,
    [dflt_min_smkt_rate_bp] [float] NULL,
    [min_smkt_prem] [money] NULL,
    [cusip_fee] [money] NULL,
    [cycle_sched_dt] [datetime2](3) NULL,
    [cycle_run_dt] [datetime2](3) NULL,
    [amg_pv_cycle_dt] [datetime2](3) NULL,
    [cycle_completion_flg] [char](1) NULL,
    [muni_load_dt] [datetime2](3) NULL,
    [wf_open_month] [date] NULL,
    [mac_dflt_min_smkt_irr] [float] NULL,
    [mac_dflt_min_smkt_rate_bp] [float] NULL,
    [acct_locked_dt] [datetime2](3) NULL,
    [updated_by_id] [varchar](32) NULL,
    [current_login] [nvarchar](128) NULL,
    [SysStartTime] [datetime2](3) NOT NULL,
    [SysEndTime] [datetime2](3) NOT NULL  
) ON [HIST]  WITH  ( DATA_COMPRESSION = PAGE )  
  
/*(2) Create index on the same filegroups as the partition that will be switched out*/  
 CREATE CLUSTERED INDEX [ix_staging_setamper] ON [staging].[setamper]  
 (  [SysEndTime] ASC, [SysStartTime] ASC  )  WITH   (  PAD_INDEX = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON ) ON [HIST]  
  
 /*(3) Create constraints matching the partition that will be switched out*/  
ALTER TABLE [staging].[setamper] WITH CHECK ADD CONSTRAINT [chk_staging_setamper_partition_1] CHECK  ([SysEndTime]<=N'2016-10-31T23:59:59.999')  
ALTER TABLE [staging].[setamper] CHECK CONSTRAINT [chk_staging_setamper_partition_1]  
  
/*(4) Switch partition to staging table*/  
ALTER TABLE [history].[setamper] SWITCH PARTITION 1 TO [staging].[setamper]   
WITH (WAIT_AT_LOW_PRIORITY (MAX_DURATION = 0 MINUTES, ABORT_AFTER_WAIT = NONE))  
  
/*(5) [Commented out] Optionally archive the data and drop staging table  
INSERT INTO [ArchiveDB].[dbo].[DepartmentHistory]   
SELECT * FROM [dbo].[staging_DepartmentHistory_September_2015];  
DROP TABLE [dbo].[staging_DepartmentHIstory_September_2015];  
*/  
  
/*(6) merge range to move lower boundary one month ahead*/  
ALTER PARTITION FUNCTION [fn_Partition_setamper_By_SysEndTime]() MERGE RANGE(N'2016-10-31T23:59:59.999')  
  
/*(7) Create new empty partition for "April and after" by creating new boundary point and specifying NEXT USED file group*/  
ALTER PARTITION SCHEME [sch_Partition_setamper_By_SysEndTime] NEXT USED [HIST]  
ALTER PARTITION FUNCTION [fn_Partition_setamper_By_SysEndTime]() SPLIT RANGE(N'2017-01-31T23:59:59.999')    
COMMIT TRANSACTION  

/* determine value in partition */
select $partition.fn_Partition_setamper_By_SysEndTime('2/2/2017')
/* the number of rows in each partition */
SELECT $PARTITION.fn_Partition_setamper_By_SysEndTime(SysEndTime) AS Partition,   
COUNT(*) AS [COUNT] FROM history.setamper   
GROUP BY $PARTITION.fn_Partition_setamper_By_SysEndTime(SysEndTime)  
ORDER BY Partition  
/* get all rows in partition */
SELECT * FROM history.setamper  
WHERE $PARTITION.fn_Partition_setamper_By_SysEndTime(SysEndTime) = 1

/* SQL to find hist table name, schema and end of period */
SELECT t2.name, s.name, c.name  
FROM sys.tables t1   
JOIN sys.tables t2 on t1.history_table_id = t2.object_id  
JOIN sys.schemas s on t2.schema_id = s.schema_id  
JOIN sys.periods p on p.object_id = t1.object_id  
JOIN sys.columns c on p.end_column_id = c.column_id and c.object_id = t1.object_id  
WHERE t1.name = 'AccountingBasis' and s.name = 'history'  

-- UPDATE dbo.setamper SET updated_by_id = convert(varchar(20), getdate(), 100)
