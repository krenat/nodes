#!/bin/bash

# ==== Конфіг ====
SCRIPT_PATH="/home/root/dria/analytics/scheduler.sh"
LOG_DIR="/home/root/dria/analyitcs/logs"
mkdir -p "$LOG_DIR"

# ==== Функція генерації відкладеного запуску ====
schedule_job() {
  local start=$1
  local end=$2
  local delay_min=$((RANDOM % 51 + 10))  # від 10 до 60 хв

  local label="dria_${start}_${end}"
  local now=$(date +%H:%M)
  local run_time=$(date -d "$delay_min minutes" +%H:%M)
  local log_file="$LOG_DIR/${label}_$(date +%F).log"

  echo "$SCRIPT_PATH $start $end >> $log_file 2>&1" | at now + $delay_min minutes
  echo "⏳ Заплановано $label через $delay_min хв (о $run_time)"
}

# ==== Основна логіка ====
for i in $(seq 0 10 90); do
  schedule_job "$i" "$((i + 9))"
done

schedule_job 100 100
