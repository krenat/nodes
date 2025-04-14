#!/bin/bash

read -p "Введи початковий номер контейнера (start): " START
read -p "Введи кінцевий номер контейнера (end): " END

declare -A points_map
TOTAL=$((END - START + 1))
COUNT=0

echo ""
echo "🔄 Збираємо дані з контейнерів..."

for i in $(seq $START $END); do
    CONTAINER="dria$i"
    COUNT=$((COUNT + 1))

    echo -ne "▶️  [$COUNT/$TOTAL] Обробка $CONTAINER...\r"

    POINTS=$(docker exec -it "$CONTAINER" /root/.dria/bin/dkn-compute-launcher points 2>/dev/null \
        | grep -oE '[0-9]+ \$DRIA' || echo "N/A")

    points_map["$CONTAINER"]=$POINTS
done

echo -e "\n✅ Завершено!"

echo ""
echo "📊 DKN Points Summary:"
echo "------------------------"
for i in $(seq $START $END); do
    CONTAINER="dria$i"
    echo "$CONTAINER: ${points_map[$CONTAINER]}"
done
