delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
where SMA_NAME='BMC CMAS'
and KPI_NAME='Number of LTE MMEs'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME, CMAS_NAME,
        SUM(nvl(NUM_LTE_NE_MAX,0)) KPI,
        count(distinct DATETIME) DATETIME_COUNT,
        count(distinct CMAS_NAME) NE_COUNT
        from ALU_CMAS.BMC_CMAS_SMPROXY_5M@KNOX_IPHLXP
        where DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME, CMAS_NAME
)
select
trunc(datetime,'MM') PERIOD_DATE,
'BMC CMAS' SMA_NAME,
'' REPORT_GROUP,
'Core' REGION_GROUP,
'IP_NE_NAME' LOCATION_GROUP,
'Number of LTE MMEs' KPI_NAME,
'pxcSMProxyletprovNumLteNe' INDICATOR_,
'MM' TIME_AGG_TYPE,
'MAX' MATH_AGG_TYPE,
null PERCENTILE_USED,
MAX(KPI),
'#' KPI_UNITS,
300 RAW_POLLING_DURATION,
max(DATETIME_COUNT) PERIOD_COUNT,
avg(NE_COUNT) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM');

