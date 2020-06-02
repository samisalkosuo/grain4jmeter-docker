#!/bin/bash

[ -z "$1" ] && echo "URL missing." && exit 1

echo $1 | grep -E http[s]?:// &> /dev/null
rv=$?
if [ $rv -ne 0 ]; then
    echo ERROR: URL does not include protocol. http or https must be present.
    exit 1
fi

#from https://stackoverflow.com/questions/6174220/parse-url-in-shell-script
# extract protocol, host, port and context path from given URL.
# extract the protocol
proto="$(echo $1 | grep :// | sed -e's,^\(.*://\).*,\1,g' | sed -e's,://,,g')"
# remove the protocol
url="$(echo ${1/$proto:\/\//})"
# extract the user (if any)
user="$(echo $url | grep @ | cut -d@ -f1)"
# extract the host and port
hostport="$(echo ${url/$user@/} | cut -d/ -f1)"
# by request host without port
host="$(echo $hostport | sed -e 's,:.*,,g')"

#check port
echo $hostport | grep : &> /dev/null
rv=$?
if [ $rv -ne 0 ]; then
#    echo no port in URL
    if [[ "${proto}" == "http" ]] ; then
        port=80
    fi
    if [[ "${proto}" == "https" ]] ; then
        port=443
    fi
else
  port="$(echo $hostport | sed  -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"
fi
# extract the path (if any)
path=/"$(echo $url | grep / | cut -d/ -f2-)"

#echo "url: $url"
#echo "  proto: $proto"
#echo "  user: $user"
#echo "  host: $host"
#echo "  port: $port"
#echo "  path: $path"


PROTOCOL=$proto
HOST=$host
PORT=$port
CONTEXT_PATH=$path

[ -z "$THREADS" ] && echo "THREADS env var missing. Using default 10." && THREADS=10
__default_host=$(/sbin/ip route|awk '/default/ { print $3 }')
[ -z "$GRAPHITE_HOST" ] && echo "GRAPHITE_HOST env var missing. Using default ${__default_host}." && GRAPHITE_HOST=${__default_host}
[ -z "$GRAPHITE_PORT" ] && echo "GRAPHITE_PORT env var missing. Using default 2003." && GRAPHITE_PORT=2003


sed -i 's@%PROTOCOL%@'"$PROTOCOL"'@' sample_jmeter_test_template.jmx
sed -i 's@%HOST%@'"$HOST"'@' sample_jmeter_test_template.jmx
sed -i 's@%PORT%@'"$PORT"'@' sample_jmeter_test_template.jmx
sed -i 's@%CONTEXT_PATH%@'"$CONTEXT_PATH"'@' sample_jmeter_test_template.jmx
sed -i 's@%THREADS%@'"$THREADS"'@' sample_jmeter_test_template.jmx
sed -i 's@%GRAPHITE_HOST%@'"$GRAPHITE_HOST"'@' sample_jmeter_test_template.jmx
sed -i 's@%GRAPHITE_PORT%@'"$GRAPHITE_PORT"'@' sample_jmeter_test_template.jmx

#entrypoint.sh executes jmeter as in base image
/entrypoint.sh -n -t sample_jmeter_test_template.jmx
