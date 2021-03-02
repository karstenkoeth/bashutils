#!/bin/bash

SLEEP="500 ms"
LOOP="1"

while [ "$LOOP" ="1" ]
do
    mosquitto_pub -h localhost -t prototype -m "O"
    sleep $SLEEP
    mosquitto_pub -h localhost -t prototype -m "I"
    sleep $SLEEP
done
