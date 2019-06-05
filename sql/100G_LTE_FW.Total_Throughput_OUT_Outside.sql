delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
 where SMA_NAME='Security SMA'
   and REPORT_GROUP='100G LTE FW'
   and KPI_NAME='Total Throughput OUT - Outside'
   AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');

--CREATE TABLE in Porduction
CREATE table AUDIT_DB.GLTEFW_4(
	DATETIME timestamp,
	KPI number(23,6),
	DATETIME_COUNT number(13),
	NE_COUNT number(13),
	LOCATION_GROUP varchar2(55)
	);

INSERT INTO AUDIT_DB.GLTEFW_2
 select /*+ materialize */ DATETIME,
	SUM(nvl(IF_OUT_THROUGHPUT,0)) KPI,
	count(distinct DATETIME) DATETIME_COUNT,
	count(distinct IP_NE_NAME) NE_COUNT,
	'Sch' LOCATION_GROUP
   from ALL_IP.STD_IPIF_5M@KNOX_IPHLXP
  where IP_NE_NAME like '%-ltefw-%'
    and (IP_NE_NAME like 'ilscha%')
    and INTERFACE_NAME='Outside'
    and DATETIME >= '<start_date>' and DATETIME <= '<end_date>'
  group by DATETIME
 UNION
 select /*+ materialize */ DATETIME,
	SUM(nvl(IF_OUT_THROUGHPUT,0)) KPI,
	count(distinct DATETIME) DATETIME_COUNT,
	count(distinct IP_NE_NAME) NE_COUNT,
	'Atl' LOCATION_GROUP
   from ALL_IP.STD_IPIF_5M@KNOX_IPHLXP
  where IP_NE_NAME like '%-ltefw-%'
    and (IP_NE_NAME like 'gaatla%')
    and INTERFACE_NAME='Outside'
    and DATETIME >= '<start_date>' and DATETIME <= '<end_date>'
  group by DATETIME
 UNION
 select /*+ materialize */ DATETIME,
	SUM(nvl(IF_OUT_THROUGHPUT,0)) KPI,
	count(distinct DATETIME) DATETIME_COUNT,
	count(distinct IP_NE_NAME) NE_COUNT,
	'Sch+Atl' LOCATION_GROUP
   from ALL_IP.STD_IPIF_5M@KNOX_IPHLXP
  where IP_NE_NAME like '%-ltefw-%'
    and (IP_NE_NAME like 'ilscha%' or IP_NE_NAME like 'gaatla%')
    and INTERFACE_NAME='Outside'
    and DATETIME >= '<start_date>' and DATETIME <= '<end_date>'
  group by DATETIME
 UNION
 select /*+ materialize */ DATETIME,
	SUM(nvl(IF_OUT_THROUGHPUT,0)) KPI,
	count(distinct DATETIME) DATETIME_COUNT,
	count(distinct IP_NE_NAME) NE_COUNT,
	'Sch+Sanj' LOCATION_GROUP
	from ALL_IP.STD_IPIF_5M@KNOX_IPHLXP
  where IP_NE_NAME like '%-ltefw-%'
    and (IP_NE_NAME like 'ilscha%' or IP_NE_NAME like 'casanj%')
    and INTERFACE_NAME='Outside'
    and DATETIME >= '<start_date>' and DATETIME <= '<end_date>'
  group by DATETIME
 UNION
 select /*+ materialize */ DATETIME,
	SUM(nvl(IF_OUT_THROUGHPUT,0)) KPI,
	count(distinct DATETIME) DATETIME_COUNT,
	count(distinct IP_NE_NAME) NE_COUNT,
	'Atl+Ash' LOCATION_GROUP
   from ALL_IP.STD_IPIF_5M@KNOX_IPHLXP
  where IP_NE_NAME like '%-ltefw-%'
    and (IP_NE_NAME like 'gaatla%' or IP_NE_NAME like 'vaashb%')
    and INTERFACE_NAME='Outside'
    and DATETIME >= '<start_date>' and DATETIME <= '<end_date>'
  group by DATETIME
 UNION
 select /*+ materialize */ DATETIME,
	SUM(nvl(IF_OUT_THROUGHPUT,0)) KPI,
	count(distinct DATETIME) DATETIME_COUNT,
	count(distinct IP_NE_NAME) NE_COUNT,
	'Sanj' LOCATION_GROUP
   from ALL_IP.STD_IPIF_5M@KNOX_IPHLXP
  where IP_NE_NAME like '%-ltefw-%'
    and (IP_NE_NAME like 'casanj%')
    and INTERFACE_NAME='Outside'
    and DATETIME >= '<start_date>' and DATETIME <= '<end_date>'
  group by DATETIME
 UNION
 select /*+ materialize */ DATETIME,
	SUM(nvl(IF_OUT_THROUGHPUT,0)) KPI,
	count(distinct DATETIME) DATETIME_COUNT,
	count(distinct IP_NE_NAME) NE_COUNT,
	'Ash' LOCATION_GROUP
   from ALL_IP.STD_IPIF_5M@KNOX_IPHLXP
  where IP_NE_NAME like '%-ltefw-%'
    and (IP_NE_NAME like 'vaashb%')
    and INTERFACE_NAME='Outside'
    and DATETIME >= '<start_date>' and DATETIME <= '<end_date>'
  group by DATETIME;

INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
 select
	trunc(datetime,'MM') PERIOD_DATE,
	'Security SMA' SMA_NAME,
	'100G LTE FW' REPORT_GROUP,
	'Core' REGION_GROUP,
	LOCATION_GROUP,
	'Total Throughput OUT - Outside' KPI_NAME,
	'IF_OUT_THROUGHPUT' INDICATOR_,
	'MM' TIME_AGG_TYPE,
	'PERC' MATH_AGG_TYPE,
	95 PERCENTILE_USED,
	PERCENTILE_CONT(0.95) within group (order by KPI) KPI_VALUE,
	'bps' KPI_UNITS,
	300 RAW_POLLING_DURATION,
	count(distinct DATETIME) PERIOD_COUNT,
	avg(NE_COUNT) AVG_INSTANCE_COUNT,
	sysdate REC_CREATE_DATE,
	sysdate LAST_UPDATE_DATE
   from AUDIT_DB.GLTEFW_2
  group by trunc(datetime,'MM'), LOCATION_GROUP;

drop table AUDIT_DB.GLTEFW_4;

