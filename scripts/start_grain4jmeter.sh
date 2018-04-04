echo "Starting InfluxDB and Grafana..."

influxd -config=/etc/influxdb/influxdb.conf > influx.log 2> influx_error.log &
service grafana-server start
echo "Waiting 3 seconds to make sure grafana starts.."
sleep 3

echo "Creating data source..."
curl -H "Content-Type: application/json" --data-binary "@create_datasource.json" http://admin:admin@127.0.0.1:3000/api/datasources
echo
echo "Creating dashboard..."
curl -H "Content-Type: application/json" --data-binary "@jmeter_dashboard.json" http://admin:admin@127.0.0.1:3000/api/dashboards/db > dashboard.json 2> /dev/null
cat dashboard.json
#extract url from json, from stackoverflow https://stackoverflow.com/questions/1955505/parsing-json-with-unix-tools
__dashboard_url=$(cat dashboard.json | sed -e 's/[{}]/''/g' | awk -v RS=',"' -F: '/^url/ {print $2}' | sed -e 's/\"//g')
echo
echo "InfluxDB and Grafana started in the background."
echo
echo "JMeter config, see here: http://jmeter.apache.org/usermanual/realtime-results.html."
echo
echo "Grafana JMeter dashboard: http://127.0.0.1:3000${__dashboard_url}"
echo "User/password: admin/admin"
echo
echo "When you stop this container all data is lost."
