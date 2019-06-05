delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
 where SMA_NAME='Security SMA'
   and KPI_NAME='Service Concurrent Flow Sessions'
   and REPORT_GROUP='Security SMA'
   AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');

--CREATE TABLE in Production only
CREATE table AUDIT_DB.Security_SMA_3(
        DATETIME timestamp,
        KPI number(23,6),
        DATETIME_COUNT number(13),
        NE_COUNT number(13),
        LOCATION_GROUP varchar2(55)
        );

INSERT INTO AUDIT_DB.Security_SMA_3
 select /*+ materialize */ DATETIME,
        SUM(NVL(CURRENT_FLOW_SESSION,0)) KPI,
        count(distinct DATETIME) DATETIME_COUNT,
        count(distinct IP_NE_NAME) NE_COUNT,
        'Sch' LOCATION_GROUP
   from JUNIPER_IP.JNX_IPNE_SPUMONITOR_5M@KNOX_IPHLXP
  where IP_NE_NAME like '%-enetvpn-%'
    and DATETIME >= '<start_date>' and DATETIME <= '<end_date>'
  group by DATETIME;

INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
 select
        trunc(datetime,'MM') PERIOD_DATE,
        'Security SMA' SMA_NAME,
        'Juniper Extranet VPN Service' REPORT_GROUP,
        'Core' REGION_GROUP,
        'Core' LOCATION_GROUP,
        'Service Concurrent Flow Sessions' KPI_NAME,
        'jnxJsSPUMonitoringCurrentFlowSession' INDICATOR_,
        'MM' TIME_AGG_TYPE,
        'PERC' MATH_AGG_TYPE,
        95 PERCENTILE_USED,
        PERCENTILE_CONT(0.95) within group (order by KPI) KPI_VALUE,
        '#' KPI_UNITS,
        300 RAW_POLLING_DURATION,
        count(distinct DATETIME) PERIOD_COUNT,
        avg(NE_COUNT) AVG_INSTANCE_COUNT,
        sysdate REC_CREATE_DATE,
        sysdate LAST_UPDATE_DATE
   from AUDIT_DB.Security_SMA_3
  group by trunc(datetime,'MM'), LOCATION_GROUP;

drop table AUDIT_DB.Security_SMA_3

