
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

PROTOCOL=$proto
HOST=$host
PORT=$port
CONTEXT_PATH=$path

__default_host="127.0.0.1"

[ -z "$THREADS" ] && echo "THREADS env var missing. Using default 10." && THREADS=10
[ -z "$GRAPHITE_HOST" ] && echo "GRAPHITE_HOST env var missing. Using default ${__default_host}." && GRAPHITE_HOST=${__default_host}
[ -z "$GRAPHITE_PORT" ] && echo "GRAPHITE_PORT env var missing. Using default 2003." && GRAPHITE_PORT=2003


TEST_PLAN_TEMPLATE=jmeter/jmeter_test_plan.jmx
TEST_PLAN=test_plan.jmx
cp $TEST_PLAN_TEMPLATE $TEST_PLAN

sed -i 's@%PROTOCOL%@'"$PROTOCOL"'@' $TEST_PLAN
sed -i 's@%HOST%@'"$HOST"'@' $TEST_PLAN
sed -i 's@%PORT%@'"$PORT"'@' $TEST_PLAN
sed -i 's@%CONTEXT_PATH%@'"$CONTEXT_PATH"'@' $TEST_PLAN
sed -i 's@%THREADS%@'"$THREADS"'@' $TEST_PLAN
sed -i 's@%GRAPHITE_HOST%@'"$GRAPHITE_HOST"'@' $TEST_PLAN
sed -i 's@%GRAPHITE_PORT%@'"$GRAPHITE_PORT"'@' $TEST_PLAN

jmeter -n -t $TEST_PLAN



# function usage
# {
#     echo "$0 <protocol http or https> <host FQDN/IP> <port>"
#     exit 1
# }

# if [ "$1" == "" ]; then
#     echo "Protocol is missing."
#     usage
# fi

# if [ "$2" == "" ]; then
#     echo "Host is missing."
#     usage
# fi

# if [ "$3" == "" ]; then
#     echo "Port is missing."
#     usage
# fi

# PROTOCOL=$1
# HOST=$2
# PORT=$3
# CONTEXT_PATH=/
# THREADS=10
# GRAPHITE_HOST=127.0.0.1
# GRAPHITE_PORT=2003
# TEST_PLAN=jmeter/jmeter_test_plan.jmx

# sed -i 's@%PROTOCOL%@'"$PROTOCOL"'@' $TEST_PLAN
# sed -i 's@%HOST%@'"$HOST"'@' $TEST_PLAN
# sed -i 's@%PORT%@'"$PORT"'@' $TEST_PLAN
# sed -i 's@%CONTEXT_PATH%@'"$CONTEXT_PATH"'@' $TEST_PLAN
# sed -i 's@%THREADS%@'"$THREADS"'@' $TEST_PLAN
# sed -i 's@%GRAPHITE_HOST%@'"$GRAPHITE_HOST"'@' $TEST_PLAN
# sed -i 's@%GRAPHITE_PORT%@'"$GRAPHITE_PORT"'@' $TEST_PLAN

# jmeter -n -t sample_jmeter_test_template.jmx
