--DMZ_ENT DNS
delete from SMA_HLX.SMA_SUMMARY@SCHAHLXPRD 
where SMA_NAME='DMZ_ENT DNS' 
and KPI_NAME='DNS Success - DMZ/ENT' 
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@SCHAHLXPRD
with pm_data as
(
	select /*+ materialize */ DATETIME, 
	SUM(NVL(BCN_DNS_STAT_SRV_QRY_SUCCESS / (SYS_UP_TIME_D/100),0)) KPI,
	count(*) INSTANCE_COUNT,
	'DMZDNS' LOCATION_GROUP
	from BLUECAT_IPAM.BLU_IP_STATSERV_5M 
	where IP_NE_NAME like '%-dmzdns-%'
	and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
  	group by DATETIME
  	UNION 
  	select /*+ materialize */ DATETIME, 
	SUM(NVL(BCN_DNS_STAT_SRV_QRY_SUCCESS / (SYS_UP_TIME_D/100),0)) KPI,
	count(*) INSTANCE_COUNT,
	'ENTDNS' LOCATION_GROUP
	from BLUECAT_IPAM.BLU_IP_STATSERV_5M 
	where IP_NE_NAME like '%-entdns-%'
	and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
  	group by DATETIME
) 
select 
trunc(datetime,'MM') PERIOD_DATE,
'DMZ_ENT DNS' SMA_NAME,
'RCC_DNS' REPORT_GROUP,
'Core' REGION_GROUP,
LOCATION_GROUP,
'DNS Success - DMZ/ENT' KPI_NAME,
'bcnDnsStatSrvQrySuccess' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
95 PERCENTILE_USED,
PERCENTILE_CONT(0.95) within group (order by KPI) KPI_VALUE,
'Counts' KPI_UNITS,
300 RAW_POLLING_DURATION,
count(DATETIME) PERIOD_COUNT,
avg(INSTANCE_COUNT) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM'), LOCATION_GROUP;
