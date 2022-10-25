#!/bin/bash
export TZ=Asia/Ho_Chi_Minh #TIMEZONE
TELEGRAM_BOT_TOKEN="55555555555:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" #YOUR TELEGRAM BOT TOKEN, CREATED VIA @BotFather
CHAT_ID="YYYYYYYY" #DESTINATION TO RECEIVE NOTIFICATIONS

notify() {
  msg=$1 
  curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" -d "chat_id=$CHAT_ID&parse_mode=html&text=$msg" &> /dev/null
}
mkdir -p updates

echo 'Sui Updater v0.1'

while :
do
  NOW=$(date +'%d/%m/%Y %T')
  
  echo "$NOW - Checking genesis.blob.."
  wget -q https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob -O ./updates/genesis.blob 
  RETURN_CODE=$?
  if [ $RETURN_CODE -ne 0 ]; then
    echo "Download genesis.blob failed"
  else
    md5f1=$(md5sum "./updates/genesis.blob" | cut -d' ' -f1) 
    md5f2=$(md5sum "genesis.blob" | cut -d' ' -f1)
    if [ "$md5f2" != "$md5f1" ]; then
     cp ./updates/genesis.blob genesis.blob
     docker compose down --volumes
     docker compose up -d
     notify "<code>$NOW</code>"$'\n'"New genesis.blob updated"
     echo "New genesis.blob updated"
    else
     echo "No change"
    fi
  fi

  echo "$NOW - Checking fullnode-template.yaml.."
  wget -q https://github.com/MystenLabs/sui/raw/main/crates/sui-config/data/fullnode-template.yaml -O ./updates/fullnode-template.yaml
  RETURN_CODE=$?
  if [ $RETURN_CODE -ne 0 ]; then
    echo "Download fullnode-template.yaml failed"
  else
    md5f2=$(md5sum "fullnode-template.yaml" | cut -d' ' -f1)
    md5f1=$(md5sum "./updates/fullnode-template.yaml" | cut -d' ' -f1) 
    if [ "$md5f2" != "$md5f1" ]; then
     cp ./updates/fullnode-template.yaml fullnode-template.yaml
     docker restart sui
     notify "<code>$NOW</code>"$'\n'"New fullnode-template.yaml updated"
     echo "New fullnode-template.yaml updated"
    else
     echo "No change"
    fi
  fi

  sleep 60s
done

