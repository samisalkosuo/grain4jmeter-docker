echo "Starting InfluxDB and Grafana..."

set -e 

#start InfluxDB
influxd -config=/etc/influxdb/influxdb.conf > influx.log 2> influx_error.log &

GRAFANA_PASSWORD=passw0rd
#create Grafana start script and start Grafana
export LOCAL_DIR=$(pwd)
cat > ./start_grafana.sh << EOF
cd /grain4jmeter/grafana-6.0.2/bin
#reset admin password
./grafana-cli admin reset-admin-password $GRAFANA_PASSWORD > $LOCAL_DIR/grafana.log 2> $LOCAL_DIR/grafana_error.log
./grafana-server > $LOCAL_DIR/grafana.log 2> $LOCAL_DIR/grafana_error.log
EOF
sh ./start_grafana.sh & 

echo "Waiting 3 seconds to make sure grafana starts.."
sleep 3

echo "Creating data source..."
curl -H "Content-Type: application/json" --data-binary "@create_datasource.json" http://admin:$GRAFANA_PASSWORD@127.0.0.1:3000/api/datasources
echo
echo "Creating dashboard..."
curl -H "Content-Type: application/json" --data-binary "@jmeter_dashboard.json" http://admin:$GRAFANA_PASSWORD@127.0.0.1:3000/api/dashboards/db > dashboard.json 2> /dev/null
#extract url from json, from stackoverflow https://stackoverflow.com/questions/1955505/parsing-json-with-unix-tools
__dashboard_url=$(cat dashboard.json | sed -e 's/[{}]/''/g' | awk -v RS=',"' -F: '/^url/ {print $2}' | sed -e 's/\"//g')

echo
echo "InfluxDB and Grafana started in the background."
echo "JMeter installed."
echo
echo "To execute simple JMeter test plan:"
echo "./run-jmeter-test.sh <URL>"
echo
echo "For more JMeter config, see here: http://jmeter.apache.org/usermanual/realtime-results.html."
echo
echo "Grafana JMeter dashboard: http://127.0.0.1:3000${__dashboard_url}"
echo "User/password: admin/passw0rd"
echo
echo "When you stop this container all data is lost."
