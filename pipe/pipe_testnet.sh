#!/bin/bash

CONTAINER_NAME="pipe"

docker container inspect "$CONTAINER_NAME" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${BLUE}Створюємо новий контейнер '$CONTAINER_NAME'...${NC}"
    docker run -dit --name "$CONTAINER_NAME" ubuntu:24.04 >/dev/null 2>&1
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

  PACKAGES=(curl nano tmux)
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
docker exec -it "$CONTAINER_NAME" bash -c '
  curl -o pipe.tar.gz https://raw.githubusercontent.com/krenat/nodes/refs/heads/main/pipe/pop-v0.3.0-linux-x64.tar.gz
'

docker exec -it "$CONTAINER_NAME" bash -c '
  mkdir -p /opt/popcache
'

