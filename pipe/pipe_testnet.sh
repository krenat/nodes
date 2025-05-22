#!/bin/bash

CONTAINER_NAME="pipe"

create_container() {
  docker container inspect "$CONTAINER_NAME" > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo -e "${BLUE}Створюємо новий контейнер '$CONTAINER_NAME'...${NC}"
    docker run -dit --name "$CONTAINER_NAME" -p 443:443 -p 80:80 ubuntu:24.04 >/dev/null 2>&1
  else
    echo -e "${BLUE}Контейнер '$CONTAINER_NAME' вже існує.${NC}"
    exit 1
  fi
}

update_container() {
  # Встановлення залежностей та запуск скриптів
  echo -e "${BLUE}Встановлюємо залежності та запускаємо інсталяційні скрипти...${NC}"

  docker exec -it "$CONTAINER_NAME" bash -c "
    cd && \
    apt update >/dev/null
  "
  update_container_dependencies
}

update_container_dependencies() {
  docker exec -it "$CONTAINER_NAME" bash -c '
    echo -e "${BLUE}Встановлення залежностей у контейнері...${NC}"

    PACKAGES=(curl wget tar nano tmux)
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
}

install_project() {
  docker exec -it "$CONTAINER_NAME" bash -c '
    mkdir -p /opt/popcache
  '

  docker exec -it "$CONTAINER_NAME" bash -c '
    curl -o pipe.tar.gz https://raw.githubusercontent.com/krenat/nodes/refs/heads/main/pipe/pop-v0.3.0-linux-x64.tar.gz
    echo -e "${GREEN}\n✅ Файл проекту завантажено ${NC}"
    tar -xzf pipe.tar.gz
    chmod +x pop
  '

  docker exec -it "$CONTAINER_NAME" bash -c '
    ./pop create-config
  '
}

update_project() {
  CONFIG_FILE="$HOME/p-pipe/config.json"
  docker cp pipe:config.json "$CONFIG_FILE"

  read -p "Введіть solana_pubkey: " SOLANA_PUBKEY
  read -p "Введіть email: " EMAIL
  read -p "Введіть discord: " DISCORD
  read -p "Введіть invite_code: " INVITE_CODE

  # Оновлюємо поля в JSON за допомогою jq
  jq --arg pubkey "$SOLANA_PUBKEY" \
     --arg email "$EMAIL" \
     --arg discord "$DISCORD" \
     --arg invite "$INVITE_CODE" \
     '
     .identity_config.solana_pubkey = $pubkey |
     .identity_config.email = $email |
     .identity_config.discord = $discord |
     .invite_code = $invite |
     .cache_config.memory_cache_size_mb = 4000 |
     .cache_config.disk_cache_size_gb = 70
     ' "$CONFIG_FILE" > tmp_config.json && mv tmp_config.json "$CONFIG_FILE"

  docker cp "$CONFIG_FILE" pipe:config.json
}

install() {
  create_container
  update_container
  install_project
}

start_project() {
  docker exec -it "$CONTAINER_NAME" tmux new -s pipe './pop; bash'
}

show_menu() {
	echo "Оберіть етап для виконання:"
	echo "i - інсталювати проєкт"
	echo "u - налаштувати проєкт"
	echo "s - запустити проєкт"
	echo "x - завершити"

	read -r -p "Ваш вибір: " step
  handle_step "$step"
}

handle_step() {
	case "$1" in
    i) install ;;
    u) update_project ;;
    s) start_project ;;
    x) exit ;;
    *) show_menu ;;
	esac
}

if [[ -n "$1" ]]; then
  handle_step "$@"
	exit
fi

show_menu