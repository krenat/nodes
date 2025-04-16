#!/bin/bash

# ==== Кольори ====
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# ==== Аргументи ====
START=${1:-0}
END=${2:-9}
DATE=$(date +%F)
RANGE_LABEL="${START}-${END}"
HISTORY_FILE="/home/root/dria/dria_points_history.json"
mkdir -p "$(dirname "$HISTORY_FILE")"

echo -e "${BLUE}📦 Збираємо DRIA points для діапазону ${RANGE_LABEL}${NC}"

# ==== Ініціалізація JSON структури ====
declare -A CURRENT_POINTS

for i in $(seq "$START" "$END"); do
  CONTAINER="dria$i"
  echo -ne "${BLUE}🔄 $CONTAINER:${NC} "

  POINTS=$(docker exec -i "$CONTAINER" /root/.dria/bin/dkn-compute-launcher points 2>/dev/null \
    | grep -oE '^[0-9]+' || echo 0)

  CURRENT_POINTS["$CONTAINER"]=$POINTS
  echo -e "${GREEN}${POINTS} $DRIA${NC}"
done

# ==== Побудова часткового JSON ====
PARTIAL_JSON="{"
for i in $(seq "$START" "$END"); do
  C="dria$i"
  PARTIAL_JSON+="\"$C\": ${CURRENT_POINTS["$C"]}"
  [[ $i -lt $END ]] && PARTIAL_JSON+=", "
done
PARTIAL_JSON+="}"

# ==== Ініціалізація файлу (якщо нема) ====
if [ ! -f "$HISTORY_FILE" ]; then
  echo "{}" > "$HISTORY_FILE"
fi

# ==== Запис у файл: .[date][range] = { partial json } ====
jq --arg date "$DATE" --arg range "$RANGE_LABEL" --argjson data "$PARTIAL_JSON" \
   '.[$date] = (.[$date] // {}) | .[$date][$range] = $data' \
   "$HISTORY_FILE" > "${HISTORY_FILE}.tmp" && mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"

echo -e "${GREEN}✅ Дані збережено в історію: $DATE → [$RANGE_LABEL]${NC}"
