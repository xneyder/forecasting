delete from SMA_HLX.SMA_SUMMARY@SCHAHLXPRD
where SMA_NAME='ERI_VoLTE911_SBG'
and KPI_NAME='IMS SBG Simultaneous SIP Sessions'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@SCHAHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME,
        SUM(nvl((SBGSIPACTIVEINCSESSIONS +  SBGSIPACTIVEOUTSESSIONS),0)) KPI,
	count(distinct DATETIME) DATETIME_COUNT,
        count(distinct SBG_NAME) NE_COUNT,
        'SBG-1' LOCATION_GROUP
        from ERICSSON_SBG.ERI_SBG_SIPV6_15M
        where (SBG_NAME like '%-sbg-01%')
        and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME
        UNION
        select /*+ materialize */ DATETIME,
        SUM(nvl((SBGSIPACTIVEINCSESSIONS +  SBGSIPACTIVEOUTSESSIONS),0)) KPI,
	count(distinct DATETIME) DATETIME_COUNT,
        count(distinct SBG_NAME) NE_COUNT,
        'SBG-2' LOCATION_GROUP
        from ERICSSON_SBG.ERI_SBG_SIPV6_15M
        where (SBG_NAME like '%-sbg-02%')
        and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME
        
)
select
trunc(datetime,'MM') PERIOD_DATE,
'ERI_VoLTE911_SBG' SMA_NAME,
'SBG' REPORT_GROUP,
'Core' REGION_GROUP,
LOCATION_GROUP,
'IMS SBG Simultaneous SIP Sessions' KPI_NAME,
'sbgActiveSessions' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
97 PERCENTILE_USED,
PERCENTILE_CONT(0.97) within group (order by KPI) KPI_VALUE,
'counter' KPI_UNITS,
300 RAW_POLLING_DURATION,
sum(DATETIME_COUNT) PERIOD_COUNT,
avg(NE_COUNT) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM'), LOCATION_GROUP;

