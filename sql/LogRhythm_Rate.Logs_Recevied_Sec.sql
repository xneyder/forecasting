delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
where SMA_NAME='LogRhythm'
and KPI_NAME='Rate Logs Recevied/Sec'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
with pm_data as
(
  select /*+ materialize */ trunc(trunc(sysdate,'MM')-1,'MM') DATETIME, IP_NE_NAME,
  PERCENTILE_CONT(0.95) within group (order by nvl(LOG_MESSAGES_RECEIVED_PER_SEC,0)) KPI,
  SUM(ENTRIES) ENTRIES_MAX,
  AVG(ENTRIES) ENTRIES_AVG
  from LOGRHYTHM_IP.LOGR_IPNE_ENSRV_HR@KNOX_IPHLXP
  where DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
  group by IP_NE_NAME
)
select
trunc(datetime,'MM') PERIOD_DATE,
'LogRhythm' SMA_NAME,
'RCC_DNS' REPORT_GROUP,
'Core' REGION_GROUP,
'IP_NE_NAME' LOCATION_GROUP,
'Rate Logs Recevied/Sec' KPI_NAME,
'LogMessagesReceivedPerSec' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
95 PERCENTILE_USED,
KPI,
'Integer' KPI_UNITS,
300 RAW_POLLING_DURATION,
sum(ENTRIES_MAX) PERIOD_COUNT,
avg(ENTRIES_AVG) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM');

