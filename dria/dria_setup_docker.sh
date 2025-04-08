#!/bin/bash

# Запит імені контейнера
read -p "Введи ім'я контейнера: " CONTAINER_NAME

# Перевірка, чи введено ім'я
if [ -z "$CONTAINER_NAME" ]; then
    echo "Ім'я контейнера не може бути порожнім."
    exit 1
fi

# Створити контейнер у фоні, якщо ще не існує
docker container inspect "$CONTAINER_NAME" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Створюємо новий контейнер '$CONTAINER_NAME'..."
    docker run -dit --name "$CONTAINER_NAME" ubuntu:22.04
else
    echo "Контейнер '$CONTAINER_NAME' вже існує. Запускаємо його..."
    docker container start "$CONTAINER_NAME"
fi

# Встановлення залежностей та запуск скриптів
echo "Встановлюємо залежності та запускаємо інсталяційні скрипти..."

docker exec -it "$CONTAINER_NAME" bash -c "
    cd && \
    apt update && \
    apt install -y curl git make jq build-essential gcc unzip wget lz4 aria2 tmux && \
    curl -fsSL https://dria.co/launcher | bash && \
    curl -fsSL https://ollama.com/install.sh | sh
"

# Запуск tmux сесії всередині контейнера
echo "Запускаємо tmux сесію 'dria'..."
docker exec -it "$CONTAINER_NAME" tmux new -s dria
