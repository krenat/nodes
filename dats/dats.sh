#!/bin/bash

# Кольори
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_DIR="$HOME/p-dats"

prepare() {
  packages=("docker:docker.io" "libasound:libasound2" "libgbm:libgbm1" "xauth:xauth")

  echo -e "${BLUE}Встановлення залежностей...${NC}"

  TOTAL=${#packages[@]}
  CURRENT=0
  BAR_WIDTH=40

  sudo apt update >/dev/null 2>&1

  draw_progress() {
    local progress=$1
    local done=$((progress * BAR_WIDTH / TOTAL))
    local left=$((BAR_WIDTH - done))
    local fill
    fill=$(printf "%${done}s")
    local empty
    empty=$(printf "%${left}s")
    printf "\r[%s%s] %d/%d" "${fill// /#}" "${empty// /-}" "$progress" "$TOTAL"
  }

  for pkg in "${packages[@]}"; do
    IFS=":" read -r pkg_name pkg_real <<< "$pkg"
      check_and_install "$pkg_name" "$pkg_real"
    ((CURRENT++))
    draw_progress "$CURRENT"
  done
}

check_and_install() {
  if ! dpkg -s "$1" &> /dev/null; then
      echo "$1 не знайдено. Встановлюємо..."
      sudo apt install -y "$2" >/dev/null 2>&1
  fi
}

download_and_install_dats() {
  echo -e "${BLUE}Завантаження та сстановлення dats...${NC}"
  cd "$PROJECT_DIR"
  wget --show-progress -O dats_install.deb https://dl.datsproject.io/evm-linux-deb
  sudo apt install ./dats_install.deb
  cd
}

show_menu() {
	echo "Оберіть етап для виконання:"
	echo "p - інсталювати необхідні залежності"
	echo "d - завантажити та інсталювати файл проєкту"
	echo "x - завершити"

	read -r -p "Ваш вибір: " step
  handle_step "$step"
}

handle_step() {
	case "$1" in
		p) prepare ;;
    d) download_and_install_dats ;;
    x) exit ;;
    *) show_menu ;;
	esac
}

if [[ -n "$1" ]]; then
  handle_step "$1"
	exit
fi

show_menu