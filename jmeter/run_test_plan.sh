#!/bin/bash

function missing_env()
{
    echo "$1 environment variable missing."
    touch not_set
}

set –f

[ -z "$PROTOCOL" ] && missing_env PROTOCOL
[ -z "$HOST" ] && missing_env HOST
[ -z "$PORT" ] && missing_env PORT
[ -z "$CONTEXT_PATH" ] && echo "CONTEXT_PATH env var missing. Using default /." && CONTEXT_PATH="/"
[ -z "$THREADS" ] && echo "THREADS env var missing. Using default 10." && THREADS=10
__default_host=$(/sbin/ip route|awk '/default/ { print $3 }')
[ -z "$GRAPHITE_HOST" ] && echo "GRAPHITE_HOST env var missing. Using default ${__default_host}." && GRAPHITE_HOST=${__default_host}
[ -z "$GRAPHITE_PORT" ] && echo "GRAPHITE_PORT env var missing. Using default 2003." && GRAPHITE_PORT=2003

set +f

if [ -f not_set ]; then
    echo "One or more environment variables missing."
    exit 1
fi

sed -i 's@%PROTOCOL%@'"$PROTOCOL"'@' sample_jmeter_test_template.jmx
sed -i 's@%HOST%@'"$HOST"'@' sample_jmeter_test_template.jmx
sed -i 's@%PORT%@'"$PORT"'@' sample_jmeter_test_template.jmx
sed -i 's@%CONTEXT_PATH%@'"$CONTEXT_PATH"'@' sample_jmeter_test_template.jmx
sed -i 's@%THREADS%@'"$THREADS"'@' sample_jmeter_test_template.jmx
sed -i 's@%GRAPHITE_HOST%@'"$GRAPHITE_HOST"'@' sample_jmeter_test_template.jmx
sed -i 's@%GRAPHITE_PORT%@'"$GRAPHITE_PORT"'@' sample_jmeter_test_template.jmx

#entrypoint.sh executes jmeter as in base image
/entrypoint.sh -n -t sample_jmeter_test_template.jmx
