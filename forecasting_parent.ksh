#!/usr/bin/ksh

BASE_DIR=/teoco/sa_root_med01
. $BASE_DIR/project/env/env.ksh

#$HOME/.local/bin/pipenv run python forecasting.py --mask "RCC_DNS_E-E.switchCapSLBSessionsCurrEnt.sql" &
$HOME/.local/bin/pipenv run python forecasting.py &

