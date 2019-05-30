delete from SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
where SMA_NAME='Security SMA'
and KPI_NAME='System Memory Usage'
and REPORT_GROUP='Walled Garden'
and REGION_GROUP='Core'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');

INSERT INTO SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
with pm_data as
(
  select /*+ materialize */ DATETIME, IP_NE_NAME,
  nvl(MEM_USAGE_MAX,0) KPI,
  ENTRIES
  from FORTINET_IP.FOR_FW_SYSINFO_MO@IPHLXP
  where (IP_NE_NAME like '%-wgfw-%')
  and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
)
select
DATETIME PERIOD_DATE,
'Security SMA' SMA_NAME,
'Walled Garden' REPORT_GROUP,
'Core' REGION_GROUP,
IP_NE_NAME LOCATION_GROUP,
'System Memory Usage' KPI_NAME,
'fgSysMemUsage' INDICATOR_,
'MM' TIME_AGG_TYPE,
'MAX' MATH_AGG_TYPE,
100 PERCENTILE_USED,
KPI KPI_VALUE,
'GAUGE' KPI_UNITS,
300 RAW_POLLING_DURATION,
ENTRIES PERIOD_COUNT,
1 AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data;

