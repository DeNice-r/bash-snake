#!/bin/bash

# Імпортування функцій та змінних з інших файлів
set -o allexport
source console.sh
source variables.sh
source game.sh
set +o allexport

# Встановлення прозорого курсора
tput civis

clear

# Встановлення ігрового розмірів вікна
draw_window_borders "$WINDOW_HEIGHT" "$WINDOW_WIDTH" "$WINDOW_CHAR"

# Запуск головного циклу гри
run_game_loop

# Завершення гри
exit_on_input "$WINDOW_HEIGHT"
