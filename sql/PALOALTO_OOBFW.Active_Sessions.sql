--PALOALTO_OOBFW - Active Sessions
delete from SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
where SMA_NAME='Security SMA' 
and KPI_NAME='Active Sessions' 
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
with pm_data as
(
	select /*+ materialize */ DATETIME, IP_NE_NAME, 
	SUM(nvl(PAN_SESSION_ACTIVE,0)) KPI,
	count(*) ENTRIES
	from PALOALTO_IP.PAN_IPNE_SESSIONSTAT_5M@KNOX_IPHLXP 
	where IP_NE_NAME like '%-oobfw-%'
	and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
  	group by DATETIME, IP_NE_NAME
) 
select 
trunc(datetime,'MM') PERIOD_DATE,
'Security SMA' SMA_NAME,
'PALOALTO' REPORT_GROUP,
'PALOALTO_OOBFW' REGION_GROUP,
IP_NE_NAME LOCATION_GROUP,
'Active Sessions' KPI_NAME,
'panSessionActive' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
95 PERCENTILE_USED,
PERCENTILE_CONT(0.95) within group (order by KPI) KPI_VALUE,
'Counts' KPI_UNITS,
300 RAW_POLLING_DURATION,
count(distinct DATETIME) PERIOD_COUNT,
avg(ENTRIES)/max(ENTRIES) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM'),IP_NE_NAME;
