delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
where SMA_NAME='Cisco TACACS'
and KPI_NAME='slbStatEnhGroupCurrSessions - MAX'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
with pm_data as
(
  select /*+ materialize */ trunc(trunc(sysdate,'MM')-1,'MM') DATETIME, IP_NE_NAME,
  MAX(nvl(GROUP_CURR_SERSSIONS_MAX,0)) KPI,
  MAX(ENTRIES) ENTRIES
  from RADWARE_IP.RAD_IPNE_RSERVGRPSES_MO@KNOX_IPHLXP
  where (IP_NE_NAME like '%-tacacslb-%')
  and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
    group by IP_NE_NAME
)
select
trunc(datetime,'MM') PERIOD_DATE,
'Cisco TACACS' SMA_NAME,
'' REPORT_GROUP,
'Core' REGION_GROUP,
'IP_NE_NAME' LOCATION_GROUP,
'slbStatEnhGroupCurrSessions - MAX' KPI_NAME,
'' INDICATOR_,
'MM' TIME_AGG_TYPE,
'MAX' MATH_AGG_TYPE,
null PERCENTILE_USED,
MAX(KPI),
'Gauge' KPI_UNITS,
300 RAW_POLLING_DURATION,
max(ENTRIES) PERIOD_COUNT,
count(*) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM');

