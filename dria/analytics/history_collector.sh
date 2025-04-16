#!/bin/bash

# ==== Кольори ====
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # Reset

# ==== Налаштування ====
START=${1:-1}
END=${2:-10}
DATE=$(date +%F)
HISTORY_FILE="/home/твій_юзер/dria/dria_points_history.json"

echo -e "${BLUE}📦 Збираємо DRIA points для контейнерів dria${START}–dria${END}${NC}"

# ==== Ініціалізація ====
declare -A CURRENT_POINTS
declare -A PREVIOUS_POINTS

# ==== Завантажити історію (якщо є) ====
if [ -f "$HISTORY_FILE" ]; then
  PREVIOUS_DATE=$(jq -r 'keys_unsorted | .[-1]' "$HISTORY_FILE")
  PREVIOUS_POINTS_RAW=$(jq -r ".[\"$PREVIOUS_DATE\"]" "$HISTORY_FILE")
else
  PREVIOUS_DATE=""
  PREVIOUS_POINTS_RAW="{}"
fi

# ==== Конвертувати попередні у масив ====
if [ -n "$PREVIOUS_POINTS_RAW" ]; then
  for i in $(seq $START $END); do
    key="dria$i"
    value=$(echo "$PREVIOUS_POINTS_RAW" | jq -r --arg key "$key" '.[$key] // 0')
    PREVIOUS_POINTS["$key"]=$value
  done
fi

# ==== Зібрати поточні значення ====
for i in $(seq "$START" "$END"); do
  CONTAINER="dria$i"
  echo -ne "${BLUE}🔄 $CONTAINER:${NC} "
  
  POINTS=$(docker exec -i "$CONTAINER" /root/.dria/bin/dkn-compute-launcher points 2>/dev/null \
    | grep -oE '^[0-9]+' || echo 0)
  
  CURRENT_POINTS["$CONTAINER"]=$POINTS
  echo -e "${GREEN}${POINTS} $DRIA${NC}"
done

# ==== Побудувати JSON для запису ====
JSON_UPDATE="{"
for i in $(seq "$START" "$END"); do
  C="dria$i"
  P=${CURRENT_POINTS["$C"]}
  JSON_UPDATE+="\"$C\": $P"
  [[ $i -lt $END ]] && JSON_UPDATE+=", "
done
JSON_UPDATE+="}"

# ==== Записати в історію ====
if [ ! -f "$HISTORY_FILE" ]; then
  echo "{}" > "$HISTORY_FILE"
fi

jq --arg date "$DATE" --argjson points "$JSON_UPDATE" '. + {($date): $points}' "$HISTORY_FILE" > "${HISTORY_FILE}.tmp" && mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"

echo -e "${GREEN}✅ Дані збережено до історії за ${DATE}${NC}"

# ==== Показати дельту ====
if [ -n "$PREVIOUS_DATE" ]; then
  echo -e "\n📈 Порівняння з ${PREVIOUS_DATE}:"
  for i in $(seq $START $END); do
    C="dria$i"
    CURRENT=${CURRENT_POINTS[$C]}
    PREVIOUS=${PREVIOUS_POINTS[$C]}
    DELTA=$((CURRENT - PREVIOUS))
    SIGN="+"; [[ $DELTA -lt 0 ]] && SIGN=""
    echo -e "$C: ${CURRENT} (${SIGN}${DELTA})"
  done
fi
