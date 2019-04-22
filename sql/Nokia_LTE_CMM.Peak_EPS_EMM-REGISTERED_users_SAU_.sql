delete from SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
where SMA_NAME='National Access Engineering SMA'
and KPI_NAME='Peak EPS EMM-REGISTERED users (SAU)'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME, VCMM_NAME,
        SUM(NVL(VS_MAXNBROFREGISTEREDUE,0)) KPI,
        count(*) ENTRIES
        from NOKIA_VCMM.NOK_VCMM_EPS_CPPS_CON_15M@KNOX_IPHLXP
        where DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME, VCMM_NAME
)
select
trunc(datetime,'MM') PERIOD_DATE,
'National Access Engineering SMA' SMA_NAME,
'Nokia_LTE_CMM' REPORT_GROUP,
'vCMM' REGION_GROUP,
VCMM_NAME LOCATION_GROUP,
'Peak EPS EMM-REGISTERED users (SAU)' KPI_NAME,
'VS.MaxNbrOfRegisteredUE' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
99 PERCENTILE_USED,
PERCENTILE_CONT(0.99) within group (order by KPI) KPI_VALUE,
'#' KPI_UNITS,
900 RAW_POLLING_DURATION,
count(distinct DATETIME) PERIOD_COUNT,
avg(ENTRIES)/max(ENTRIES) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM'),VCMM_NAME;

