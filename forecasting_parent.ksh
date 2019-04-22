#!/usr/bin/ksh

BASE_DIR=/teoco/sa_root_med01
. $BASE_DIR/project/env/env.ksh

$HOME/.local/bin/pipenv run python forecasting.py --mask "Border_Routers_P_Routers*" &
#$HOME/.local/bin/pipenv run python forecasting.py &

