delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
where SMA_NAME='vEPC_LTE_MME_MCC'
and KPI_NAME='Max Number of TAI known to MME'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME, VMME_NAME,
        SUM(nvl(S1_PEAKNBRTAI,0)) KPI,
        count(*) INSTANCE_COUNT
        from AFFIRMED_VMME.AFF_VMME_SRV_NODAL_S1_15M
        where DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME, VMME_NAME
)
select
trunc(datetime,'MM') PERIOD_DATE,
'vEPC_LTE_MME_MCC' SMA_NAME,
'vMME' REPORT_GROUP,
'Core' REGION_GROUP,
'VMME_NAME' LOCATION_GROUP,
'Max Number of TAI known to MME' KPI_NAME,
'S1.PeakNbrTai' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
90 PERCENTILE_USED,
PERCENTILE_CONT(0.90) within group (order by KPI) KPI_VALUE,
'Max' KPI_UNITS,
900 RAW_POLLING_DURATION,
count(VMME_NAME) PERIOD_COUNT,
avg(INSTANCE_COUNT) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM');

