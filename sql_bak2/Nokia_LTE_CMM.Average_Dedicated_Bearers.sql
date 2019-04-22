delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
where SMA_NAME='Nokia_LTE_CMM'
and KPI_NAME='Average Dedicated Bearers'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME, VCMM_NAME,
        SUM(NVL(VS_AVENUMOFDEDICATEDBEARERS,0)) KPI,
	count(distinct DATETIME) DATETIME_COUNT,
        count(distinct VCMM_NAME) NE_COUNT
        from NOKIA_VCMM.NOK_VCMM_EPS_CPPS_CON_15M
        where DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME, VCMM_NAME
)
select
trunc(datetime,'MM') PERIOD_DATE,
'Nokia_LTE_CMM' SMA_NAME,
'vCMM' REPORT_GROUP,
'Core' REGION_GROUP,
'VCMM_NAME' LOCATION_GROUP,
'Average Dedicated Bearers' KPI_NAME,
'VS.AveNumOfDedicatedBearers' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
99 PERCENTILE_USED,
PERCENTILE_CONT(0.99) within group (order by KPI) KPI_VALUE,
'#' KPI_UNITS,
900 RAW_POLLING_DURATION,
sum(DATETIME_COUNT) PERIOD_COUNT,
avg(NE_COUNT) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM');

