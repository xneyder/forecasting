delete from SMA_HLX.SMA_SUMMARY@SCHAHLXPRD
where SMA_NAME='Walled Garden'
and KPI_NAME='SYSTEM SESSION COUNT'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@SCHAHLXPRD
with pm_data as
(
  select /*+ materialize */ trunc(trunc(sysdate,'MM')-1,'MM') DATETIME, IP_NE_NAME,
  MAX(nvl(FG_SYS_SES_COUNT,0)) KPI,
  count(*) ENTRIES
  from FORTINET_IP.FOR_FW_SYSINFO_5M
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
'SYSTEM SESSION COUNT' KPI_NAME,
'fgSysSesCount' INDICATOR_,
'MM' TIME_AGG_TYPE,
'MAX' MATH_AGG_TYPE,
null PERCENTILE_USED,
MAX(KPI),
'GAUGE' KPI_UNITS,
300 RAW_POLLING_DURATION,
count(ENTRIES) PERIOD_COUNT,
count(ENTRIES) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM');

