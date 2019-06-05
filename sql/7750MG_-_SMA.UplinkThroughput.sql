delete from SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
where SMA_NAME='7750MG - SMA'
and KPI_NAME='UplinkThroughput'
AND PERIOD_DATE=trunc(trunc(sysdate,'MM')-1,'MM');
INSERT INTO SMA_HLX.SMA_SUMMARY@KNOXHLXPRD
with pm_data as
(
        select /*+ materialize */ DATETIME,  SGW_ID,
        SUM(nvl(UPLINKTHROUGHPUT,0)) KPI,
        count(*) ENTRIES
        from ALU_SAEGW.KCIDATAPLMSM_STATS_15M@KNOXHLXPRD
        where DATETIME >= trunc(trunc(sysdate,'MM')-1,'MM') and DATETIME < trunc(sysdate,'MM')
	and SGW_ID like '%-saegw-0_'
        group by DATETIME,  SGW_ID
)
select
trunc(datetime,'MM') PERIOD_DATE,
'7750MG - SMA' SMA_NAME,
'LCC SAEGW' REPORT_GROUP,
decode(SGW_ID, 'ncashe-saegw-01','Atlanta', 'iacdr2-saegw-01','Schaumburg', 'ncclin-saegw-01','Ashburn', 'mocolu-saegw-01','Schaumburg', 'nhcong-saegw-01','Ashburn', 'caeure-saegw-01','Santa Clara', 'megran-saegw-01','Ashburn', 'ncgree-saegw-01','Ashburn', 'iajhtn-saegw-01','Schaumburg', 'mojopl-saegw-01','Schaumburg', 'tnknxv-saegw-01','Atlanta', 'valync-saegw-01','Ashburn', 'wimadi-saegw-02','Schaumburg', 'ormedf-saegw-01','Santa Clara', 'wimnsh-saegw-01','Schaumburg', 'wvmor2-saegw-01','Ashburn', 'winewb-saegw-01','Schaumburg', 'okokla-saegw-01','Schaumburg', 'neomah-saegw-01','Atlanta', 'okowas-saegw-01','Atlanta', 'ilpeo2-saegw-01','Schaumburg', 'varoan-saegw-01','Ashburn', 'ilroc2-saegw-01','Schaumburg', 'kssali-saegw-01','Schaumburg', 'wayaki-saegw-01','Santa Clara', 'Not defined') REGION_GROUP,
SGW_ID LOCATION_GROUP,
'UplinkThroughput' KPI_NAME,
'Inbound Tput' INDICATOR_,
'MM' TIME_AGG_TYPE,
'PERC' MATH_AGG_TYPE,
97 PERCENTILE_USED,
PERCENTILE_CONT(0.97) within group (order by KPI) KPI_VALUE,
'Mbps' KPI_UNITS,
900 RAW_POLLING_DURATION,
count(distinct DATETIME) PERIOD_COUNT,
avg(ENTRIES)/max(ENTRIES) AVG_INSTANCE_COUNT,
sysdate REC_CREATE_DATE,
sysdate LAST_UPDATE_DATE
from pm_data
group by trunc(datetime,'MM'),SGW_ID;

