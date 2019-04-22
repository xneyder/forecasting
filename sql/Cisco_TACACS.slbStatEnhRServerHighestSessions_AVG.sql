delete from SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
where SMA_NAME='Security SMA'
and KPI_NAME='Average slbStat Enh Rserver Highest Sessions'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
with pm_data as
(
  select /*+ materialize */ trunc(trunc(sysdate,'MM')-1,'MM') DATETIME, IP_NE_NAME,
  AVG(nvl(HIGHEST_SESSIONS_AVG,0)) KPI,
  MAX(ENTRIES) ENTRIES_MAX,
  AVG(ENTRIES) ENTRIES_AVG
  from RADWARE_IP.RAD_IPNE_REALSERVSES_MO@KNOX_IPHLXP
  where (IP_NE_NAME like '%-tacacslb-%')
  and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
    group by IP_NE_NAME
)
select
trunc(datetime,'MM') PERIOD_DATE,
'Security SMA' SMA_NAME,
'Cisco TACACS' REPORT_GROUP,
'Core' REGION_GROUP,
IP_NE_NAME LOCATION_GROUP,
'Average slbStat Enh Rserver Highest Sessions' KPI_NAME,
'slbStatEnhRServerHighestSessions' INDICATOR_,
'MM' TIME_AGG_TYPE,
'AVG' MATH_AGG_TYPE,
-1 PERCENTILE_USED,
AVG(KPI),
'Counter' KPI_UNITS,
300 RAW_POLLING_DURATION,
max(ENTRIES_MAX) PERIOD_COUNT,
avg(ENTRIES_AVG)/max(ENTRIES_MAX) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM');
