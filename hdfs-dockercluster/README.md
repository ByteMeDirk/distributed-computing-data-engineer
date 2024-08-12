Certainly! I'll create a README file based on your successful HDFS setup using Docker Compose. This README will guide
others through replicating your configuration.

# HDFS Cluster Setup with Docker Compose

This project demonstrates how to set up a Hadoop Distributed File System (HDFS) cluster using Docker Compose. It's
designed for learning and experimentation with HDFS on a small scale.

## Prerequisites

- Docker and Docker Compose installed on your system
- Basic understanding of HDFS and Docker concepts

## Project Structure

```
hdfs-docker-cluster/
│
├── docker-compose.yml
├── hadoop_config/
│   ├── core-site.xml
│   ├── hdfs-site.xml
│   └── ... (other Hadoop configuration files)
├── start-hdfs.sh
├── init-datanode.sh
├── hadoop_namenode/
├── hadoop_datanode1/
└── hadoop_datanode2/
```

## Setup Instructions

1. **Clone the Repository**
   ```
   git clone [your-repository-url]
   cd hdfs-docker-cluster
   ```

2. **Prepare Configuration Files**
    - Place your Hadoop configuration files in the `hadoop_config/` directory.
    - Ensure `core-site.xml` and `hdfs-site.xml` are properly configured.

3. **Create Initialization Scripts**
    - Create `start-hdfs.sh` for the NameNode:
      ```bash
      #!/bin/bash
      if [ ! -d "/opt/hadoop/data/nameNode/current" ]; then
          echo "Formatting NameNode..."
          hdfs namenode -format
      fi
      hdfs namenode
      ```
    - Create `init-datanode.sh` for DataNodes:
      ```bash
      #!/bin/bash
      rm -rf /opt/hadoop/data/dataNode/*
      chown -R hadoop:hadoop /opt/hadoop/data/dataNode
      chmod 755 /opt/hadoop/data/dataNode
      hdfs datanode
      ```
    - Make these scripts executable:
      ```
      chmod +x start-hdfs.sh init-datanode.sh
      ```

4. **Start the HDFS Cluster**
   ```
   docker-compose up -d
   ```

5. **Verify the Cluster**
    - Access the NameNode web interface: `http://localhost:9870`
    - Check the status of DataNodes in the web interface

## Usage

- To interact with HDFS, use the `hdfs dfs` commands through the NameNode container:
  ```
  docker exec -it namenode hdfs dfs -ls /
  ```

- To add files to HDFS:
  ```
  echo 'Hello, HDFS' > test.txt
  docker cp test.txt namenode:/tmp/
  docker exec -it namenode hdfs dfs -put /tmp/test.txt /
  ```

- To view files in HDFS:
  ```
  docker exec -it namenode hdfs dfs -cat /test.txt
  ```

## Troubleshooting

- If containers fail to start, check the logs:
  ```
  docker-compose logs
  ```
- Ensure all configuration files are correctly set up in the `hadoop_config/` directory.
- Verify that the initialization scripts have the correct permissions and are executable.

## Limitations

- This setup is for learning and experimentation purposes only.
- It's not suitable for production environments or handling large-scale data.
