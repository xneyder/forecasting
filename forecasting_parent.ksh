#!/usr/bin/ksh

BASE_DIR=/teoco/sa_root_med01
. $BASE_DIR/project/env/env.ksh

#$HOME/.local/bin/pipenv run python forecasting.py --mask "Cisco_TACACS.curThroughputUsage_AVG.sql" &
$HOME/.local/bin/pipenv run python forecasting.py &

