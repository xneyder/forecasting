delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
where SMA_NAME='100G LTE FW'
and KPI_NAME='Total Throughput IN'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
--CREATE TABLE
CREATE table AUDIT_DB.GLTEFW_1(
DATETIME timestamp,
KPI number(23,6),
DATETIME_COUNT number(13),
NE_COUNT number(13),
LOCATION_GROUP varchar2(55)
);
INSERT INTO AUDIT_DB.GLTEFW_1
select /*+ materialize */ DATETIME,
SUM(nvl(IF_IN_THROUGHPUT,0)) KPI,
count(distinct DATETIME) DATETIME_COUNT,
count(distinct IP_NE_NAME) NE_COUNT,
'Sch' LOCATION_GROUP
from ALL_IP.STD_IPIF_5M
where IP_NE_NAME like '%-ltefw-%'
and (IP_NE_NAME like 'ilscha%')
and DATETIME >= '<start_date>' and DATETIME <= '<end_date>'
group by DATETIME
UNION
select /*+ materialize */ DATETIME,
SUM(nvl(IF_IN_THROUGHPUT,0)) KPI,
count(distinct DATETIME) DATETIME_COUNT,
count(distinct IP_NE_NAME) NE_COUNT,
'Atl' LOCATION_GROUP
from ALL_IP.STD_IPIF_5M
where IP_NE_NAME like '%-ltefw-%'
and (IP_NE_NAME like 'gaatla%')
and DATETIME >= '<start_date>' and DATETIME <= '<end_date>'
group by DATETIME
UNION
select /*+ materialize */ DATETIME,
SUM(nvl(IF_IN_THROUGHPUT,0)) KPI,
count(distinct DATETIME) DATETIME_COUNT,
count(distinct IP_NE_NAME) NE_COUNT,
'Sch+Atl' LOCATION_GROUP
from ALL_IP.STD_IPIF_5M
where IP_NE_NAME like '%-ltefw-%'
and (IP_NE_NAME like 'ilscha%' or IP_NE_NAME like 'gaatla%')
and DATETIME >= '<start_date>' and DATETIME <= '<end_date>'
group by DATETIME;
INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
select
trunc(datetime,'MM') PERIOD_DATE,
'100G LTE FW' SMA_NAME,
'' REPORT_GROUP,
'Core' REGION_GROUP,
LOCATION_GROUP,
'Total Throughput IN' KPI_NAME,
'' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
95 PERCENTILE_USED,
PERCENTILE_CONT(0.95) within group (order by KPI) KPI_VALUE,
'N/A - Derived' KPI_UNITS,
300 RAW_POLLING_DURATION,
SUM(DATETIME_COUNT) PERIOD_COUNT,
avg(NE_COUNT) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from AUDIT_DB.GLTEFW_1
group by trunc(datetime,'MM'), LOCATION_GROUP;
drop table AUDIT_DB.GLTEFW_1;
