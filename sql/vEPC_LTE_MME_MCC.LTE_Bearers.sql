delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
where SMA_NAME='vEPC_LTE_MME_MCC'
and KPI_NAME='LTE Bearers'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME, VMME_NAME,
        SUM(nvl(SM_MAXNBRACTDEDICATEDBEARER,0)) KPI,
        count(distinct DATETIME) DATETIME_COUNT,
        count(distinct VMME_NAME) NE_COUNT
        from AFFIRMED_VMME.AFF_VMME_SRV_LTESMGEN_5M@KNOX_IPHLXP
        where DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME, VMME_NAME
)
select
trunc(datetime,'MM') PERIOD_DATE,
'vEPC_LTE_MME_MCC' SMA_NAME,
'vMME' REPORT_GROUP,
'Core' REGION_GROUP,
'VMME_NAME' LOCATION_GROUP,
'LTE Bearers' KPI_NAME,
'LTESM_GENERAL.SM.MaxNbrActDedicatedBearer' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
90 PERCENTILE_USED,
PERCENTILE_CONT(0.90) within group (order by KPI) KPI_VALUE,
'Max' KPI_UNITS,
900 RAW_POLLING_DURATION,
sum(DATETIME_COUNT) PERIOD_COUNT,
avg(NE_COUNT) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM');

