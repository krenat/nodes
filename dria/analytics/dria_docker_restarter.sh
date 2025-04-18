#!/bin/bash

# Запитуємо початок і кінець діапазону
read -p "Введіть номер першого контейнера: " START
read -p "Введіть номер останнього контейнера: " END

for i in $(seq "$START" "$END"); do
  CONTAINER="dria$i"
  echo -e "\n🔄 ${CONTAINER}: перезапуск tmux-сесії..."

  # Зупиняємо сесію tmux, якщо вона існує
  docker exec "$CONTAINER" bash -c '
    if tmux has-session -t dria 2>/dev/null; then
      echo "🛑 Зупиняємо стару сесію tmux 'dria'..."
      tmux kill-session -t dria
    else
      echo "ℹ️  Стара сесія tmux 'dria' не знайдена"
    fi
  '

  # Стартуємо нову сесію
  docker exec -d "$CONTAINER" bash -c '
    echo "🚀 Запускаємо нову tmux-сесію 'dria'..."
    tmux new -s dria "/root/.dria/bin/dkn-compute-launcher start; bash"
  '

  echo "✅ $CONTAINER — Готово"
done
