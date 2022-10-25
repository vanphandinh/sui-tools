# Tools for automatically monitoring the Sui network and upgrading the latest Sui docker image and important files
- Watchtower in `docker-compose.yml`: detect and upgrade the Sui container if a new Sui image is available.
- `monitor.sh`: notify the Sui network states.
- `updater.sh`: detect, download new `genesis.blob` & `fullnode-template.yaml` file and upgrade the Sui container if they are updated

## How to use
1. Clone this repo.
2. Copy all files to your Sui folder, that overrides your `docker-compose.yml` file. Refer to https://github.com/MystenLabs/sui/tree/main/docker/fullnode
3. Run your fullnode as normal with the new `docker-compose.yml`.
4. Add your TELEGRAM_BOT_TOKEN & CHAT_ID to `monitor.sh` and `updater.sh`.
5. Run `chmod +x monitor.sh && chmod +x updater.sh`.
6. Run `monitor.sh` and `updater.sh` in 2 sessions of `screen`. Refer to https://linuxize.com/post/how-to-use-linux-screen/
