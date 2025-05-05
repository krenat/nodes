#!/bin/bash

# Цвета текста
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # Нет цвета (сброс цвета)

check_dependencies() {
	# Проверка наличия curl и установка, если не установлен
	if ! command -v curl &> /dev/null; then
		sudo apt update
		sudo apt install curl -y
	fi
	sleep 1
}

show_menu() {
	echo -e "${YELLOW}Выберите действие:${NC}"
	echo -e "${CYAN}1) Установка ноды${NC}"
	echo -e "${CYAN}2) Проверка статуса ноды${NC}"
	echo -e "${CYAN}3) Удаление ноды${NC}"

	echo -e "${YELLOW}Введите номер:${NC} "
	read choice
	handle_step $choice
}

handle_step() {
	case $choice in
		1) node_install ;;
		2) node_check ;;
		3) node_delete ;;
		*)
			echo -e "${RED}Неверный выбор. Пожалуйста, введите номер от 1 до 3.${NC}"
			;;
	esac
}

node_install() {
  check_dependencies
	echo -e "${BLUE}Устанавливаем ноду...${NC}"
	cd ~
	
	# Скачиваем клиент
	echo -e "${BLUE}Скачиваем клиент...${NC}"
	wget https://mdeck-download.s3.us-east-1.amazonaws.com/client/linux/install.sh
	source ./install.sh

	# Распаковываем архив
	echo -e "${BLUE}Обновляем...${NC}"
	wget https://mdeck-download.s3.us-east-1.amazonaws.com/client/linux/update.sh
	source ./update.sh

	# Переход в папку клиента
	cd ~/multipleforlinux

	# Запуск ноды
	echo -e "${BLUE}Запускаем multiple-node...${NC}"
	#nohup ./multiple-node > output.log 2>&1 &
	wget https://mdeck-download.s3.us-east-1.amazonaws.com/client/linux/start.sh
	source ./start.sh

	# Ввод Account ID и PIN
	echo -e "${YELLOW}Введите ваш Account ID:${NC}"
	read IDENTIFIER
	echo -e "${YELLOW}Установите ваш PIN:${NC}"
	read PIN

	# Привязка аккаунта
	echo -e "${BLUE}Привязываем аккаунт с ID: $IDENTIFIER и PIN: $PIN...${NC}"
	multiple-cli bind --bandwidth-download 100 --identifier $IDENTIFIER --pin $PIN --storage 200 --bandwidth-upload 100

	# Заключительный вывод
	echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
	sleep 2
	cd && cd ~/multipleforlinux && ./multiple-cli status
	rm -f ~/install.sh ~/update.sh 
}

node_check() {
	# Проверка логов
	echo -e "${BLUE}Проверяем статус...${NC}"
	cd && cd ~/multipleforlinux && ./multiple-cli status
}

node_delete() {
	echo -e "${BLUE}Удаление ноды...${NC}"

	# Остановка процесса ноды
	pkill -f multiple-node

	# Удаление файлов ноды
	cd ~
	sudo rm -rf multipleforlinux

	echo -e "${GREEN}Нода успешно удалена!${NC}"
	sleep 1
}

show_menu
