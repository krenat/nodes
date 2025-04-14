#!/bin/bash

# Кольори
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Запит імені контейнера
read -p "Введи індекс контейнера dria: " INDEX
CONTAINER_NAME="dria$INDEX"

echo " Виберіть етап встановлення:"
echo "1) Налаштування контейнера"
echo "2) Встановлення DRIA"
echo "3) Налаштування DRIA (env)"
read -p "➡️ Введіть номер або назву етапу: " STAGE


# Перевірка, чи введено ім'я
if [ -z "$CONTAINER_NAME" ]; then
    echo -e "${RED}Ім'я контейнера не може бути порожнім.${NC}"
    exit 1
fi


if [[ "$STAGE" == "1" ]]; then
  # Створити контейнер у фоні, якщо ще не існує
  docker container inspect "$CONTAINER_NAME" > /dev/null 2>&1
  if [ $? -ne 0 ]; then
      echo -e "${BLUE}Створюємо новий контейнер '$CONTAINER_NAME'...${NC}"
      docker run -dit --name "$CONTAINER_NAME" ubuntu:22.04 >/dev/null 2>&1
  else
      echo -e "${BLUE}Контейнер '$CONTAINER_NAME' вже існує.${NC}"
      exit 1
  fi
  
  # Встановлення залежностей та запуск скриптів
  echo -e "${BLUE}Встановлюємо залежності та запускаємо інсталяційні скрипти...${NC}"

  docker exec -it "$CONTAINER_NAME" bash -c "
    cd && \
    apt update >/dev/null
  "
  
  docker exec -it "$CONTAINER_NAME" bash -c '
    echo -e "${BLUE}Встановлення залежностей у контейнері...${NC}"

    PACKAGES=(curl git make jq build-essential gcc unzip wget lz4 aria2 tmux)
    TOTAL=${#PACKAGES[@]}
    CURRENT=0
    BAR_WIDTH=40
  
    draw_progress() {
      local progress=$1
      local done=$((progress * BAR_WIDTH / TOTAL))
      local left=$((BAR_WIDTH - done))
      local fill
      fill=$(printf "%${done}s")
      local empty
      empty=$(printf "%${left}s")
      printf "\r[%s%s] %d/%d" "${fill// /#}" "${empty// /-}" "$progress" "$TOTAL"
    }
  
    apt update -qq >/dev/null 2>&1
  
    for pkg in "${PACKAGES[@]}"; do
      apt install -y -qq "$pkg" >/dev/null 2>&1
      ((CURRENT++))
      draw_progress "$CURRENT"
    done
  
    echo -e "${GREEN}\n✅ Усі залежності встановлено у контейнері${NC}"
  '
  
  
  STAGE="2"
fi

if [[ "$STAGE" == "2" ]]; then
  
  docker exec "$CONTAINER_NAME" bash -c '
    INSTALL_OUTPUT=$(curl -fsSL https://dria.co/launcher | bash 2>&1)

    if echo "$INSTALL_OUTPUT" | grep -qi "failed\|error"; then
      echo -e "${RED}❌ Помилка: не вдалося отримати останню версію DRIA${NC}"
      exit 1
    else
      echo -e "${GREEN}✅ DRIA launcher встановлено успішно${NC}"
    fi
  '
  
  
  if [[ $? -ne 0 ]]; then
    exit 1
  fi
  
  
#  docker exec -it "$CONTAINER_NAME" bash -c "
#    curl -fsSL https://ollama.com/install.sh | sh
#  "
  
  STAGE="3"
fi

if [[ "$STAGE" == "3" ]]; then
  # Отримуємо дані з файлу dria_wallets
  WALLET_SECRET=$(jq -r ".[] | select(.index == $INDEX) | .wallet" dria_wallets.json)
  GEMINI_API_KEY=$(jq -r ".[] | select(.index == $INDEX) | .api" dria_wallets.json)
  
  if [[ -z "$WALLET_SECRET" ]]; then
    echo -e "${RED}❌ Не знайдено wallet для індексу $INDEX${NC}"
    exit 1
  fi
  
  echo -e "${BLUE}Створення файлу .env ${NC}"
  docker exec "$CONTAINER_NAME" mkdir -p /root/.dria/dkn-compute-launcher

cat > .env <<EOF
## DRIA ##
DKN_WALLET_SECRET_KEY=$WALLET_SECRET
DKN_MODELS=gemini-1.5-flash,gemini-1.5-pro,gemini-2.0-flash
DKN_P2P_LISTEN_ADDR=/ip4/0.0.0.0/tcp/4001
DKN_RELAY_NODES=
DKN_BOOTSTRAP_NODES=
DKN_BATCH_SIZE=

## Ollama (if used, optional) ##
OLLAMA_HOST=http://127.0.0.1
OLLAMA_PORT=11434
OLLAMA_AUTO_PULL=true

## Open AI (if used, required) ##
OPENAI_API_KEY=
## Gemini (if used, required) ##
GEMINI_API_KEY=$GEMINI_API_KEY
## Open Router (if used, required) ##
OPENROUTER_API_KEY=
## Serper (optional) ##
SERPER_API_KEY=
## Jina (optional) ##
JINA_API_KEY=

## Log levels
RUST_LOG=none
EOF
  
  docker cp .env "$CONTAINER_NAME":/root/.dria/dkn-compute-launcher/.env

  echo -e "${GREEN}✅ .env для $CONTAINER_NAME створено з wallet $WALLET_SECRET${NC}"
  
  
  # Запуск tmux-сесії 'dria' і запуск dkn-compute-launcher всередині
  echo -e "${BLUE}Запускаємо tmux-сесію 'dria' з dkn-compute-launcher...${NC}"
  
  docker exec -it "$CONTAINER_NAME" tmux new -s dria 
fi
