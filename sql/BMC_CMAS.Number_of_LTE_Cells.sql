delete from SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
where SMA_NAME='National Access Engineering SMA'
and KPI_NAME='Number of LTE Cells'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME, CMAS_NAME,
        SUM(nvl(NUM_LTE_CELLS_MAX,0)) KPI,
        count(*) ENTRIES
        from ALU_CMAS.BMC_CMAS_SMPROXY_5M@KNOX_IPHLXP
        where DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME, CMAS_NAME
)
select
trunc(datetime,'MM') PERIOD_DATE,
'National Access Engineering SMA' SMA_NAME,
'BMC CMAS' REPORT_GROUP,
'Core' REGION_GROUP,
CMAS_NAME LOCATION_GROUP,
'Number of LTE Cells' KPI_NAME,
'pxcSMProxyletprovNumLteCells' INDICATOR_,
'MM' TIME_AGG_TYPE,
'MAX' MATH_AGG_TYPE,
null PERCENTILE_USED,
MAX(KPI) KPI_VALUE,
'#' KPI_UNITS,
300 RAW_POLLING_DURATION,
count(distinct DATETIME) PERIOD_COUNT,
avg(ENTRIES)/max(ENTRIES) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM'),CMAS_NAME;

