FROM jupyter/pyspark-notebook:spark-3.5.1

USER root

# Install Hadoop client and other dependencies
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Download and install Hadoop
RUN curl -O https://downloads.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5.tar.gz \
    && tar xzf hadoop-3.3.5.tar.gz \
    && mv hadoop-3.3.5 /usr/local/hadoop \
    && rm hadoop-3.3.5.tar.gz

# Set Hadoop environment variables
ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

USER $NB_UID

# Install additional Python packages
RUN pip install hdfs pyspark==3.3.5 findspark
