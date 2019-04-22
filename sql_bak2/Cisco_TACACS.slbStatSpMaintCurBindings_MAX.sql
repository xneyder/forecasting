delete from SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
where SMA_NAME='Security SMA'
and KPI_NAME='Maximum slbStat Sp Maint Current Bindings'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
with pm_data as
(
  select /*+ materialize */ trunc(trunc(sysdate,'MM')-1,'MM') DATETIME, IP_NE_NAME,
  MAX(nvl(SLB_STAT_SP_MAINT_CUR_BINDINGS,0)) KPI,
  MAX(ENTRIES) ENTRIES_MAX,
  AVG(ENTRIES) ENTRIES_AVG
  from RADWARE_IP.RAD_IPNE_SLBSTAT_MO@KNOX_IPHLXP
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
'Maximum slbStat Sp Maint Current Bindings' KPI_NAME,
'slbStatSpMaintCurBindings' INDICATOR_,
'MM' TIME_AGG_TYPE,
'MAX' MATH_AGG_TYPE,
100 PERCENTILE_USED,
MAX(KPI),
'Gauge' KPI_UNITS,
300 RAW_POLLING_DURATION,
max(ENTRIES_MAX) PERIOD_COUNT,
avg(ENTRIES_AVG)/max(ENTRIES_MAX) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM');

