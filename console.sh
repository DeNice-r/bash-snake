#!/bin/bash

# Перенесення курсора на задану позицію
move_cursor_to_position() {
    local row="$1"
    local col="$2"
    
    # Move cursor to the specified row and column
    echo -e -n "\e[${row};${col}H"
}

# Запис символу на задану позицію
write_char_at_position() {
    local row="$1"
    local col="$2"
    local char="$3"
    
    move_cursor_to_position "$row" "$col"
    
    echo -n "$char"
}

# Відображення границь вікна
draw_window_borders() {
    local height="$1"
    local width="$2"
    local char="$3"
    
    # Малювання вертикальних границь
    for ((i=0; i < height; i++)); do
        write_char_at_position "$i" 0 "$char"
        write_char_at_position "$i" "$((width - 1))" "$char"
    done
    
    # Малювання горизонтальних границь
    for ((i=0; i < width; i++)); do
        write_char_at_position 0 "$i" "$char"
        write_char_at_position "$((height - 1))" "$i" "$char"
    done
    
}

# Завершення гри
exit_on_input() {
    local row="$1"
    
    move_cursor_to_position "$row" 0
    # Відновлення видимості курсора
    tput cnorm
    # Відображення повідомлення про завершення гри
    read -n 1 -s -r -p "Press any key to exit..."
    
    clear
    move_cursor_to_position 0 0
}
