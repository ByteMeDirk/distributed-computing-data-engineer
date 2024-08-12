#!/bin/bash

# Format the NameNode if it hasn't been formatted yet
if [ ! -d "/opt/hadoop/data/nameNode/current" ]; then
    echo "Formatting NameNode..."
    hdfs namenode -format
fi

# Start the NameNode
hdfs namenode &

# Wait for the NameNode to be up and running
sleep 30

# Create a directory in HDFS for notebooks
hdfs dfs -mkdir -p /user/jovyan/notebooks

# Mount the local notebooks directory to HDFS
hadoop fs -put /home/jovyan/work /user/jovyan/notebooks

# Keep the script running
tail -f /dev/null
