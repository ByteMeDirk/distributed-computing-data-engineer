#!/bin/bash

while true
do
    hadoop fs -put -f /home/jovyan/work/* /user/jovyan/notebooks/work/
    sleep 60  # Sync every 60 seconds
done
