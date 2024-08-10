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

## 1. Configuring Static IP Addresses

To ensure consistent network connectivity, set up static IP addresses for each Raspberry Pi:

1. **Identify network information:**
   ```shell
   ip addr show
   ip route | grep default
   ```

2. **Edit the DHCP configuration:**
   ```shell
   sudo nano /etc/dhcpcd.conf
   ```

3. **Add static IP configuration:**
   ```text
   interface eth0
   static ip_address=<STATIC_IP>/24
   static routers=192.168.1.1
   static domain_name_servers=192.168.1.1 8.8.8.8
   ```
   This configuration establishes a static IP address for the Raspberry Pi, crucial for a stable HDFS cluster. It
   ensures consistency, predictability, and ease of management. Static IPs also ensure consistent DNS resolution, making
   HDFS operations more reliable. Manually configuring network parameters reduces the risk of DHCP-related issues,
   providing a solid networking foundation.

4. **Apply changes:**
   ```shell
   sudo reboot
   ```

5. **Verify configuration:**
   ```shell
   ip addr show
   ```

## 2. Configuring Hostname Resolution

Configuring hostname resolution is crucial for setting up an HDFS cluster as it enables seamless communication between
nodes. By assigning unique hostnames to each Raspberry Pi and updating the hosts file, you create a local DNS-like
system. This allows the nodes to refer to each other by name rather than IP address, which is more convenient and
maintainable. It's particularly important for Hadoop configuration files where you specify the NameNode and DataNode
locations. This setup ensures that even if IP addresses change, the cluster can still function properly as long as the
hostname mappings are updated, providing flexibility and ease of management in your HDFS setup.

1. **Set hostnames:**
   ```shell
   sudo hostnamectl set-hostname <HOSTNAME>  # e.g., pimaster for master, piworker1 for worker
   ```

2. **Update hosts file:**
   ```shell
   sudo nano /etc/hosts
   ```

3. **Add hostnames:**
   ```text
   <MASTER_IP> <MASTER_HOSTNAME>
   <WORKER1_IP> <WORKER1_HOSTNAME>
   # Add more worker entries as needed
   ```

## 3. Setting up Java and Hadoop

This section on setting up Java and Hadoop is crucial for establishing the foundational software environment required
for running HDFS on Raspberry Pi.

The process involves updating the system, installing Java (which Hadoop requires to run), and setting up Hadoop itself.
It ensures that all necessary dependencies are in place, creates a dedicated user for Hadoop operations, and configures
the environment variables and file paths essential for Hadoop's functionality. The configuration files (core-site.xml
and hdfs-site.xml) are set up to define the HDFS cluster's basic structure and behavior.

1. **Update system packages:**
   ```shell
   sudo apt-get update && sudo apt-get upgrade -y
   sudo apt-get -f install
   sudo apt-get clean && sudo apt-get autoclean
   ```

2. **Install OpenJDK:**
   ```shell
   sudo apt install openjdk-17-jdk
   ```

3. **Verify Java installation:**
   ```shell
   java -version
   ```

4. **Set JAVA_HOME:**
   Add to ~/.bashrc:
   ```shell
   export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-armhf
   ```

5. **Create Hadoop user and group:**
   ```shell
   sudo addgroup hadoop
   sudo adduser --ingroup hadoop hadoop
   sudo usermod -aG sudo hadoop
   ```

6. **Install Hadoop:**
   ```shell
   wget https://downloads.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
   tar -xzvf hadoop-3.4.0.tar.gz
   sudo mv hadoop-3.4.0 /opt/hadoop
   ```

7. **Configure Hadoop:**

   Edit core-site.xml:
   ```shell
   sudo nano /opt/hadoop/etc/hadoop/core-site.xml
   ```
   Add:
   ```xml
   <configuration>
       <property>
           <name>fs.defaultFS</name>
           <value>hdfs://<MASTER_HOSTNAME>:9000</value>
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
   </configuration>
   ```

   Edit hadoop-env.sh:
   ```shell
   sudo nano /opt/hadoop/etc/hadoop/hadoop-env.sh
   ```
   Add or modify:
   ```shell
   export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-armhf
   export HADOOP_OS_TYPE=${HADOOP_OS_TYPE:-$(uname -s)}
   ```

8. **Set Hadoop environment:**
   Add to ~/.bashrc:
   ```shell
   export HADOOP_HOME=/opt/hadoop
   export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
   ```
   Then run:
   ```shell
   source ~/.bashrc
   ```

9. **Verify Hadoop installation:**
   ```shell
   hadoop version
   ```

10. **Create necessary directories:**
    ```shell
    sudo mkdir -p /opt/hadoop/data/nameNode
    sudo mkdir -p /opt/hadoop/data/dataNode
    sudo chown -R hadoop:hadoop /opt/hadoop/data
    ```

## 4. Setting up SSH

Setting up SSH for HDFS clusters is crucial for passwordless authentication, automated operations, security, efficiency,
Hadoop requirements, and seamless data transfer. It eliminates manual password entry, is impractical in distributed
systems, and facilitates smooth data transfer across the cluster. This ensures secure and automatic communication
between nodes, crucial for HDFS functionality.

Perform these steps on all nodes:

1. Generate SSH key pair:
   ```shell
   ssh-keygen -t rsa -b 4096
   ```
   Ignore pass-phrases, these are not needed.

2. Set proper permissions:
   ```shell
   chmod 700 ~/.ssh
   ```

3. Add public key to authorized keys:
   ```shell
   cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
   ```

4. Copy public key to other nodes:
   ```shell
   ssh-copy-id hadoop@<OTHER_NODE_HOSTNAME>
   ```

5. Test SSH connection:
   ```shell
   ssh hadoop@<OTHER_NODE_HOSTNAME>
   ```

## 5. Initializing and Starting HDFS

The process of initializing and starting HDFS is crucial for a distributed file system. It starts with formatting the
NameNode, creating and setting permissions for directories, and configuring worker nodes. Starting HDFS brings the
entire system online, addresses potential issues like stack guard warnings and native library problems, and confirms the
system's health and capacity. These steps transform the configured Raspberry Pis into a functioning HDFS cluster ready
for data storage and processing tasks.

1. Format the NameNode (on master only):
   ```shell
   /opt/hadoop/bin/hdfs namenode -format
   ```

2. Create necessary directories and set permissions:
   ```shell
   sudo mkdir -p /opt/hadoop/logs
   sudo chown -R hadoop:hadoop /opt/hadoop
   sudo chmod -R 755 /opt/hadoop
   ```

3. Configure worker nodes:
   ```shell
   sudo nano /opt/hadoop/etc/hadoop/workers
   ```
   Add the hostnames of all worker nodes, one per line.
   To create a Hadoop cluster, add the hostnames or IP addresses of your worker nodes to
   the `/opt/hadoop/etc/hadoop/workers` file. If our example, if using hostnames, add "raspberrypiworker" and if using
   IP addresses, replace "192.168.1.101" with the actual IP address. The file should only contain worker nodes, not the
   master node. The Hadoop system uses this file to determine which nodes to start DataNode and NodeManager processes
   on. The file should be updated based on your setup.

4. Start HDFS:
   ```shell
   /opt/hadoop/sbin/start-dfs.sh
   ```

5. Address potential issues:
    - For stack guard warnings:
      ```shell
      sudo apt-get install execstack
      sudo execstack -c /opt/hadoop/lib/native/libhadoop.so.1.0.0
      ```
    - For native library issues:
      ```shell
      sudo apt-get install build-essential
      ```

6. Verify HDFS status:
   ```shell
   /opt/hadoop/bin/hdfs dfsadmin -report
   ```

## 6. Testing HDFS

This test is designed to verify the basic functionality of your HDFS setup on your Raspberry Pi cluster. It includes
commands like hdfs dfs -mkdir /user and hdfs dfs -mkdir /user/$USER, which create directories in HDFS. The test expects
no output if successful, or an error message if the directories already exist or there's a permission issue. The test
also creates a local file named 'testfile.txt' with the content "Hello, HDFS!". It uploads the local file to the '/test'
directory in HDFS. The test aims to verify that all commands execute without errors, and the '/user', '/user/$USER',
and '/test' directories are created in HDFS. The test also allows you to list the contents of the '/test' directory and
read the file from HDFS, confirming that the basic HDFS operations are working correctly on your Raspberry Pi cluster.

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

## 7. Monitoring and Troubleshooting

- Check logs:
  ```shell
  tail -f /opt/hadoop/logs/*
  ```

- Monitor web interfaces:
    - NameNode: http://<master-node>:9870
    - DataNode: http://<data-node>:9864

- Common issues:
    - Firewall settings: Ensure necessary ports are open
    - Java version compatibility: Verify Java version is compatible with Hadoop
    - Hostname resolution: Ensure /etc/hosts is correctly configured on all nodes

Remember to adjust configurations for production use, implement security measures, and regularly back up important data.
Consistency in configurations across all nodes is crucial for proper cluster operation.
