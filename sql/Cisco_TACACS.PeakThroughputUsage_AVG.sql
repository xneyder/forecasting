delete from SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
where SMA_NAME='Security SMA'
and KPI_NAME='Average Peak Throughput Usage'
and REPORT_GROUP='Cisco TACACS'
and REGION_GROUP='Core'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');

INSERT INTO SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
with pm_data as
(
  select /*+ materialize */ DATETIME, IP_NE_NAME,
  nvl(PEAK_THR_USAGE_AVG,0) KPI,
  ENTRIES
  from RADWARE_IP.RAD_IPNE_CAPUSAGE_MO@KNOX_IPHLXP
  where (IP_NE_NAME like '%-tacacslb-%')
  and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
)
select
DATETIME PERIOD_DATE,
'Security SMA' SMA_NAME,
'Cisco TACACS' REPORT_GROUP,
'Core' REGION_GROUP,
IP_NE_NAME LOCATION_GROUP,
'Average Peak Throughput Usage' KPI_NAME,
'PeakThroughputUsage' INDICATOR_,
'MM' TIME_AGG_TYPE,
'AVG' MATH_AGG_TYPE,
-1 PERCENTILE_USED,
KPI KPI_VALUE,
'Counter' KPI_UNITS,
300 RAW_POLLING_DURATION,
ENTRIES PERIOD_COUNT,
1 AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data;

