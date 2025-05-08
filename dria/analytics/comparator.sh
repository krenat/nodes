#!/bin/bash

JSON_FILE="dria/analytics/dria_points_history.json"
START=${1:-0}
END=${2:-9}
DAYS=5

# Кольори
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Отримати останні $DAYS днів у форматі yyyy-mm-dd
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