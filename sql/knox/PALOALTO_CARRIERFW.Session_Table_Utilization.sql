delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD 
where SMA_NAME='PALOALTO_CARRIERFW' 
and KPI_NAME='Session Table Utilization' 
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
with pm_data as
(
  select /*+ materialize */ trunc(trunc(sysdate,'MM')-1,'MM') DATETIME, IP_NE_NAME, 
  MAX(nvl(SESSION_UTILIZATION_MAX,0)) KPI,
  MAX(ENTRIES) ENTRIES
  from PALOALTO_IP.PAN_IPNE_SESSIONSTAT_MO
  where IP_NE_NAME like '%-dmzfw-%'
  and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
    group by IP_NE_NAME
) 
select 
trunc(datetime,'MM') PERIOD_DATE,
'PALOALTO_CARRIERFW' SMA_NAME,
'' REPORT_GROUP,
'Core' REGION_GROUP,
'Core' LOCATION_GROUP,
'Session Table Utilization' KPI_NAME,
'panSessionUtilization' INDICATOR_,
'MM' TIME_AGG_TYPE,
'MAX' MATH_AGG_TYPE,
null PERCENTILE_USED,
MAX(KPI),
'Counts' KPI_UNITS,
300 RAW_POLLING_DURATION,
max(ENTRIES) PERIOD_COUNT,
count(*) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM');
