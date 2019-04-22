delete from SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
where SMA_NAME='National Access Engineering SMA'
and KPI_NAME='LTE - Total eNodeB Connected'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME, VMME_NAME,
        SUM(nvl(S1_PEAKNBRENB,0)) KPI,
        count(*) ENTRIES
        from AFFIRMED_VMME.AFF_VMME_SRV_NODAL_S1_5M@KNOX_IPHLXP
        where DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME, VMME_NAME
)
select
trunc(datetime,'MM') PERIOD_DATE,
'National Access Engineering SMA' SMA_NAME,
'vEPC_LTE_MME_MCC' REPORT_GROUP,
'vMME' REGION_GROUP,
VMME_NAME LOCATION_GROUP,
'LTE - Total eNodeB Connected' KPI_NAME,
'S1.PeakNbrEnb' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
90 PERCENTILE_USED,
PERCENTILE_CONT(0.90) within group (order by KPI) KPI_VALUE,
'Max' KPI_UNITS,
900 RAW_POLLING_DURATION,
count(distinct DATETIME) PERIOD_COUNT,
avg(ENTRIES)/max(ENTRIES) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM'),VMME_NAME;

