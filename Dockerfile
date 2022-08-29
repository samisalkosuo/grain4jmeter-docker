FROM rockylinux:8.6

WORKDIR /grain4jmeter

#Keep Package List Updated
#RUN dnf -y update 
RUN dnf -y install wget curl ca-certificates  fontconfig  java-1.8.0-openjdk-devel

#======START Grafana======

ENV GF_SERVER_ROOT_URL http://localhost:3000

RUN wget https://dl.grafana.com/oss/release/grafana-6.0.2.linux-amd64.tar.gz
RUN tar -zxvf grafana-6.0.2.linux-amd64.tar.gz
#RUN wget https://dl.grafana.com/oss/release/grafana_6.0.2_amd64.deb && \
#    dpkg -i grafana_6.0.2_amd64.deb

#======END Grafana======

#======START InfluxDB======

ENV	INFLUXDB_URL http://localhost:8086

ENV	INFLUXDB_DATA_USER root
ENV	INFLUXDB_DATA_PW root
ENV	INFLUXDB_GRAFANA_USER root
ENV	INFLUXDB_GRAFANA_PW root
ENV	ROOT_PW root
ENV CONFIG_FILE="/etc/influxdb/influxdb.conf"
ENV API_URL="http://localhost:8086"

RUN wget https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10.x86_64.rpm
RUN dnf -y install influxdb-1.8.10.x86_64.rpm
#RUN wget https://dl.influxdata.com/influxdb/releases/influxdb_1.3.5_amd64.deb && \
#    dpkg -i influxdb_1.3.5_amd64.deb

ENV INFLUXDB_META_DIR=/var/lib/influxdb/meta \
    INFLUXDB_DATA_DIR=/var/lib/influxdb/data \
    INFLUXDB_DATA_WAL_DIR=/var/lib/influxdb/wal \
    INFLUXDB_HINTED_HANDOFF_DIR=/var/lib/influxdb/hh

COPY influxdb/influxdb.conf /etc/influxdb/influxdb.conf

#======END InfluxDB======

#======START Jmeter======

RUN wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.5.tgz && \
    tar -xf apache-jmeter-5.5.tgz
ENV PATH /grain4jmeter/apache-jmeter-5.5/bin:$PATH
COPY ./jmeter ./jmeter


#======END Jmeter======

COPY grafana/create_datasource.json .
COPY grafana/jmeter_dashboard.json .

COPY scripts/*.sh .
RUN chmod 755 *.sh

#Exposing influxdb port for jmeter
EXPOSE 2003
#Exposing grafana port
EXPOSE 3000

CMD ./start_grain4jmeter.sh ; /bin/bash
