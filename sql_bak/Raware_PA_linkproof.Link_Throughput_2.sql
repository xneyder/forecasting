delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
where SMA_NAME='Raware PA linkproof'
and KPI_NAME='Link Throughput 2'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME,
        sum(nvl(IF_THROUGHPUT,0)) KPI,
        sum(ENTRIES) ENTRIES,
        count(distinct IP_NE_NAME) NE_COUNT,
        'Sch' LOCATION_GROUP
        from ALL_IP.STD_IPIF_HR@KNOX_IPHLXP
        where (IP_NE_NAME like '%-mdfwlbin-%' OR IP_NE_NAME like '%-mdfwlbout-%' OR IP_NE_NAME like '%-mdfw-%')
		AND IP_NE_NAME like 'ilscha%'
        and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME
        UNION
        select /*+ materialize */ DATETIME,
        sum(nvl(IF_THROUGHPUT,0)) KPI,
        sum(ENTRIES) ENTRIES,
        count(distinct IP_NE_NAME) NE_COUNT,
        'Knox' LOCATION_GROUP
        from ALL_IP.STD_IPIF_HR
        where (IP_NE_NAME like '%-mdfwlbin-%' OR IP_NE_NAME like '%-mdfwlbout-%' OR IP_NE_NAME like '%-mdfw-%')
		AND IP_NE_NAME like 'tnknox%'
        and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME

)
select
trunc(datetime,'MM') PERIOD_DATE,
'Raware PA linkproof' SMA_NAME,
' ' REPORT_GROUP,
'Core' REGION_GROUP,
LOCATION_GROUP,
'Link Throughput 2' KPI_NAME,
'' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
95 PERCENTILE_USED,
PERCENTILE_CONT(0.95) within group (order by KPI) KPI_VALUE,
'Inbound and Outbound Bits Per Seconds' KPI_UNITS,
300 RAW_POLLING_DURATION,
sum(ENTRIES) PERIOD_COUNT,
avg(NE_COUNT) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM'), LOCATION_GROUP;

