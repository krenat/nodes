#!/bin/bash

# Кольори
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[1;30m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

prepare() {
  packages=("docker:docker.io")

  echo -e "${BLUE}Встановлення залежностей...${NC}"

  TOTAL=${#packages[@]}
  CURRENT=0
  BAR_WIDTH=40

  sudo apt update >/dev/null 2>&1

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

  echo

  for pkg in "${packages[@]}"; do
    IFS=":" read -r pkg_name pkg_real <<< "$pkg"
    check_and_install "$pkg_name" "$pkg_real"
    ((CURRENT++))
    draw_progress "$CURRENT"
  done

  echo -e "\n${GREEN}✅ Усі залежності встановлені.${NC}"
}

check_and_install() {
  if ! dpkg -s "$1" &> /dev/null; then
    echo -e "${YELLOW}$pkg_name не знайдено. Встановлюємо...${NC}"
    sudo apt install -y "$2" >/dev/null 2>&1
  fi
}

get_index() {
  local index
  read -p "Введи індекс контейнера dria: " index

  if [[ -z "$index" ]]; then
    echo -e "${RED}❌ Індекс не може бути порожнім.${NC}"
    exit 1
  fi

  echo "$index"
}

install() {
  INDEX=$(get_index)
  CONTAINER_NAME="dria$INDEX"

  # Перевірка, чи введено ім'я
  if [ -z "$CONTAINER_NAME" ]; then
    echo -e "${RED}Ім'я контейнера не може бути порожнім.${NC}"
    exit 1
  fi

  create_container "$CONTAINER_NAME"
  install_project "$CONTAINER_NAME"
  setup_project "$CONTAINER_NAME" "$INDEX"
}

install_1() {
  INDEX=$(get_index)
  CONTAINER_NAME="dria$INDEX"
  create_container "$CONTAINER_NAME"
}

install_2() {
  INDEX=$(get_index)
  CONTAINER_NAME="dria$INDEX"
  install_project "$CONTAINER_NAME"
}

install_3() {
  INDEX=$(get_index)
  CONTAINER_NAME="dria$INDEX"
  setup_project "$CONTAINER_NAME" "$INDEX"
}

create_container() {
  CONTAINER_NAME="$1"
   # Перевірка, чи контейнер існує
  if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    echo -e "${YELLOW}Контейнер '$CONTAINER_NAME' вже існує.${NC}"
    read -p "🔁 Хочеш перезапустити його? [y/N]: " choice
    case "$choice" in
      [yY])
        echo -e "${BLUE}Зупиняємо та видаляємо контейнер '$CONTAINER_NAME'...${NC}"
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1
        ;;
      *)
        echo -e "${RED}❌ Операцію скасовано користувачем.${NC}"
        exit 1
        ;;
    esac
  fi

  echo -e "${BLUE}Створюємо новий контейнер '$CONTAINER_NAME'...${NC}"
  docker run -dit --name "$CONTAINER_NAME" ubuntu:22.04 >/dev/null 2>&1

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
}

install_project() {
  CONTAINER_NAME="$1"
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
}

setup_project() {
  CONTAINER_NAME="$1"
  INDEX="$2"

  WALLET_JSON=$(jq -r ".[] | select(.index == $INDEX)" "$WALLETS_FILE")

  WALLET_SECRET=$(echo "$WALLET_JSON" | jq -r ".evm-private")
  GEMINI_API_KEY=$(echo "$WALLET_JSON" | jq -r ".gemini-api")
  SERPER_API_KEY=$(echo "$WALLET_JSON" | jq -r ".serper-api")
  JINA_API_KEY=$(echo "$WALLET_JSON" | jq -r ".jina-api")
  MODELS=$(echo "$WALLET_JSON" | jq -r ".models")

  if [[ -z "$WALLET_SECRET" ]]; then
    echo -e "${RED}❌ Не знайдено wallet для індексу $INDEX${NC}"
    exit 1
  fi

  echo -e "${BLUE}Створення файлу .env ${NC}"
  docker exec "$CONTAINER_NAME" mkdir -p /root/.dria/dkn-compute-launcher

  cat > .env <<EOF
## DRIA ##
DKN_WALLET_SECRET_KEY=$WALLET_SECRET
DKN_MODELS=$MODELS
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
SERPER_API_KEY=$SERPER_API_KEY
## Jina (optional) ##
JINA_API_KEY=$JINA_API_KEY

## Log levels
RUST_LOG=none
EOF

  docker cp .env "$CONTAINER_NAME":/root/.dria/dkn-compute-launcher/.env
  rm .env

  echo -e "${GREEN}✅ .env для $CONTAINER_NAME створено з wallet $WALLET_SECRET${NC}"

  # Запуск tmux-сесії 'dria' і запуск dkn-compute-launcher всередині
  echo -e "${BLUE}Запускаємо tmux-сесію 'dria' з dkn-compute-launcher...${NC}"
  docker exec "$CONTAINER_NAME" tmux kill-session -t dria 2>/dev/null
  docker exec -it "$CONTAINER_NAME" tmux new -s dria '/root/.dria/bin/dkn-compute-launcher start; bash'
}

restart() {
  if [[ -z "$2" ]]; then
    read -p "Введи початковий індекс контейнера (START): " START
  else
    START=$2
  fi

  if [[ -z "$3" ]]; then
    read -p "Введи кінцевий індекс контейнера (END): " END
  else
    END=$3
  fi

  for i in $(seq "$START" "$END"); do
    CONTAINER="dria$i"
    echo -e "\n🔄 ${CONTAINER}: перезапуск tmux-сесії..."

    # Зупиняємо сесію tmux, якщо вона існує
    docker exec "$CONTAINER" bash -c '
      if tmux has-session -t dria 2>/dev/null; then
        echo "🛑 Зупиняємо стару сесію tmux dria..."
        tmux kill-session -t dria
      else
        echo "ℹ️  Стара сесія tmux dria не знайдена"
      fi
    '

    # Стартуємо нову сесію
    docker exec -d "$CONTAINER" bash -c '
      echo "🚀 Запускаємо нову tmux-сесію dria..."
      tmux new -s dria "/root/.dria/bin/dkn-compute-launcher start; bash"
    '

    echo "✅ $CONTAINER — Готово"
  done

}

continue_collect_points() {
  TIME_FILE="$SCRIPT_DIR/last_run_time.txt"
  INTERVAL_SECONDS_DAY=$((24 * 60 * 60))

  if [[ -z "$2" ]]; then
    read -p "Введи початковий індекс контейнера (START): " START
  else
    START=$2
  fi

  if [[ -z "$3" ]]; then
    read -p "Введи кінцевий індекс контейнера (END): " END
  else
    END=$3
  fi

  while true; do
    CURRENT_TIME=$(date +%s)

    if [[ -f "$TIME_FILE" ]]; then
      LAST_RUN_TIME=$(cat "$TIME_FILE")
    else
      LAST_RUN_TIME=0
    fi

    ELAPSED=$((CURRENT_TIME - LAST_RUN_TIME))

    if (( ELAPSED >= INTERVAL_SECONDS_DAY )); then
        collect_points points "$START" "$END"
        date +%s > "$TIME_FILE"
    else
      REMAINING=$((INTERVAL_SECONDS_DAY - ELAPSED))

      if (( REMAINING >= 3600 )); then
        HOURS=$((REMAINING / 3600))
        echo "[$(date)] Waiting another ~$HOURS hour(s)..."
      else
        MINUTES=$((REMAINING / 60))
        echo "[$(date)] Waiting another ~$MINUTES minute(s)..."
      fi
    fi

    sleep 3600  # перевірка кожну годину
  done
}

collect_points() {
  # ==== Аргументи ====
  if [[ -z "$2" ]]; then
    read -p "Введи початковий індекс контейнера (START): " START
  else
    START=$2
  fi

  if [[ -z "$3" ]]; then
    read -p "Введи кінцевий індекс контейнера (END): " END
  else
    END=$3
  fi

  SLEEP_MAX=${4:-90}

  DATE=$(date +%F)
  RANGE_LABEL="${START}-${END}"
  HISTORY_FILE="$SCRIPT_DIR/dria_points_history.json"

  echo -e "${BLUE}📦 Збираємо DRIA points для діапазону ${RANGE_LABEL}${NC}"

  # ==== Ініціалізація файлу (якщо нема) ====
  if [ ! -f "$HISTORY_FILE" ]; then
    echo "{}" > "$HISTORY_FILE"
  fi

  # ==== Ініціалізація JSON структури ====
  declare -A CURRENT_POINTS

  FAILED_INDEXES=()
  MAX_RETRIES=3

  attempt_collect() {
    local i=$1
    local CONTAINER="dria$i"

    # Перевірка, чи вже є дані не 0
    EXISTING=$(jq -r --arg date "$DATE" --arg range "$RANGE_LABEL" --arg key "$CONTAINER" \
      '.[$date][$range][$key] // 0' "$HISTORY_FILE")

    if [[ "$EXISTING" -ne 0 ]]; then
      echo -e "${BLUE}$CONTAINER: дані вже є ($EXISTING), пропускаємо...${NC}"
      return
    fi

    # Sleep
    SLEEP_TIME=$(( RANDOM % SLEEP_MAX + 1 ))
    echo -e "${BLUE}⏳ Очікуємо $SLEEP_TIME сек перед запитом для $CONTAINER...${NC}"
    sleep "$SLEEP_TIME"

    # Запит
    echo -ne "${BLUE}🔍 $CONTAINER:${NC} "
    POINTS=$(docker exec -it "$CONTAINER" /root/.dria/bin/dkn-compute-launcher points 2>/dev/null \
      | sed -r 's/\x1B\[[0-9;]*[mK]//g' | grep -oE '[0-9]+ \$DRIA' | grep -oE '^[0-9]+' || echo 0)

    echo "$POINTS $DRIA"

    if [[ "$POINTS" -eq 0 ]]; then
      FAILED_INDEXES+=("$i")
    else
      CURRENT_POINTS["$CONTAINER"]=$POINTS
    fi
  }

  # === Основний цикл ===
  for i in $(seq "$START" "$END"); do
    attempt_collect "$i"
  done

  # === Повторні спроби для невдалих індексів ===
  for ((retry=1; retry<=MAX_RETRIES; retry++)); do
    if [[ ${#FAILED_INDEXES[@]} -eq 0 ]]; then break; fi
    echo -e "${BLUE}🔁 Повторна спроба #$retry для невдалих контейнерів...${NC}"
    RETRY_FAILED=()
    for i in "${FAILED_INDEXES[@]}"; do
      attempt_collect "$i"
    done
    FAILED_INDEXES=("${RETRY_FAILED[@]}")
  done

  # ==== Побудова часткового JSON ====
  PARTIAL_JSON=$(jq -n '{'"$(for i in $(seq "$START" "$END"); do
    C="dria$i"
    V=${CURRENT_POINTS["$C"]:-0}
    echo -n "\"$C\": $V"
    [[ $i -lt $END ]] && echo -n ", "
  done)"'}')

  # ==== Запис у файл: .[date] = { partial json } ====
   jq --arg date "$DATE" --argjson data "$PARTIAL_JSON" \
      '.[$date] = (.[$date] // {}) + $data' \
      "$HISTORY_FILE" > "${HISTORY_FILE}.tmp" && mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"

  echo -e "${GREEN}✅ Дані збережено в історію: $DATE ${NC}"
}

analyze_points() {
  if [[ -z "$2" ]]; then
   read -p "Введи початковий індекс контейнера (START): " START
  else
    START=$2
  fi

  if [[ -z "$3" ]]; then
    read -p "Введи кінцевий індекс контейнера (END): " END
  else
    END=$3
  fi

  DAYS=${4:-5}

  # Отримати останні $DAYS днів у форматі yyyy-mm-dd
  JSON_FILE="$SCRIPT_DIR/dria_points_history.json"
  DATES=($(jq -r 'keys_unsorted[]' "$JSON_FILE" | sort | tail -n $DAYS))

  # Заголовок
  printf "%-7s" "DRIA"
  for DATE in "${DATES[@]}"; do
    SHORT=$(date -d "$DATE" +%m-%d 2>/dev/null || date -j -f "%Y-%m-%d" "$DATE" +%m-%d)
    printf " | %6s" "$SHORT"
  done
  echo

  # Дані по контейнерах
  for i in $(seq "$START" "$END"); do
    CONTAINER="dria$i"
    printf "%-8s" "$CONTAINER"
    PREV_VALUE=""
    LAST_VALUE=""
    DELTA=""

    for DATE in "${DATES[@]}"; do
      VALUE=$(jq -r --arg d "$DATE" --arg c "$CONTAINER" '.[$d][$c] // empty' "$JSON_FILE")

      if [ -z "$VALUE" ] || [ "$VALUE" = "0" ]; then
        printf " | ${GRAY}%6s${NC}" "---"
        PREV_VALUE=""
        continue
      fi

      COLOR=$NC
      if [ -n "$PREV_VALUE" ]; then
        DIFF=$((VALUE - PREV_VALUE))
        if [ "$DIFF" -eq 0 ]; then
          COLOR=$RED
        elif [ "$DIFF" -lt 100 ]; then
          COLOR=$YELLOW
        elif [ "$DIFF" -le 250 ]; then
          COLOR=$GREEN
        else
          COLOR=$PURPLE
        fi
      fi

      printf " | ${COLOR}%6s${NC}" "$VALUE"
      PREV_VALUE=$VALUE
    done

    # Вираховуємо дельту між останніми двома значеннями
    LEN=${#DATES[@]}
    if [ "$LEN" -ge 2 ]; then
      LAST_DATE="${DATES[$((LEN - 1))]}"
      PREV_DATE="${DATES[$((LEN - 2))]}"
      LAST_VALUE=$(jq -r --arg d "$LAST_DATE" --arg c "$CONTAINER" '.[$d][$c] // empty' "$JSON_FILE")
      PREV_VAL=$(jq -r --arg d "$PREV_DATE" --arg c "$CONTAINER" '.[$d][$c] // empty' "$JSON_FILE")

      if [[ "$LAST_VALUE" =~ ^[0-9]+$ ]] && [[ "$PREV_VAL" =~ ^[0-9]+$ ]]; then
        DELTA=$((LAST_VALUE - PREV_VAL))
        if [ "$DELTA" -eq 0 ]; then
          COLOR=$RED
        elif [ "$DELTA" -lt 100 ]; then
          COLOR=$YELLOW
        elif [ "$DELTA" -le 250 ]; then
          COLOR=$GREEN
        else
          COLOR=$PURPLE
        fi
        printf " | ${COLOR}%+4d${NC}" "$DELTA"
      else
        printf " | ${GRAY}%6s${NC}" "---"
      fi
    else
      printf " | ${GRAY}%6s${NC}" "---"
    fi

    echo
  done
}

show_menu() {
	echo "Оберіть етап для виконання:"
	echo "p - інсталювати необхідні залежності"
	echo "i - інсталювати та налаштувати проєкт"
	echo "i1 - cтворити контейнер"
	echo "i2 - інсталювати проєкт"
	echo "i3 - налаштувати проєкт"
	echo "points - збір та відображення поінтів разове"
	echo "points-c - збір та відображення поінтів постійно"
	echo "analyze - аналіз та відображення поінтів"
	echo "r - перезапустити"
	echo "x - завершити"

	read -r -p "Ваш вибір: " step
  handle_step "$step"
}

handle_step() {
	case "$1" in
	  p) prepare ;;
    i) install ;;
    i1) install_1 ;;
    i2) install_2 ;;
    i3) install_3 ;;
    points) collect_points "$@" ;;
    points-c) continue_collect_points "$@" ;;
    analyze) analyze_points "$@" ;;
    r) restart "$@";;
    x) exit ;;
    *) show_menu ;;
	esac
}

if [[ -n "$1" ]]; then
  handle_step "$@"
	exit
fi

show_menu