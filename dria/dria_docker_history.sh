#!/bin/bash

# Кольори
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# JSON-файл
JSON_FILE="dria_points_history.json"
TIMESTAMP=$(date -Iseconds)

# Ввід діапазону
read -p "🔢 Введіть стартовий індекс контейнера (наприклад, 1): " START
read -p "🔢 Введіть кінцевий індекс контейнера (наприклад, 10): " END

echo -e "${YELLOW}🔍 Збираємо DRIA points з контейнерів dria${START} до dria${END}...${NC}"

declare -A CURRENT_POINTS

for ((i=START; i<=END; i++)); do
  CONTAINER="dria$i"
  echo -ne "🔄 Контейнер $CONTAINER: "

  if docker exec "$CONTAINER" test -f /root/.dria/bin/dkn-compute-launcher; then
    POINTS=$(docker exec -it "$CONTAINER" /root/.dria/bin/dkn-compute-launcher points 2>/dev/null \
        | grep -oE '[0-9]+ \$DRIA' || echo "N/A")

    if [[ -n "$POINTS" ]]; then
      CURRENT_POINTS[$CONTAINER]=$POINTS
      echo -e "${GREEN}$POINTS $DRIA${NC}"
    else
      CURRENT_POINTS[$CONTAINER]=0
      echo -e "${RED}❌ Не вдалося отримати поінти${NC}"
    fi
  else
    CURRENT_POINTS[$CONTAINER]=0
    echo -e "${RED}🚫 dkn-compute-launcher не знайдено${NC}"
  fi
done

# Підготовка JSON
TMP_JSON=$(mktemp)
echo "{}" > "$TMP_JSON"
for CONTAINER in "${!CURRENT_POINTS[@]}"; do
  jq --arg key "$CONTAINER" --argjson val "${CURRENT_POINTS[$CONTAINER]}" \
    '. + {($key): $val}' "$TMP_JSON" > "$TMP_JSON.tmp" && mv "$TMP_JSON.tmp" "$TMP_JSON"
done

# Додати з міткою часу
if [[ -f "$JSON_FILE" ]]; then
  jq --arg time "$TIMESTAMP" --slurpfile data "$TMP_JSON" \
    '. + {($time): $data[0]}' "$JSON_FILE" > "${JSON_FILE}.tmp" && mv "${JSON_FILE}.tmp" "$JSON_FILE"
else
  jq --null-input --arg time "$TIMESTAMP" --slurpfile data "$TMP_JSON" \
    '{($time): $data[0]}' > "$JSON_FILE"
fi

rm "$TMP_JSON"

echo -e "\n📁 Дані збережено у файл: ${YELLOW}$JSON_FILE${NC}"

# 🔁 Виведення дельти
LAST_TIMESTAMP=$(jq -r 'keys_unsorted | .[-2]' "$JSON_FILE")
if [[ "$LAST_TIMESTAMP" != "null" ]]; then
  echo -e "\n📊 Зміни відносно попереднього запуску ($LAST_TIMESTAMP):"
  for CONTAINER in "${!CURRENT_POINTS[@]}"; do
    OLD=$(jq -r --arg t "$LAST_TIMESTAMP" --arg c "$CONTAINER" '.[$t][$c] // 0' "$JSON_FILE")
    NEW=${CURRENT_POINTS[$CONTAINER]}
    DELTA=$((NEW - OLD))
    SIGN=""
    [[ $DELTA -gt 0 ]] && SIGN="+"
    echo -e "$CONTAINER: ${GREEN}$NEW${NC} (${YELLOW}${SIGN}${DELTA}${NC})"
  done
fi
