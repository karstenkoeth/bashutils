#!/bin/bash

SLEEP=0.500
LOOP="1"

while [ "$LOOP" = "1" ]
do
    curl http://localhost:11883/data/818c4143-11a0-4254-b22b-b0f2b9ddba55/prototype/loadtest
    sleep $SLEEP
done
