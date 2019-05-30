-- Cisco_ASR_1006_BV.Total_Throughput_INGRESS.sql
delete from SMA_HLX.SMA_OPERATIONS@SCHAHLXPRD
 where SMA_NAME='Routing/Switching SMA'
   and KPI_NAME='Combined Highwater Throughput IN'
   and REPORT_GROUP='BV VPN Tunnel Aggregator'
   AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');

CREATE table AUDIT_DB.CISCO_ASR_ING(
        DATETIME timestamp,
        KPI number(23,6),
	NE_COUNT NUMBER(6),
        ENTRIES number(13)
        );

INSERT INTO AUDIT_DB.CISCO_ASR_ING
 select /*+ materialize */ DATETIME, 
        SUM(nvl(IF_IN_THROUGHPUT,0)) KPI,
	count(distinct IP_NE_NAME) NE_COUNT,
        count(*) ENTRIES
        from ALL_IP.STD_IPIF_5M@IPHLXP
  where (IP_NE_NAME like '%-bvvpn-%')
    and DATETIME >= '<start_date>' and DATETIME <= '<end_date>'
  group by DATETIME;
	
INSERT INTO SMA_HLX.SMA_OPERATIONS@SCHAHLXPRD
select
	trunc(datetime,'MM') PERIOD_DATE,
	'Routing/Switching SMA' SMA_NAME,
	'BV VPN Tunnel Aggregator' REPORT_GROUP,
	'Core' REGION_GROUP,
	'Core' LOCATION_GROUP,
	'Combined Highwater Throughput IN' KPI_NAME,
	'ifHCInOctets' INDICATOR_,
	'MM' TIME_AGG_TYPE,
	'PERC' MATH_AGG_TYPE,
	97 PERCENTILE_USED,
	PERCENTILE_CONT(0.97) within group (order by KPI) KPI_VALUE,
	'Bytes per second' KPI_UNITS,
	300 RAW_POLLING_DURATION,
	count(distinct DATETIME) PERIOD_COUNT,
	avg(NE_COUNT) AVG_INSTANCE_COUNT,
	sysdate REC_CREATE_DATE,
	sysdate LAST_UPDATE_DATE,
	'' KPI_FIX
 from AUDIT_DB.CISCO_ASR_ING
group by trunc(datetime,'MM');

drop table AUDIT_DB.CISCO_ASR_ING;
