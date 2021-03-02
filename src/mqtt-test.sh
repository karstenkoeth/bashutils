#!/bin/bash

SLEEP=0.500
LOOP="1"

while [ "$LOOP" = "1" ]
do
    mosquitto_pub -h localhost -t prototype/loadtest -m "O"
    sleep $SLEEP
    mosquitto_pub -h localhost -t prototype/loadtest -m "I"
    sleep $SLEEP
done
