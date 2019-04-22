--DMZ_ENT DNS
delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
where SMA_NAME='Security SMA' 
and REPORT_GROUP='RCC_DNS'
and KPI_NAME='DNS Success - DMZ/ENT' 
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
with pm_data as
(
	select /*+ materialize */ DATETIME, 
	SUM(NVL(BCN_DNS_STAT_SRV_QRY_SUCCESS / (SYS_UP_TIME_D/100),0)) KPI,
	count(*) INSTANCE_COUNT,
	'DMZDNS' LOCATION_GROUP
	from BLUECAT_IPAM.BLU_IP_STATSERV_5M@KNOX_IPHLXP 
	where IP_NE_NAME like '%-dmzdns-%'
	and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
  	group by DATETIME
  	UNION 
  	select /*+ materialize */ DATETIME, 
	SUM(NVL(BCN_DNS_STAT_SRV_QRY_SUCCESS / (SYS_UP_TIME_D/100),0)) KPI,
	count(*) INSTANCE_COUNT,
	'ENTDNS' LOCATION_GROUP
	from BLUECAT_IPAM.BLU_IP_STATSERV_5M@KNOX_IPHLXP 
	where IP_NE_NAME like '%-entdns-%'
	and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
  	group by DATETIME
) 
select 
trunc(datetime,'MM') PERIOD_DATE,
'Security SMA' SMA_NAME,
'RCC_DNS' REPORT_GROUP,
'DMZ_ENT DNS' REGION_GROUP,
LOCATION_GROUP,
'DNS Success - DMZ/ENT' KPI_NAME,
'bcnDnsStatSrvQrySuccess' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
95 PERCENTILE_USED,
PERCENTILE_CONT(0.95) within group (order by KPI) KPI_VALUE,
'Counts' KPI_UNITS,
300 RAW_POLLING_DURATION,
count(distinct DATETIME) PERIOD_COUNT,
avg(INSTANCE_COUNT) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM'), LOCATION_GROUP;
