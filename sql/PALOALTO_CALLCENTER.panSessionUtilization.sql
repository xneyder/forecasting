delete from SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
where SMA_NAME='Security SMA' 
and REPORT_GROUP='PALOALTO'
and KPI_NAME='Session Table Utilization' 
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
with pm_data as
(
  select /*+ materialize */ DATETIME, IP_NE_NAME, 
  nvl(SESSION_UTILIZATION_MAX,0) KPI,
  ENTRIES
  from PALOALTO_IP.PAN_IPNE_SESSIONSTAT_MO@KNOX_IPHLXP
  where (IP_NE_NAME like '%-pcifw-%' or IP_NE_NAME like '%-pciccfw-%')
  and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
) 
select 
trunc(datetime,'MM') PERIOD_DATE,
'Security SMA' SMA_NAME,
'PALOALTO' REPORT_GROUP,
'PALOALTO_CALLCENTER' REGION_GROUP,
IP_NE_NAME LOCATION_GROUP,
'Session Table Utilization' KPI_NAME,
'panSessionUtilization' INDICATOR_,
'MM' TIME_AGG_TYPE,
'MAX' MATH_AGG_TYPE,
100 PERCENTILE_USED,
KPI KPI_VALUE,
'Counts' KPI_UNITS,
300 RAW_POLLING_DURATION,
ENTRIES PERIOD_COUNT,
1 AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data;
