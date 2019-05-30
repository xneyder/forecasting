delete from SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
where SMA_NAME='Security SMA'
and KPI_NAME='Rate Logs Processed/Sec'
and REPORT_GROUP='LogRhythm'
and REGION_GROUP='Core'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');

INSERT INTO SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
with pm_data as
(
  select /*+ materialize */ trunc(trunc(sysdate,'MM')-1,'MM') DATETIME, IP_NE_NAME,
  PERCENTILE_CONT(0.95) within group (order by nvl(LOG_MESSAGES_PROCESSED_PER_SEC,0)) KPI,
  SUM(ENTRIES) ENTRIES_SUM,
  MAX(ENTRIES) ENTRIES_MAX,
  AVG(ENTRIES) ENTRIES_AVG
  from LOGRHYTHM_IP.LOGR_IPNE_ENSRV_HR@KNOX_IPHLXP
  where DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
  group by trunc(DATETIME,'MM'),IP_NE_NAME
)
select
trunc(datetime,'MM') PERIOD_DATE,
'Security SMA' SMA_NAME,
'LogRhythm' REPORT_GROUP,
'Core' REGION_GROUP,
IP_NE_NAME LOCATION_GROUP,
'Rate Logs Processed/Sec' KPI_NAME,
'LogMessagesProcessedPerSec' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
95 PERCENTILE_USED,
KPI KPI_VALUE,
'Integer' KPI_UNITS,
300 RAW_POLLING_DURATION,
ENTRIES_SUM PERIOD_COUNT,
ENTRIES_AVG/ENTRIES_MAX AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data;

