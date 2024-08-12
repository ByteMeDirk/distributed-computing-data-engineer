#!/bin/bash

# Bootstrap script for setting up HDFS on Raspberry Pi
# Usage: ./bootstrap.sh <node_type> <node_ip> <master_ip>
# node_type: "namenode" or "datanode"
# node_ip: IP address for this node
# master_ip: IP address of the master node (NameNode)

# Check if correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <node_type> <node_ip> <master_ip>"
    exit 1
fi

NODE_TYPE=$1
NODE_IP=$2
MASTER_IP=$3

# Update system packages
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get -f install
sudo apt-get clean && sudo apt-get autoclean

# Install OpenJDK
sudo apt install openjdk-17-jdk -y

# Set JAVA_HOME
echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-armhf" >> ~/.bashrc
source ~/.bashrc

# Create Hadoop user and group
sudo addgroup hadoop
sudo adduser --ingroup hadoop hadoop --gecos "" --disabled-password
echo "hadoop:hadoop" | sudo chpasswd
sudo usermod -aG sudo hadoop

# Install Hadoop
wget https://downloads.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
tar -xzvf hadoop-3.4.0.tar.gz
sudo mv hadoop-3.4.0 /opt/hadoop

# Configure Hadoop
sudo tee /opt/hadoop/etc/hadoop/core-site.xml > /dev/null <<EOL
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://${MASTER_IP}:9000</value>
    </property>
</configuration>
EOL

sudo tee /opt/hadoop/etc/hadoop/hdfs-site.xml > /dev/null <<EOL
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>/opt/hadoop/data/nameNode</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/opt/hadoop/data/dataNode</value>
    </property>
</configuration>
EOL

# Set Hadoop environment variables
echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-armhf" | sudo tee -a /opt/hadoop/etc/hadoop/hadoop-env.sh
echo "export HADOOP_OS_TYPE=\${HADOOP_OS_TYPE:-\$(uname -s)}" | sudo tee -a /opt/hadoop/etc/hadoop/hadoop-env.sh

# Set Hadoop environment
echo "export HADOOP_HOME=/opt/hadoop" >> ~/.bashrc
echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" >> ~/.bashrc
source ~/.bashrc

# Create necessary directories
sudo mkdir -p /opt/hadoop/data/nameNode
sudo mkdir -p /opt/hadoop/data/dataNode
sudo chown -R hadoop:hadoop /opt/hadoop/data

# Set up SSH
sudo -u hadoop ssh-keygen -t rsa -b 4096 -N "" -f /home/hadoop/.ssh/id_rsa
sudo -u hadoop cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys
sudo -u hadoop chmod 700 /home/hadoop/.ssh
sudo -u hadoop chmod 600 /home/hadoop/.ssh/authorized_keys

# Configure static IP
sudo tee -a /etc/dhcpcd.conf > /dev/null <<EOL

interface eth0
static ip_address=${NODE_IP}/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8
EOL

# Set hostname
if [ "$NODE_TYPE" == "namenode" ]; then
    sudo hostnamectl set-hostname pimaster
else
    sudo hostnamectl set-hostname piworker
fi

# Update hosts file
sudo tee -a /etc/hosts > /dev/null <<EOL

${MASTER_IP} pimaster
${NODE_IP} $(hostname)
EOL

# Node-specific setup
if [ "$NODE_TYPE" == "namenode" ]; then
    # Format the NameNode
    sudo -u hadoop /opt/hadoop/bin/hdfs namenode -format

    # Create workers file
    echo "piworker" | sudo tee /opt/hadoop/etc/hadoop/workers
else
    # For DataNode, ensure it's in the workers file on the NameNode
    ssh hadoop@${MASTER_IP} "echo $(hostname) | sudo tee -a /opt/hadoop/etc/hadoop/workers"
fi

# Start HDFS
if [ "$NODE_TYPE" == "namenode" ]; then
    sudo -u hadoop /opt/hadoop/sbin/start-dfs.sh
fi

# Reboot to apply network changes
sudo reboot
