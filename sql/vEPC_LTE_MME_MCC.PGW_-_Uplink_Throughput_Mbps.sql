delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
where SMA_NAME='vEPC_LTE_MME_MCC'
and KPI_NAME='PGW - Uplink Throughput(Mbps)'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME, MCC_NAME,
        SUM(nvl(PGW_UPLINK_THROUGHPUT,0)) KPI,
        count(*) INSTANCE_COUNT
        from AFFIRMED_VMCC.AFF_MCC_PGW_CLPERFGRID_15M
        where DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME, MCC_NAME
)
select
trunc(datetime,'MM') PERIOD_DATE,
'vEPC_LTE_MME_MCC' SMA_NAME,
'vMCC' REPORT_GROUP,
'Core' REGION_GROUP,
'MCC_NAME' LOCATION_GROUP,
'PGW - Uplink Throughput(Mbps)' KPI_NAME,
'PGWCALLPERFSTATSGRID.NumUplinkBytes * 8 / 1000000 / Interval' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
90 PERCENTILE_USED,
PERCENTILE_CONT(0.90) within group (order by KPI) KPI_VALUE,
'Mbps' KPI_UNITS,
900 RAW_POLLING_DURATION,
count(MCC_NAME) PERIOD_COUNT,
avg(INSTANCE_COUNT) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM');

