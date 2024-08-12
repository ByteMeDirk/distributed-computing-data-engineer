#!/bin/bash

# Clean up the DataNode directory
rm -rf /opt/hadoop/data/dataNode/*

# Ensure proper permissions
chown -R hadoop:hadoop /opt/hadoop/data/dataNode
chmod 755 /opt/hadoop/data/dataNode

# Start the DataNode
hdfs datanode