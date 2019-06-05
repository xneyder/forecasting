delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
 where SMA_NAME='Security SMA'
   and KPI_NAME='Throughput In'
   and REPORT_GROUP='Juniper Extranet VPN Service'
   AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');

--CREATE TABLE in Production only
CREATE table AUDIT_DB.Security_SMA_1(
        DATETIME timestamp,
        KPI number(23,6),
        DATETIME_COUNT number(13),
        NE_COUNT number(13),
        LOCATION_GROUP varchar2(55)
        );

INSERT INTO AUDIT_DB.Security_SMA_1
 select /*+ materialize */ DATETIME,
        SUM(nvl(IF_IN_THROUGHPUT,0)) KPI,
        count(distinct DATETIME) DATETIME_COUNT,
        count(distinct IP_NE_NAME) NE_COUNT,
        'Sch' LOCATION_GROUP
   from ALL_IP.STD_IPIF_5M@KNOX_IPHLXP
  where IP_NE_NAME like '%-enetvpn-%' 
    AND INTERFACE_NAME in ('reth0','reth1')
    and DATETIME >= '<start_date>' and DATETIME <= '<end_date>'
  group by DATETIME;

INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
 select
        trunc(datetime,'MM') PERIOD_DATE,
        'Security SMA' SMA_NAME,
        'Juniper Extranet VPN Service' REPORT_GROUP,
        'Core' REGION_GROUP,
        'Core' LOCATION_GROUP,
        'Throughput In' KPI_NAME,
        'ifHCInOctets' INDICATOR_,
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
   from AUDIT_DB.Security_SMA_1
  group by trunc(datetime,'MM'), LOCATION_GROUP;

drop table AUDIT_DB.Security_SMA_1

