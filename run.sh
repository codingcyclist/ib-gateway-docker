#!/bin/bash

set -e
set -o errexit

if [[ "$TRADING_MODE" = "paper" ]]; then
    TWSUSERID=$IB_PAPER_USERNAME
    TWSPASSWORD=$IB_PAPER_PASSWORD
else
    TWSUSERID=$IB_LIVE_USERNAME
    TWSPASSWORD=$IB_LIVE_PASSWORD
fi

rm -f /tmp/.X0-lock

Xvfb :0 &
sleep 1

x11vnc -rfbport $VNC_PORT -display :0 -usepw -forever &
socat TCP-LISTEN:$TWS_PORT,fork TCP:localhost:4001,forever &

# Start this last and directly, so that if the gateway terminates for any reason, the container will stop as well.
# Retry behavior can be implemented by re-running the container.
/opt/ibc/scripts/ibcstart.sh $(ls ~/Jts/ibgateway) --gateway "--mode=$TRADING_MODE" "--user=$TWSUSERID" "--pw=$TWSPASSWORD"
