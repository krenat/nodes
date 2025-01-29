#!/bin/bash

# Колір тексту
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # Нема кольору (скидання)

#Оновлення системи
echo -e "${BLUE}Оновлення системи.${NC}"
sudo apt update
#sudo apt upgrade -y
echo -e "${GREEN}Систему оновлено.${NC}"

#Інсталювання python
echo -e "${BLUE}Інсталювання python${NC}"
sudo apt install -y python3-pip python3-dev python3-venv curl git
echo -e "${GREEN}Python встановлено.${NC}"

#Налаштування python
python3 -m venv venv
source venv/bin/activate
pip3 install aiohttp
echo -e "${GREEN}Python налаштовано.${NC}"

#Інсталювання gaianet
echo -e "${BLUE}Інсталювання gaianet${NC}"
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash
source ~/.bashrc
echo -e "${BLUE}Gaianet інстальовано.${NC}"

#Налаштування gaianet
gaianet init --config https://raw.gaianet.ai/qwen-1.5-0.5b-chat/config.json

#Запуск gaianet
gaianet start
gaianet info
