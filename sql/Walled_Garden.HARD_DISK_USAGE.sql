delete from SMA_HLX.SMA_SUMMARY@SCHAHLXPRD
where SMA_NAME='Walled Garden'
and KPI_NAME='HARD DISK USAGE'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@SCHAHLXPRD
with pm_data as
(
  select /*+ materialize */ trunc(trunc(sysdate,'MM')-1,'MM') DATETIME, IP_NE_NAME,
  MAX(nvl(DISK_USAGE_MAX,0)) KPI,
  MAX(ENTRIES) ENTRIES_MAX,
  AVG(ENTRIES) ENTRIES_AVG
  from FORTINET_IP.FOR_FW_SYSINFO_MO
  where (IP_NE_NAME like '%-wgfw-%')
  and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
  group by IP_NE_NAME
)
select
trunc(datetime,'MM') PERIOD_DATE,
'Walled Garden' SMA_NAME,
'' REPORT_GROUP,
'Core' REGION_GROUP,
'IP_NE_NAME' LOCATION_GROUP,
'HARD DISK USAGE' KPI_NAME,
'fgSysDiskUsage' INDICATOR_,
'MM' TIME_AGG_TYPE,
'MAX' MATH_AGG_TYPE,
null PERCENTILE_USED,
MAX(KPI),
'GAUGE' KPI_UNITS,
300 RAW_POLLING_DURATION,
max(ENTRIES_MAX) PERIOD_COUNT,
avg(ENTRIES_AVG) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM');

