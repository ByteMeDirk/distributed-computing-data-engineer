# Setting Up PySpark on Raspberry Pi Cluster: A Comprehensive Guide

For this tutorial we will go through a rather exciting project of setting up a PySpark cluster on Raspberry Pi devices.
We will also go about setting up JupyterLabs on the master node to interact with the cluster.

This is a fantastic way to:

- Learn about PySpark and big data processing
- Get hands-on experience with Linux and distributed systems
- Understand the challenges of running big data workloads on small devices
- Have fun with a unique home project!

Once this has been set up, you will be able to:

- Run PySpark jobs on a cluster of Raspberry Pi devices
- Experiment with big data processing on a small scale
- Learn about the PySpark ecosystem and its capabilities
- Have a mini big data powerhouse at your disposal!

Before we begin, I will not get into the nitty-gritty of setting up the Raspberry Pis, that's something you can get
into. Once you have them running and connected to your home Wi-Fi, you're ready to tackle this tutorial.

### What is the `~/.bashrc` file?

The ~/.bashrc file is a shell script that Bash runs whenever it is started interactively. It's a configuration file for
the Bash shell that allows users to customize their shell environment.
Here are the key points about ~/.bashrc:

- Location: It's typically located in the user's home directory (~/) and is hidden (starts with a dot).
- Purpose: It's used to set up the shell environment, define aliases, functions, and shell options that will be
  available whenever you start a new interactive Bash session.
- Execution: The file is executed every time you open a new terminal or start a new Bash session.
- Applying changes: After editing ~/.bashrc, you need to either start a new shell session or run source ~/.bashrc to
  apply the changes to the current session.

### What is `nano`?

GNU nano is a simple and user-friendly text editor for Unix-like operating systems that can be used from the command
line. Here are the key points about nano:

- It's a small, free and open-source text editor that's part of the GNU Project.
- Nano is designed to be easy to use, especially for beginners. It's less complex than editors like Vim or Emacs.
- It emulates the Pico text editor, which was part of the Pine email client, but adds extra functionality.
- Nano uses keyboard shortcuts for various functions. These are typically displayed at the bottom of the screen for easy
  reference.

## 1. Initial Setup (All Nodes)

1. Update and upgrade all Raspberry Pis:

```shell
sudo apt update && sudo apt upgrade -y
```

This ensures all systems are up-to-date with the latest packages and security updates.

2. Install necessary packages:

```shell
sudo apt install openjdk-17-jdk ufw net-tools python3 python3-pip -y
```

- openjdk-17-jdk: Java Development Kit for running Spark
- ufw: Uncomplicated Firewall for network security
- net-tools: Networking utilities
- python3 and python3-pip: For running PySpark applications

3. Set up static IP addresses:

Edit the dhcpcd.conf file:

```shell
sudo nano /etc/dhcpcd.conf
```

Add the following at the end (adjust IP addresses as needed):

```shell
interface wlan0  # Use eth0 if using Ethernet
static ip_address=<ip address>/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8
```

4. Update hosts file:

```shell
sudo nano /etc/hosts
```

Add entries for all nodes:

```shell
<master ip> master
<worker ip> worker1
# Add more entries as needed
```

6. Set unique names for each host:

```shell
sudo hostnamectl set-hostname master  # For the master node
sudo hostnamectl set-hostname worker1  # For the first worker node
# Repeat for additional nodes
```

5. Reboot to apply changes:

```shell
sudo reboot
```

## 2. SSH Key Authentication Setup (Master Nodes)

1. Generate SSH keys on the master Pi:

```shell
ssh-keygen -t rsa -b 4096
chmod 700 ~/.ssh
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

2. Copy the public key to each worker Pi:

```shell
ssh-copy-id pi@worker1.local
```

Repeat for each worker node.

3. Test the connection:

```shell
ssh pi@worker1.local
```

## 3. Install and Configure Spark (All Nodes)

1. Download and extract Spark:

```shell
wget https://downloads.apache.org/spark/spark-3.5.2/spark-3.5.2-bin-hadoop3.tgz
tar -xzf spark-3.5.2-bin-hadoop3.tgz
sudo mv spark-3.5.2-bin-hadoop3 /opt/spark
rm spark-3.5.2-bin-hadoop3.tgz
```

2. Set up environment variables:

Add to ~/.bashrc:

```shell
echo "export SPARK_HOME=/opt/spark" >> ~/.bashrc
echo "export PATH=\$PATH:\$SPARK_HOME/bin:\$SPARK_HOME/sbin" >> ~/.bashrc
echo "export PYSPARK_PYTHON=/usr/bin/python3" >> ~/.bashrc
source ~/.bashrc
```

3. Configure Spark:

Create and edit /opt/spark/conf/spark-env.sh:

```shell
sudo nano /opt/spark/conf/spark-env.sh
```

Add these lines:

```shell
export SPARK_MASTER_HOST=<master ip>
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
```

4. Create workers file (Master Node Only):

```shell
echo "<worker ip>" | sudo tee /opt/spark/conf/workers
# Add more worker IPs as needed
```

5. Set permissions & Configure spark-defaults.conf:

```shell
sudo chown -R pi:pi /opt/spark
sudo mkdir -p /opt/spark/logs
sudo chown pi:pi /opt/spark/logs
sudo mkdir /tmp/spark-temp
sudo chown pi:pi /tmp/spark-temp

sudo nano /opt/spark/conf/spark-defaults.conf
```

Add these lines:

```shell
spark.master                     spark://<master ip>:7077
spark.driver.host                master
spark.driver.bindAddress         0.0.0.0
spark.executor.memory            768m
spark.driver.memory              1g
spark.driver.port                4040
spark.driver.host                <master ip>
spark.blockManager.port          4041
```

6. Ensure Spark scripts are executable:

```shell
sudo chmod +x /opt/spark/sbin/*
sudo chmod +x /opt/spark/bin/*
```

## 4. Configure Firewall (All Nodes)

1. Set up UFW rules:

```shell
sudo ufw default allow incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 4040
sudo ufw allow 4041
sudo ufw allow 7077
sudo ufw allow 8080
sudo ufw enable
```

Be careful with UFW rules to avoid locking yourself out of the system!
You may need to restart your clusters for the changes to take effect.

## 5. Start Spark Cluster

1. On the master node:

```shell
$SPARK_HOME/sbin/start-master.sh
```

2. On each worker node(s):

```shell
$SPARK_HOME/sbin/start-worker.sh spark://master:7077
```

## 6. Test the Cluster

On the master node, run the Spark Pi example:

```shell
$SPARK_HOME/bin/run-example \
--master spark://<master ip> \
--conf spark.driver.port=4040 \
--conf spark.driver.host=<master ip> \
--conf spark.driver.bindAddress=0.0.0.0 \
--conf spark.blockManager.port=4041 \
--executor-memory 512m \
--total-executor-cores 2 \
SparkPi 10
```

Here's a Python script that you can run on your PySpark cluster:

```shell
nano word_count_test.py
```

Add the script:

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import explode, split, lower, col, count

# Initialize Spark session
spark = SparkSession.builder \
    .appName("JupyterLabSparkTest") \
    .master("spark://master:7077") \
    .config("spark.driver.host", "master") \
    .getOrCreate()

# Sample text (you can replace this with a larger text file for a more comprehensive test)
text = """
PySpark is the Python API for Apache Spark.
It enables you to perform big data processing and machine learning tasks.
Spark is designed for fast computation and can handle large-scale data processing.
This example demonstrates a simple word count using PySpark on a Raspberry Pi cluster.
"""

# Create a DataFrame from the text
df = spark.createDataFrame([(text,)], ["text"])

# Split the text into words, explode the words into rows, and count occurrences
word_counts = df.select(explode(split(lower(col("text")), "\\s+")).alias("word")).groupBy("word").agg(
  count("*").alias("count")).orderBy("count", ascending=False)

# Show the results
print("Word Count Results:")
word_counts.show(20, truncate=False)

# Stop the Spark session
spark.stop()
```

And run it using:

```shell
$SPARK_HOME/bin/spark-submit \
--master spark://192.168.3.52:7077 \
--executor-memory 512m \
--total-executor-cores 2 \
word_count_test.py
```

## 7. Set up JupyterLabs

Start by setting up a venv on your Master Pi.
We do this because the OS comes with Python 2.7 and Python 3.7 pre-installed. We need to create a virtual environment
to install the required packages for JupyterLab and PySpark.

```shell
python3 -m venv ~/spark_jupyter_env
source ~/spark_jupyter_env/bin/activate
```

1. Install JupyterLab:

```shell
pip install jupyterlab
```

2. Install PySpark kernel for Jupyter:

```shell
pip install pyspark
```

3. Configure environment variables:

Add these lines to your ~/.bashrc file:

```shell
echo "export PYSPARK_DRIVER_PYTHON=jupyter'"  >> ~/.bashrc
echo "export PYSPARK_DRIVER_PYTHON_OPTS='lab'" >> ~/.bashrc
echo "export PYSPARK_PYTHON=/usr/bin/python3" >> ~/.bashrc
```

Then, source your .bashrc file:

```shell
source ~/.bashrc
```

4. Start JupyterLab:

You can now start JupyterLab with PySpark integration by running:

```shell
jupyter lab --ip=<master ip> --no-browser --port=8888
```

This command will start JupyterLab and automatically create a SparkSession.

5. Create a new notebook:

In JupyterLab, create a new notebook and select the "PySpark"  or "Python" kernel.

6. Test your Spark connection:

In a notebook cell, you can test your Spark connection with:

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("JupyterLabSparkTest") \
    .master("spark://master:7077") \
    .config("spark.driver.host", "master") \
    .getOrCreate()

print(spark.version)
```

## Troubleshooting

- If you encounter connection issues, ensure all nodes can ping each other by hostname and IP address.
- Check Spark logs in /opt/spark/logs/ on both master and worker nodes for error messages.
- Verify that all necessary ports are open using sudo ufw status.
- Ensure Java version is consistent across all nodes with java -version.

By following these steps, you should have a functioning Spark cluster on your Raspberry Pi devices. Remember to adjust
IP addresses and hostnames according to your specific network configuration.

Enjoy your PySpark cluster and happy big data processing!