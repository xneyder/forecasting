delete from SMA_HLX.SMA_SUMMARY@SCHAHLXPRD
where SMA_NAME='RCC DNS E-E'
and KPI_NAME='Session Table Utilization'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@SCHAHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME,
        SUM(nvl(SLB_SESS_CURR,0)) KPI,
        count(*) INSTANCE_COUNT,
        'Sch+Atl' LOCATION_GROUP
        from RADWARE_IP.RAD_IPNE_CURBIND_5M
        where IP_NE_NAME like '%-rccdnslb-%'
        and (IP_NE_NAME like 'ilscha%' or IP_NE_NAME like 'gaatla%')
        and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME        
)
select
trunc(datetime,'MM') PERIOD_DATE,
'RCC DNS E-E' SMA_NAME,
'RCC_DNS' REPORT_GROUP,
'Core' REGION_GROUP,
LOCATION_GROUP,
'Session Table Utilization' KPI_NAME,
'bcnDnsStatSrvQrySuccess' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
95 PERCENTILE_USED,
PERCENTILE_CONT(0.95) within group (order by KPI) KPI_VALUE,
'Counts' KPI_UNITS,
300 RAW_POLLING_DURATION,
count(DATETIME) PERIOD_COUNT,
avg(INSTANCE_COUNT) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM'), LOCATION_GROUP;

