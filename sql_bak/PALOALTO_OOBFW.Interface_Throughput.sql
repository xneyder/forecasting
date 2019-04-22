delete from SMA_HLX.SMA_SUMMARY@SCHAHLXPRD
where SMA_NAME='PALOALTO_OOBFW' 
and KPI_NAME='Interface Throughput' 
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
--CREATE TABLE
CREATE table AUDIT_DB.PALOALTO_OOBFW (
DATETIME timestamp,
IP_NE_NAME varchar2(55),
KPI number(13,3),
INSTANCE_COUNT number(13)
);
INSERT INTO AUDIT_DB.PALOALTO_OOBFW
select DATETIME, 
IP_NE_NAME, 
SUM(nvl(IF_THROUGHPUT,0)) KPI,
count(*) INSTANCE_COUNT
from ALL_IP.STD_IPIF_5M 
where IP_NE_NAME like '%-oobfw-%'
and DATETIME >= '<start_date>' and DATETIME <= '<end_date>'
group by DATETIME, IP_NE_NAME;
INSERT INTO SMA_HLX.SMA_SUMMARY@SCHAHLXPRD
select 
trunc(datetime,'MM') PERIOD_DATE,
'PALOALTO_OOBFW' SMA_NAME,
' ' REPORT_GROUP,
'Core' REGION_GROUP,
'IP_NE_NAME' LOCATION_GROUP,
'Interface Throughput' KPI_NAME,
'IF_THROUGHPUT' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
95 PERCENTILE_USED,
PERCENTILE_CONT(0.95) within group (order by KPI) KPI_VALUE,
'Counts' KPI_UNITS,
300 RAW_POLLING_DURATION,
count(IP_NE_NAME) PERIOD_COUNT,
avg(INSTANCE_COUNT) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from AUDIT_DB.PALOALTO_OOBFW
group by trunc(datetime,'MM');
drop table AUDIT_DB.PALOALTO_OOBFW;
