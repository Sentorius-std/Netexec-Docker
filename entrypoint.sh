#!/bin/bash


# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color



mkdir -p /data

#Here we saved both json format and log one 
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="/output/scan_${TIMESTAMP}.log"
JSON_FILE="/output/scan_${TIMESTAMP}.json"

if [ "$#" -eq 0 ]; then
    echo '{"result":"error","reason":"no arguments"}' > "$JSON_FILE"
    exit 1
fi

echo -e "${BLUE}[*]${NC} Running NetExec with arguments: $@" | tee "$LOG_FILE"

# Running and capturing NetExec output
OUTPUT=$(netexec "$@" 2>&1)
STATUS=$?

echo "$OUTPUT" | tee -a "$LOG_FILE"

# If tool crashed or something goes wrong
if [ $STATUS -ne 0 ]; then
    echo "{\"result\":\"error\",\"exit_code\":$STATUS}" > "$JSON_FILE"
    exit 4
fi


# --- PARSING PART ---

#echo "$OUTPUT" | 
PROTO=""
IP=""
HOST=""
PWNED="false"
CREDS=""


# If NetExec produced Empty output (Same times if port is closed or the machine is off, netexec return nothing)
if [ -z "$OUTPUT" ]; then
cat <<EOF > "$JSON_FILE"
{
  "response": "Error",
  "reason": "empty_output"
}
EOF
    exit 4
fi

# This is Why it took some times, parsing the output to simulate a bit auditguard format (Look Like json)
while read -r line; do
    # Detect host info line
    echo "$line" >> $LOG_FILE
    if echo "$line" | grep -q "(name:"; then
        PROTO=$(echo "$line" | awk '{print $1}')
        IP=$(echo "$line" | awk '{print $2}')
        HOST=$(echo "$line" | grep -oP '(?<=name:)[^)]*')
    fi

    # Detect compromise line
    if echo "$line" | grep -q "Pwn3d!"; then
        PWNED="true"
        CREDS=$(echo "$line" | grep -oP '\S+:\S+(?= \(Pwn3d!\))')
    fi
    
    # Detect successful auth line
    case "$line" in
       *"[+]"*)
        PWNED="Partial"
        CREDS=$(echo "$line" | awk -F '\[\+\] ' '{print $2}')
        ;;
    esac
done <<< "$OUTPUT"



# Finally Buildibg single JSON object
cat <<EOF > "$JSON_FILE"
{
  "protocol": "$PROTO",
  "ip": "$IP",
  "hostname": "$HOST",
  "compromised": $PWNED,
  "creds": "$CREDS"
}
EOF


exit 0
