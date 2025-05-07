# Кольори
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
GRAY='\033[0;37m'
NC='\033[0m'

# Заголовок
printf "%-8s" "Container"
for DATE in "${DATES[@]}"; do
  printf " | %6s" "$DATE"
done
echo

# Дані по контейнерах
for i in $(seq "$START" "$END"); do
  CONTAINER="dria$i"
  printf "%-8s" "$CONTAINER"
  PREV_VALUE=""

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

  echo
done
