delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
where SMA_NAME='National Access Engineering SMA'
and KPI_NAME='IMS ASBG Registered Users'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME,
        SUM(nvl(SBGSIPREGSTATREGUSERGAUGE,0)) KPI,
	count(distinct DATETIME) DATETIME_COUNT,
        count(distinct SBG_NAME) NE_COUNT,
        'SBG-1' LOCATION_GROUP
        from ERICSSON_SBG.ERI_SBG_PROXYREGV6_15M@KNOX_IPHLXP
        where (SBG_NAME like '%-sbg-01%')
        and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME
        UNION
        select /*+ materialize */ DATETIME,
        SUM(nvl(SBGSIPREGSTATREGUSERGAUGE,0)) KPI,
	count(distinct DATETIME) DATETIME_COUNT,
        count(distinct SBG_NAME) NE_COUNT,
        'SBG-2' LOCATION_GROUP
        from ERICSSON_SBG.ERI_SBG_PROXYREGV6_15M@KNOX_IPHLXP
        where (SBG_NAME like '%-sbg-02%')
        and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME
        
)
select
trunc(datetime,'MM') PERIOD_DATE,
'National Access Engineering SMA' SMA_NAME,
'ERI_VoLTE911' REPORT_GROUP,
'SBG' REGION_GROUP,
LOCATION_GROUP,
'IMS ASBG Registered Users' KPI_NAME,
'sbgSipRegStatRegUserGauge' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
97 PERCENTILE_USED,
PERCENTILE_CONT(0.97) within group (order by KPI) KPI_VALUE,
'counter' KPI_UNITS,
300 RAW_POLLING_DURATION,
count(distinct DATETIME) PERIOD_COUNT,
avg(NE_COUNT) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM'), LOCATION_GROUP;

