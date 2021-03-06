-- Border_Routers_P_Routers.Interface_Throughput.sql

delete from SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
where SMA_NAME='National Access Engineering SMA'
and KPI_NAME='Interface Throughput'
and REPORT_GROUP='Border_Routers P_Routers'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');

--CREATE TABLE in Porduction
CREATE table AUDIT_DB.BORDER_RPR(
        DATETIME timestamp,
	IP_NE_NAME VARCHAR2(255),
        KPI number(23,6),
        ENTRIES number(13)
        );

INSERT INTO AUDIT_DB.BORDER_RPR
 select /*+ materialize */ 
	DATETIME, 
	IP_NE_NAME,
        SUM(nvl(IF_THROUGHPUT,0)) KPI,
        count(*) ENTRIES
        from ALL_IP.STD_IPIF_5M@KNOX_IPHLXP
  where (IP_NE_NAME like '%-border-%' or IP_NE_NAME like '%-p-%')
    and DATETIME >= '<start_date>' and DATETIME <= '<end_date>'
    group by DATETIME, IP_NE_NAME;
		
INSERT INTO SMA_HLX.SMA_OPERATIONS@KNOXHLXPRD
select
	trunc(datetime,'MM') PERIOD_DATE,
	'National Access Engineering SMA' SMA_NAME,
	'Border_Routers P_Routers' REPORT_GROUP,
	'Core' REGION_GROUP,
	IP_NE_NAME LOCATION_GROUP,
	'Interface Throughput' KPI_NAME,
	'Throughput Bothways' INDICATOR_,
	'MM' TIME_AGG_TYPE,
	'PERC' MATH_AGG_TYPE,
	97 PERCENTILE_USED,
	PERCENTILE_CONT(0.97) within group (order by KPI) KPI_VALUE,
	'Bytes per second' KPI_UNITS,
	300 RAW_POLLING_DURATION,
	count(distinct DATETIME) PERIOD_COUNT,
	avg(ENTRIES)/max(ENTRIES) AVG_INSTANCE_COUNT,
	sysdate REC_CREATE_DATE,
	sysdate LAST_UPDATE_DATE
  from AUDIT_DB.BORDER_RPR
group by trunc(datetime,'MM'),IP_NE_NAME;

drop table AUDIT_DB.BORDER_RPR;
