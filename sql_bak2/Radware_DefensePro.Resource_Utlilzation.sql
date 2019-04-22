delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
where SMA_NAME='Security SMA'
and KPI_NAME='Combined Resource Utilization'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME,
        SUM(NVL(RS_WSDRESOURCE_UTILIZATION / (SYS_UP_TIME_D/100),0)) KPI,
        count(*) INSTANCE_COUNT,
        'DDOS' LOCATION_GROUP
        from RADWARE_IP.RAD_IPNE_ENV_5M@KNOX_IPHLXP
        where (IP_NE_NAME like '%-borderips-%')
        and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME                
)
select
trunc(datetime,'MM') PERIOD_DATE,
'Security SMA' SMA_NAME,
'Radware DefensePro' REPORT_GROUP,
'Core' REGION_GROUP,
LOCATION_GROUP,
'Combined Resource Utilization' KPI_NAME,
'rsWSDResourceUtilization' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
95 PERCENTILE_USED,
PERCENTILE_CONT(0.95) within group (order by KPI) KPI_VALUE,
'%' KPI_UNITS,
300 RAW_POLLING_DURATION,
count(distinct DATETIME) PERIOD_COUNT,
avg(INSTANCE_COUNT) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM'), LOCATION_GROUP;

