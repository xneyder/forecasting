delete from SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
where SMA_NAME='National Access Engineering SMA'
and KPI_NAME='% CPU Utilization'
and REPORT_GROUP='Border_Routers P_Routers'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME, IP_NE_NAME,
        SUM(nvl(SGI_CPU_USAGE,0)) KPI,
	count(*) ENTRIES
        from ALU_IP.ALU_IPNE_SYSTEM_STAT_5M@KNOX_IPHLXP
        where DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        and (IP_NE_NAME like '%-border-%' or IP_NE_NAME like '%-p-%')
        group by DATETIME, IP_NE_NAME
)
select
trunc(datetime,'MM') PERIOD_DATE,
'National Access Engineering SMA' SMA_NAME,
'Border_Routers P_Routers' REPORT_GROUP,
'Core' REGION_GROUP,
IP_NE_NAME LOCATION_GROUP,
'% CPU Utilization' KPI_NAME,
'sgiCpuUsage' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
97 PERCENTILE_USED,
PERCENTILE_CONT(0.97) within group (order by KPI) KPI_VALUE,
'%' KPI_UNITS,
300 RAW_POLLING_DURATION,
count(distinct DATETIME) PERIOD_COUNT,
avg(ENTRIES)/max(ENTRIES) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM'),IP_NE_NAME;

