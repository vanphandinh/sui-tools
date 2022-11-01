#!/bin/bash
export TZ=Asia/Ho_Chi_Minh #TIMEZONE
TELEGRAM_BOT_TOKEN="55555555555:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" #YOUR TELEGRAM BOT TOKEN, CREATED VIA @BotFather
CHAT_ID="YYYYYYYY" #DESTINATION TO RECEIVE NOTIFICATIONS

TOTAL_TXS=$(curl --location --max-time 180 -s -X POST 'http://127.0.0.1:9000' -H 'Content-Type: application/json' --data-raw '{ "jsonrpc":"2.0", "id":1, "method":"sui_getTotalTransactionNumber", "params":[] }' | jq '.result')
API_STUCK=0
TX_STUCK=0
NOW=$(date +'%d/%m/%Y %T')
CONTAINER_STARTED_AT=$(docker inspect -f '{{ .State.StartedAt }}' sui)
CONTAINER_TIMESTAMP=$(date -d "$CONTAINER_STARTED_AT" +%s)
echo 'Sui Monitor Script v0.1'
echo "$NOW - Current Txs: $TOTAL_TXS"

notify() {
  msg=$1 
  curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" -d "chat_id=$CHAT_ID&parse_mode=html&text=$msg" &> /dev/null
}

while :
do
  sleep 60s
  LATEST_TOTAL_TXS=$(curl --location --max-time 180 -s -X POST 'http://127.0.0.1:9000' -H 'Content-Type: application/json' --data-raw '{ "jsonrpc":"2.0", "id":1, "method":"sui_getTotalTransactionNumber", "params":[] }' | jq '.result')
  CONTAINER_STARTED_AT=$(docker inspect -f '{{ .State.StartedAt }}' sui)
  LATEST_CONTAINER_TIMESTAMP=$(date -d "$CONTAINER_STARTED_AT" +%s)
  NOW=$(date +'%d/%m/%Y %T')

  if [ "$LATEST_TOTAL_TXS" == "null" ]; then
    if [ "$API_STUCK" -gt "2" ]; then
       API_STUCK=0
       notify "<code>$NOW</code>"$'\n'"The API is stuck. Restarting node.."
       echo "$NOW - The API is stuck. Restarting node.."
       docker restart sui
    else
       ((API_STUCK++))
       notify "<code>$NOW</code>"$'\n'"The API got nothing"
       echo "$NOW - The API got nothing"
    fi
    continue
  fi

  if [ "$CONTAINER_TIMESTAMP" -lt "$LATEST_CONTAINER_TIMESTAMP" ]; then
    TOTAL_TXS=$LATEST_TOTAL_TXS
    CONTAINER_TIMESTAMP=$LATEST_CONTAINER_TIMESTAMP
  fi

  if [ "$LATEST_TOTAL_TXS" -gt "$TOTAL_TXS" ]; then
    TOTAL_TXS=$LATEST_TOTAL_TXS
    TX_STUCK=0
    notify "<code>$NOW</code>"$'\n'"Current Txs: $TOTAL_TXS"
    echo "$NOW - Current Txs: $TOTAL_TXS"
  else
    ((TX_STUCK++))
    notify "<code>$NOW</code>"$'\n'"Got stuck $TX_STUCK times at TX: $TOTAL_TXS"
    echo "$NOW - Got stuck $TX_STUCK times at TX: $TOTAL_TXS, notifying.."
  fi
done
