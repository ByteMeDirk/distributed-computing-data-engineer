FROM apache/spark:3.4.3

USER root

RUN apt-get update && apt-get install -y python3 python3-pip

COPY requirements.txt .
COPY spark_job.py /opt/spark/work-dir/
RUN pip3 install -r requirements.txt

USER spark