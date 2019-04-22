delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
where SMA_NAME='Border_Routers P_Routers'
and KPI_NAME='Route Table Size'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME, IP_NE_NAME,
        SUM(nvl(IP_CIDR_ROUTE_NUMBER,0)) KPI,
        count(distinct DATETIME) DATETIME_COUNT,
	count(distinct IP_NE_NAME) NE_COUNT
        from ALL_IP.STD_IPNE_IPCIDR_NUM_5M
        where DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        and (IP_NE_NAME like '%-border-%' or IP_NE_NAME like '%-p-%')
        group by DATETIME, IP_NE_NAME
)
select
trunc(datetime,'MM') PERIOD_DATE,
'Border_Routers P_Routers' SMA_NAME,
' ' REPORT_GROUP,
'Core' REGION_GROUP,
'IP_NE_NAME' LOCATION_GROUP,
'Route Table Size' KPI_NAME,
'ipCidrRouteNumber' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
97 PERCENTILE_USED,
PERCENTILE_CONT(0.97) within group (order by KPI) KPI_VALUE,
'COUNTER64' KPI_UNITS,
300 RAW_POLLING_DURATION,
sum(DATETIME_COUNT) PERIOD_COUNT,
avg(NE_COUNT) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM');

