#!/bin/bash

# Format the NameNode if it hasn't been formatted yet
if [ ! -d "/opt/hadoop/data/nameNode/current" ]; then
    echo "Formatting NameNode..."
    hdfs namenode -format
fi

# Start the NameNode
hdfs namenode