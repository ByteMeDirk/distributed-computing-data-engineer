# Setting Up HDFS on Raspberry Pi: A Fun Home Project Adventure!

Ever wondered what to do with those Raspberry Pis gathering dust in your drawer? Well, buckle up, because we're about to
turn them into a mini Hadoop Distributed File System (HDFS) cluster! Why? Because we can, and because it's an awesome
way to learn about big data technologies on a small scale!

## What's This All About?

In this tutorial, I'll guide you through the process of setting up HDFS on Raspberry Pi 4B devices. It's a fantastic
way to:

- Learn about HDFS and Hadoop
- Get hands-on experience with Linux
- Understand the challenges of distributed systems
- Have fun with a unique home project!

Before beginning, I will not get into the nitty-gritty of setting up the Raspberry Pis, that's something you can get
into, once you have them running and connected to your home Wi-Fi, you're ready to tackle this tutorial.

## Why This is Great (and Not So Great)

### The Good Stuff:

- Perfect for learning and experimentation
- Low-cost entry into big data concepts
- Great conversation starter for tech enthusiasts
- Potential for small-scale home data projects

This setup isn't meant for production use or serious data processing. It's like building a mini race track in your
backyard – fun, but you won't be hosting Formula 1 races anytime soon!

## What Could You Actually Do With This?

While not suitable for enterprise-level tasks, your Raspberry Pi HDFS cluster could be used for:

- Personal file storage and backup
- Small-scale data analysis projects
- Learning and practicing Hadoop ecosystem tools
- Prototyping ideas before scaling to larger systems

So, if you're ready to hop into this quirky tech, let's dive in and turn those idle Raspberry Pis into a mini
big data powerhouse!

## Introduction

This guide walks you through setting up a Hadoop Distributed File System (HDFS) cluster using Raspberry Pi devices. It's
an educational project designed to provide hands-on experience with distributed systems, Linux, and big data
technologies on a small scale.

## Prerequisites

- Two or more Raspberry Pi 4B devices (one for NameNode, others for DataNodes)
- Raspberry Pi OS (64-bit recommended) installed on all devices
- Network connectivity between all Raspberry Pi devices
- Basic knowledge of Linux commands
- Minimum 4GB RAM and 32GB storage on each Raspberry Pi

## 1. Initial Setup

### 1.1 Configure Static IP Addresses

For each Raspberry Pi:

1. Identify network information:

```shell
ip addr show
ip route | grep default
```

2. Edit the DHCP configuration:

```shell
sudo nano /etc/dhcpcd.conf  
```

3. Add static IP configuration (adjust values as needed):

```shell
interface eth0
static ip_address=<ip_address>/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8
```

4. Apply changes:

```shell
sudo reboot
```

5. Verify configuration:

```shell
ip addr show
```

### 1.2 Configure Hostname Resolution

**On each Raspberry Pi:**

1. Set unique hostnames:

```shell
sudo hostnamectl set-hostname namenode  # For the master node
sudo hostnamectl set-hostname datanode1  # For the first worker node
# Repeat for additional nodes
```

2. Update hosts file:

```shell
sudo nano /etc/hosts
```

3. Add entries for all nodes:

```shell
<ip_address> namenode
<ip_address> datanode1
# Add more entries as needed
```

4. Reboot to apply changes:

```shell
sudo reboot
```

5. Test connectivity:

```shell
ping namenode
ping datanode1
```

## 2. Install Java and Hadoop

**Perform these steps on all nodes:**

1. Update system packages:

```shell
sudo apt update && sudo apt upgrade -y && sudo apt -f install -y && sudo apt clean && sudo apt autoclean
```

2. Install OpenJDK:

```shell
sudo apt install openjdk-17-jdk -y
```

To find the location of the Java installation, run:

```shell
sudo update-alternatives --config java
```

3. Verify Java installation:

```shell
java -version
```

4. Set JAVA_HOME:

```shell
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64' >> ~/.bashrc
source ~/.bashrc
```

5. Create Hadoop user and group:

```shell
sudo addgroup hadoop
sudo adduser --ingroup hadoop hadoop
sudo usermod -aG sudo hadoop
```

6. Switch to hadoop user:

```shell
su - hadoop
```

7. Install Hadoop:

```shell
wget https://downloads.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz && tar -xzvf hadoop-3.4.0.tar.gz && rm hadoop-3.4.0.tar.gz && sudo mv hadoop-3.4.0 /opt/hadoop
```

8. Set Hadoop environment variables:

```shell
echo 'export HADOOP_HOME=/opt/hadoop' >> ~/.bashrc
echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >> ~/.bashrc
source ~/.bashrc
```

9. Configure Hadoop:

```shell
sudo nano /opt/hadoop/etc/hadoop/core-site.xml
```

Add:

```xml

<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://namenode:9000</value>
    </property>
</configuration>
```

Edit hdfs-site.xml:

```shell
sudo nano /opt/hadoop/etc/hadoop/hdfs-site.xml
```

Add:

```xml

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
    <property>
        <name>dfs.webhdfs.enabled</name>
        <value>true</value>
    </property>
</configuration>
```

Edit hadoop-env.sh:

```shell
sudo nano /opt/hadoop/etc/hadoop/hadoop-env.sh
```

Add or modify:

```shell
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export HADOOP_OS_TYPE=${HADOOP_OS_TYPE:-$(uname -s)}
```

10. Create necessary directories:

```shell
sudo mkdir -p /opt/hadoop/data/nameNode
sudo mkdir -p /opt/hadoop/data/dataNode
sudo chown -R hadoop:hadoop /opt/hadoop
sudo chmod -R 755 /opt/hadoop
```

11. Verify Hadoop installation:

```shell
hadoop version
```

## 3. Set up SSH

Perform these steps on all nodes:

1. Generate SSH key pair:

```shell
ssh-keygen -t rsa -b 4096
```

_Press Enter for all prompts to use default settings and no passphrase._

2. Set proper permissions:

```shell
chmod 700 ~/.ssh
```

3. Add public key to authorized_keys:

```shell
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

4. Copy public key to other nodes:

From namenode to datanodes:

```shell
ssh-copy-id hadoop@datanode1
```

From datanodes to namenode:

```shell
ssh-copy-id hadoop@namenode
```

5. Test SSH connection:

```shell
ssh hadoop@datanode1
ssh hadoop@namenode
```

## 4. Initialize and Start HDFS

**On the NameNode:**

1. Format the NameNode:

```shell
hdfs namenode -format
```

2. Edit the workers file:

```shell
sudo nano /opt/hadoop/etc/hadoop/workers
```

Add DataNode hostnames:

```shell
datanode1
# Add more hostnames as needed
```

3. Start HDFS:

```shell
start-dfs.sh
```

4. Verify HDFS status:

```shell
hdfs dfsadmin -report
```

## 5. Test HDFS

Perform these basic HDFS operations:

```shell
hdfs dfs -mkdir /user
hdfs dfs -mkdir /user/$USER
hdfs dfs -mkdir /test
echo "Hello, HDFS!" > testfile.txt
hdfs dfs -put testfile.txt /test
hdfs dfs -ls /test
hdfs dfs -cat /test/testfile.txt
```

## 6. Monitor and Troubleshoot

1. Check logs:
    - ```shell 
           tail -f /opt/hadoop/logs/*
     ```
2. Monitor web interfaces:
    - NameNode: http://namenode:9870
    - DataNode: http://datanode1:9864
3. Common issues and solutions:
    - Firewall settings: Ensure ports 9000, 9870, and 9864 are open.
    - Java version compatibility: Verify Java version is compatible with Hadoop.
    - Hostname resolution: Ensure /etc/hosts is correctly configured on all nodes.
    - DataNode not connecting to NameNode:
        - Check if DataNode process is running: `jps`
        - Verify network connectivity: `ping namenode`
    - Missing blocks or corrupt files:
        - Run HDFS filesystem check: `hdfs fsck /`
        - If necessary, delete corrupt files: `hdfs fsck / -delete`
    - Configuration parsing errors:
        - Double-check XML syntax in configuration files, ensuring all tags are properly closed.
4. Performance Optimization:
    - Adjust memory settings in hadoop-env.sh, yarn-site.xml, and mapred-site.xml based on your Raspberry Pi's
      resources.
    - Consider overclocking your Raspberry Pi for better performance (at the cost of higher power consumption and heat
      generation).
5. Security Considerations:
    - Implement Kerberos authentication for production environments.
    - Use firewalls to restrict access to Hadoop ports.
    - Regularly update and patch your system.

## 7. Stopping the Cluster

To stop HDFS:

```shell
stop-dfs.sh
```

## Conclusion

This setup provides a functional HDFS cluster on Raspberry Pi devices. While not suitable for production workloads, it
serves as an excellent learning tool for understanding distributed systems and Hadoop ecosystem technologies. Remember
to adjust configurations for your specific needs, implement proper security measures, and regularly maintain your
cluster.

For production use or larger-scale projects, consider upgrading to more powerful hardware and implementing additional
Hadoop ecosystem components like YARN and MapReduce.
