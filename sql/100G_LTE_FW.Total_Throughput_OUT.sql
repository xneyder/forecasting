delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
where SMA_NAME='100G LTE FW'
and KPI_NAME='Total Throughput OUT'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME,
        SUM(nvl(IF_OUT_THROUGHPUT,0)) KPI,
        count(*) INSTANCE_COUNT,
        'Sch' LOCATION_GROUP
        from ALL_IP.STD_IPIF_5M
        where IP_NE_NAME like '%-ltefw-%'
        and (IP_NE_NAME like 'ilscha%')
        and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME
        UNION
        select /*+ materialize */ DATETIME,
        SUM(nvl(IF_OUT_THROUGHPUT,0)) KPI,
        count(*) INSTANCE_COUNT,
        'Atl' LOCATION_GROUP
        from ALL_IP.STD_IPIF_5M
        where IP_NE_NAME like '%-ltefw-%'
        and (IP_NE_NAME like 'gaatla%')
        and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME
        UNION
        select /*+ materialize */ DATETIME,
        SUM(nvl(IF_OUT_THROUGHPUT,0)) KPI,
        count(*) INSTANCE_COUNT,
        'Sch+Atl' LOCATION_GROUP
        from ALL_IP.STD_IPIF_5M
        where IP_NE_NAME like '%-ltefw-%'
        and (IP_NE_NAME like 'ilscha%' or IP_NE_NAME like 'gaatla%')
        and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME
)
select
trunc(datetime,'MM') PERIOD_DATE,
'100G LTE FW' SMA_NAME,
'' REPORT_GROUP,
'Core' REGION_GROUP,
LOCATION_GROUP,
'Total Throughput OUT' KPI_NAME,
'' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
95 PERCENTILE_USED,
PERCENTILE_CONT(0.95) within group (order by KPI) KPI_VALUE,
'N/A – Derived' KPI_UNITS,
300 RAW_POLLING_DURATION,
count(DATETIME) PERIOD_COUNT,
avg(INSTANCE_COUNT) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM'), LOCATION_GROUP;

