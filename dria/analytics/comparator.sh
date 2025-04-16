#!/bin/bash

HISTORY_FILE="/home/root/dria/analytics/dria_points_history.json"
TODAY=$(date +%F)
YESTERDAY=$(date -d "yesterday" +%F)

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ ! -f "$HISTORY_FILE" ]; then
  echo "❌ Файл історії не знайдено: $HISTORY_FILE"
  exit 1
fi

# ==== Перевірка чи є дані ====
jq -e --arg day "$TODAY" 'has($day)' "$HISTORY_FILE" > /dev/null || {
  echo "❌ Немає записів за $TODAY"
  exit 1
}

jq -e --arg day "$YESTERDAY" 'has($day)' "$HISTORY_FILE" > /dev/null || {
  echo "❌ Немає записів за $YESTERDAY"
  exit 1
}

echo -e "${BLUE}📊 Порівняння DRIA Points: $YESTERDAY → $TODAY${NC}"

# ==== Порівняння по діапазонах ====
jq -r --arg day1 "$YESTERDAY" --arg day2 "$TODAY" '
  [$day1, $day2] as $days |
  $days | map(. as $d | input[$d]) | transpose | .[0] as $yest | .[1] as $today |
  input[$day2] as $today_data |
  reduce keys_unsorted[] as $range (
    "";
    . + (
      $today_data[$range] as $t |
      input[$day1][$range] as $y |
      (
        $t | keys_unsorted[] | map({
          container: .,
          today: ($t[.]),
          yesterday: ($y[.] // 0),
          delta: ($t[.] - ($y[.] // 0))
        })
      )
    )
  )
' --slurpfile input "$HISTORY_FILE" | jq -c '.[]' | while read -r entry; do
  CONTAINER=$(echo "$entry" | jq -r '.container')
  TODAY_P=$(echo "$entry" | jq -r '.today')
  YESTERDAY_P=$(echo "$entry" | jq -r '.yesterday')
  DELTA=$(echo "$entry" | jq -r '.delta')

  COLOR=$([ "$DELTA" -ge 0 ] && echo "$GREEN" || echo "$RED")
  SIGN=$([ "$DELTA" -ge 0 ] && echo "+" || echo "-")

  echo -e "$CONTAINER: $YESTERDAY_P → $TODAY_P ${COLOR}(${SIGN}${DELTA})${NC}"
done
