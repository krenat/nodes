#!/bin/bash

CONFIG_FILE="$HOME/drosera/.drosera_keys"

# Функція для завантаження ключів
load_private_key() {
  if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Файл з ключами не знайдено: $CONFIG_FILE"
    exit 1
  fi
  source "$CONFIG_FILE"
  if [[ -z "$PRIVATE_KEY" ]]; then
    echo "❌ PRIVATE_KEY не знайдено у $CONFIG_FILE"
    exit 1
  fi
}

load_public_key() {
  if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Файл з ключами не знайдено: $CONFIG_FILE"
    exit 1
  fi
  source "$CONFIG_FILE"
  if [[ -z "$PUBLIC_KEY" ]]; then
    echo "❌ PUBLIC_KEY не знайдено у $CONFIG_FILE"
    exit 1
  fi
}

load_drosera_key() {
  if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Файл з ключами не знайдено: $CONFIG_FILE"
    exit 1
  fi
  source "$CONFIG_FILE"
  if [[ -z "$DROSERA_ADDRESS" ]]; then
    echo "❌ DROSERA_ADDRESS не знайдено у $CONFIG_FILE"
    exit 1
  fi
}

install() {
	save_keys
	install_tools
	init_project

	echo "Щоб зміни вступили в силу, виконайте:"
	echo "source ~/.bashrc"
}

# Етап 1: Збереження ключів
save_keys() {
  echo "[Етап 1] Збереження приватного та публічного ключів"
  read -p "Введіть ваш PRIVATE_KEY: " PRIVATE_KEY
  read -p "Введіть ваш PUBLIC_KEY: " PUBLIC_KEY

  mkdir -p "$(dirname "$CONFIG_FILE")"

  echo "PRIVATE_KEY=\"$PRIVATE_KEY\"" > "$CONFIG_FILE"
  echo "PUBLIC_KEY=\"$PUBLIC_KEY\"" >> "$CONFIG_FILE"

  echo "✅ Ключі збережено у $CONFIG_FILE"
}

# Етап 2: Встановлення інструментів та ініціалізація проєкту
install_tools() {
  echo "[Етап 2] Встановлення Foundry, Bun, Drosera і ініціалізація проєкту"

  cd ~

  # Foundry
  curl -L https://foundry.paradigm.xyz | bash
  export PATH="$HOME/.foundry/bin:$PATH"
  echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> ~/.bashrc
  source ~/.bashrc
  foundryup

  # Bun
  curl -fsSL https://bun.sh/install | bash
  export PATH="$HOME/.bun/bin:$PATH"
  echo 'export PATH="$HOME/.bun/bin:$PATH"' >> ~/.bashrc

  # Drosera
  curl -L https://app.drosera.io/install | bash
  export PATH="$HOME/.drosera/bin:$PATH"
  echo 'export PATH="$HOME/.drosera/bin:$PATH"' >> ~/.bashrc
  droseraup

  # Створення директорії
  mkdir -p ~/my-drosera-trap
  cd ~/my-drosera-trap

  # Forge ініціалізація
  forge init -t drosera-network/trap-foundry-template

  # Компіляція
  bun install
  forge build

	cd ~
	echo "Щоб зміни вступили в силу, виконайте:"
	echo "source ~/.bashrc"
}

init_project() {
	echo "[Етап 3] ініціалізація проєкту"

  # Застосування drosera apply
  apply_drosera

	# Тепер парсимо адресу
	trap_address=$(grep '^address' $HOME/my-drosera-trap/drosera.toml | sed -E 's/.*"([^"]+)"/\1/')
	if [[ -n "$trap_address" ]]; then
		echo "DROSERA_ADDRESS=\"$trap_address\"" >> "$CONFIG_FILE"
		echo "Trap address збережено: $trap_address"
	else
		echo "Не вдалося знайти адресу у виводі drosera apply."
		exit 1
	fi

  boost_drosera

	DROSERA_TOML_PATH="$HOME/my-drosera-trap/drosera.toml"

	if [[ ! -f "$DROSERA_TOML_PATH" ]]; then
		echo "Файл drosera.toml не знайдено: $DROSERA_TOML_PATH"
		exit 1
	fi
	# Заміна або додавання private_trap
	if grep -q "^private_trap" "$DROSERA_TOML_PATH"; then
		sed -i 's/^private_trap.*/private_trap = true/' "$DROSERA_TOML_PATH"
	else
		echo -e "\nprivate_trap = true" >> "$DROSERA_TOML_PATH"
	fi

	# Заміна або додавання whitelist
	if grep -q "^whitelist" "$DROSERA_TOML_PATH"; then
		sed -i "s|^whitelist.*|whitelist = [\"$PUBLIC_KEY\"]|" "$DROSERA_TOML_PATH"
	else
		echo -e "whitelist = [\"$PUBLIC_KEY\"]" >> "$DROSERA_TOML_PATH"
	fi
	echo "Оновлення drosera.toml завершено!"
	sleep 5
	apply_drosera
}

# Етап 4: Завантаження drosera-operator та налаштування firewall
setup_operator_and_firewall() {
  echo "[Етап 4] Завантаження drosera-operator і налаштування Firewall"

  load_private_key
  cd ~

  # Завантаження drosera-operator
  curl -LO https://github.com/drosera-network/releases/releases/download/v1.16.2/drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
  tar -xvf drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz

  # Docker
  docker pull ghcr.io/drosera-network/drosera-operator:latest

  # Firewall
  echo "[Firewall] Увімкнення UFW та відкриття портів..."
  sudo ufw allow ssh
  sudo ufw allow 22
  sudo ufw allow 31313/tcp
  sudo ufw allow 31314/tcp
  sudo ufw --force enable

  # Реєстрація
  ./drosera-operator register \
      --eth-rpc-url https://ethereum-holesky-rpc.publicnode.com \
      --eth-private-key "$PRIVATE_KEY"
}

# Етап 5: Клонування Drosera-Network
clone_drosera_network() {
  echo "[Етап 5] Клонування Drosera-Network"

  cd ~
  git clone https://github.com/0xmoei/Drosera-Network

  echo "[Етап 5] Створення і заповнення .env файлу"

  cd ~/Drosera-Network
  cp .env.example .env

  load_private_key

  VPS_IP=$(curl -s ifconfig.me)
  if [[ -z "$VPS_IP" ]]; then
      echo "❌ Не вдалося отримати публічну IP адресу"
      exit 1
  fi

  sed -i "s|^ETH_PRIVATE_KEY=.*|ETH_PRIVATE_KEY=$PRIVATE_KEY|" .env
  sed -i "s|^VPS_IP=.*|VPS_IP=$VPS_IP|" .env

  echo "✅ .env оновлено:"
  echo "  ETH_PRIVATE_KEY=$PRIVATE_KEY"
  echo "  VPS_IP=$VPS_IP"

  echo "[Етап 6] Запуск docker-compose і optin"

  cd ~/Drosera-Network
  docker-compose up -d

  optin_drosera
}

apply_drosera() {
	load_private_key
	cd ~/my-drosera-trap

	DROSERA_PRIVATE_KEY="$PRIVATE_KEY" drosera apply

	cd ~
}

boost_drosera() {
  load_private_key
  load_drosera_key

  cd ~/my-drosera-trap

  read -p "Введіть кількість ETH: " ETH_AMOUNT
  DROSERA_PRIVATE_KEY="$PRIVATE_KEY" drosera bloomboost --trap-address "$DROSERA_ADDRESS" --eth-amount "$ETH_AMOUNT"

  cd ~
}

optin_drosera() {
  	load_private_key
	load_drosera_key

	cd ~/Drosera-Network

  drosera-operator optin \
        --eth-rpc-url https://ethereum-holesky-rpc.publicnode.com \
        --eth-private-key "$PRIVATE_KEY" \
        --trap-config-address "$DROSERA_ADDRESS"

	cd ~
}

show_menu() {
	# === Головне меню ===
	echo "Оберіть етап для виконання:"
	echo "0 - Інсталювати поетапно"
	echo "1 — Зберегти приватний та публічний ключ у файл"
	echo "2 — Встановити Foundry, Bun, Drosera, ініціалізувати проєкт"
	echo "3 — Iніціалізувати проєкт"
	echo "4 — Завантажити drosera-operator, налаштувати firewall і зареєструвати ноду"
	echo "5 — Клонувати Drosera-Network та Заповнити .env, Запустити docker-compose і optin"
	echo "00 - Apply"
	echo "01 - boost"
	echo "02 - optin"
}

handle_step() {
	case "$1" in
		0) install ;;
		1) save_keys ;;
		2) install_tools ;;
		3) init_project ;;
		4) setup_operator_and_firewall ;;
		5) clone_drosera_network ;;
		00) apply_drosera ;;
		01) boost_drosera ;;
		02) optin_drosera ;;
		*) show_menu ;;
	esac
}

if [[ -n "$1" ]]; then
  handle_step "$1"
	exit
fi

show_menu
read -r -p "Ваш вибір (1-4): " step
handle_step $step
