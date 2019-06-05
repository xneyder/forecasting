#!/usr/bin/ksh

BASE_DIR=/teoco/sa_root_med01
. $BASE_DIR/project/env/env.ksh
cd /teoco/sa_root_med01/integration/scripts/implementation/forecasting

$HOME/.local/bin/pipenv run python forecasting.py --mask "100G_LTE_FW.Total_Throughput_*" &
#$HOME/.local/bin/pipenv run python forecasting.py &

