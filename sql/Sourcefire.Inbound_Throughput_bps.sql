delete from SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
where SMA_NAME='Security SMA'
and KPI_NAME='Inbound Throughput (bps)'
and REPORT_GROUP='Sourcefire'
and REGION_GROUP='Core'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');

INSERT INTO SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
with pm_data as
(
  select /*+ materialize */ DATETIME, IP_NE_NAME,
  AVG(nvl(IF_IN_THROUGHPUT,0)) KPI,
  MAX(ENTRIES) ENTRIES_MAX,
  AVG(ENTRIES) ENTRIES_AVG
  from ALL_IP.STD_IPIF_MO@KNOX_IPHLXP
  where (IP_NE_NAME like '%-tdsips-%' or IP_NE_NAME like '%-virtualdc64-%')
  and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
    group by DATETIME,IP_NE_NAME
)
select
trunc(datetime,'MM') PERIOD_DATE,
'Security SMA' SMA_NAME,
'Sourcefire' REPORT_GROUP,
'Core' REGION_GROUP,
IP_NE_NAME LOCATION_GROUP,
'Inbound Throughput (bps)' KPI_NAME,
'IF_IN_THROUGHPUT' INDICATOR_,
'MM' TIME_AGG_TYPE,
'AVG' MATH_AGG_TYPE,
-1 PERCENTILE_USED,
KPI KPI_VALUE,
'bps' KPI_UNITS,
300 RAW_POLLING_DURATION,
ENTRIES_MAX PERIOD_COUNT,
ENTRIES_AVG/ENTRIES_MAX AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data;

