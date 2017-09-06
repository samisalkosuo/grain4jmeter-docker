FROM ubuntu:14.04

WORKDIR /grain4jmeter

#Keep Package List Updated & software upgraded
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y --no-install-recommends wget curl ca-certificates apt-transport-https

#======START InfluxDB======

ENV	INFLUXDB_URL http://localhost:8086

ENV	INFLUXDB_DATA_USER root
ENV	INFLUXDB_DATA_PW root
ENV	INFLUXDB_GRAFANA_USER root
ENV	INFLUXDB_GRAFANA_PW root
ENV	ROOT_PW root
ENV CONFIG_FILE="/etc/influxdb/influxdb.conf"
ENV API_URL="http://localhost:8086"

RUN wget https://dl.influxdata.com/influxdb/releases/influxdb_1.3.5_amd64.deb
RUN sudo dpkg -i influxdb_1.3.5_amd64.deb

ENV INFLUXDB_META_DIR=/var/lib/influxdb/meta \
    INFLUXDB_DATA_DIR=/var/lib/influxdb/data \
    INFLUXDB_DATA_WAL_DIR=/var/lib/influxdb/wal \
    INFLUXDB_HINTED_HANDOFF_DIR=/var/lib/influxdb/hh

#VOLUME ["/var/lib/influxdb"]

COPY influxdb/influxdb.conf /etc/influxdb/influxdb.conf

#======END InfluxDB======

#======START Grafana======
ENV GF_SERVER_ROOT_URL http://localhost:3000

RUN wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_4.4.3_amd64.deb
RUN sudo apt-get install -y adduser libfontconfig
RUN sudo dpkg -i grafana_4.4.3_amd64.deb
RUN sudo update-rc.d grafana-server defaults 95 10

#======END Grafana======

COPY grafana/create_datasource.json .
COPY grafana/jmeter_dashboard.json .

COPY start_grain4jmeter.sh .
RUN chmod 755 start_grain4jmeter.sh

#Exposing influxdb port for jmeter
EXPOSE 2003
#Exposing grafana port
EXPOSE 3000

CMD ./start_grain4jmeter.sh ; /bin/bash
