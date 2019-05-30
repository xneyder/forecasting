#!/usr/bin/ksh

BASE_DIR=/teoco/sa_root_med01
. $BASE_DIR/project/env/env.ksh
cd /teoco/sa_root_med01/integration/scripts/implementation/forecasting

$HOME/.local/bin/pipenv run python forecasting.py --mask "Cisco_ASR_1006_BV.Total_Throughput_INGRESS.sql" &
#$HOME/.local/bin/pipenv run python forecasting.py &

