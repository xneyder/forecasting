delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
where SMA_NAME='ERI_VoLTE911_vSBG'
and KPI_NAME='IMS ASBG Registered Users'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME,
        SUM(nvl(SBGSIPREGSTATREGUSERGAUGE,0)) KPI,
        count(*) INSTANCE_COUNT,
        'Santa Clara' LOCATION_GROUP
        from ERICSSON_SBGV.SBG_PROXYREGISTRARPA_15M
        where (SBGV_NAME like 'casant%')
        and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME
        UNION
        select /*+ materialize */ DATETIME,
        SUM(nvl(SBGSIPREGSTATREGUSERGAUGE,0)) KPI,
        count(*) INSTANCE_COUNT,
        'Ashburn' LOCATION_GROUP
        from ERICSSON_SBGV.SBG_PROXYREGISTRARPA_15M
        where (SBGV_NAME like 'vaashb%')
        and DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
        group by DATETIME

)
select
trunc(datetime,'MM') PERIOD_DATE,
'ERI_VoLTE911_vSBG' SMA_NAME,
'vSBG' REPORT_GROUP,
'Core' REGION_GROUP,
LOCATION_GROUP,
'IMS ASBG Registered Users' KPI_NAME,
'sbgSipRegStatRegUserGauge' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
97 PERCENTILE_USED,
PERCENTILE_CONT(0.97) within group (order by KPI) KPI_VALUE,
'Counter' KPI_UNITS,
300 RAW_POLLING_DURATION,
count(DATETIME) PERIOD_COUNT,
avg(INSTANCE_COUNT) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM'), LOCATION_GROUP;

