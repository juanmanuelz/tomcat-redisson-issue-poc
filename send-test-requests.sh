#!/bin/bash

# This script is designed to interact with a local server to check and set control flags.
# It performs a series of operations to ensure that the control flag remains consistent across multiple requests.
# The script logs in to a local server, sets a control flag, and then repeatedly checks the control flag,
# updating it at regular intervals.

# Function: check_control_flag
# This function checks the current control flag on the server against an expected value.
# Arguments:
#   $1 - Expected control flag value.
#   $2 - Current repetition count or identifier.
# Behavior:
#   Makes a request to the server and compares the response to the expected control flag value.
#   If the response doesn't match the expected value, the script exits with a message and code 123.
check_control_flag(){
    CURL_RESPONSE=$(curl -s -L 'http://localhost:3000/?x='$2 -b $COOKIE_JAR_FILE | tr -d '\n')
    if [ "$1" != "$CURL_RESPONSE" ]; then 
        echo "Exit at $2 repetitions and response $1 != $CURL_RESPONSE. Unexpected control flag" 
        exit 123
    fi 
}

# Function: set_control_flag
# This function sets a new control flag on the server.
# Arguments:
#   $1 - New control flag value to set.
# Behavior:
#   Sends a request to the server to update the control flag to the specified value.
set_control_flag(){
    echo "Setting a new control flag: $1. The process will fail if any of the nodes return a different value."
    curl -s -L 'http://localhost:3000/?controlFlag='$1 -b $COOKIE_JAR_FILE > /dev/null
}

# Main Script Execution:

# Set the default control flag value or use the existing one if provided.
CONTROL_FLAG=${CONTROL_FLAG:-ctrlflg}

# Define the cookie jar file location used for maintaining session.
COOKIE_JAR_FILE=/tmp/${CONTROL_FLAG}-test.cookie-jar

# Remove the cookie jar file if it already exists to start fresh.
rm $COOKIE_JAR_FILE || true

# Login to the server to start the session and store the cookies.
# copied from firefox UI :D
curl 'http://localhost:3000/login' -X POST  --cookie-jar $COOKIE_JAR_FILE -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost:3000' -H 'Connection: keep-alive' -H 'Referer: http://localhost:3000/login' -H 'Cookie: JSESSIONID=89D0F51CD8BD4DB5BC3103C8E8337FC2' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' --data-raw 'username=admin&password=admin123' -vv

# Set the initial control flag on the server.
set_control_flag $CONTROL_FLAG

# Loop through a set number of times to check and occasionally update the control flag.
for i in {1..100000}
do
  # Check the current control flag against the expected value.
  check_control_flag $CONTROL_FLAG $i
 
  # Every 777 iterations, update the control flag to the current iteration number.
  if [ $((i % 777)) -eq 0 ]; then
    CONTROL_FLAG="$i"
    set_control_flag $CONTROL_FLAG    
  fi
done

# End of script
