#!/bin/bash

set -o allexport
source console.sh
source variables.sh
source coordinates_functions.sh
set +o allexport


# Оголошення глобальних змінних
export coordinates="" last_coords=""
apple_x=0
apple_y=0
score=0
highscore=0


# Отримання рахунку з файлу
if [ -f "$HIGHSCORE_FILE" ] ; then
    highscore=$(cat "$HIGHSCORE_FILE")
fi


# Створення яблука
spawn_apple() {
    apple_x=$((RANDOM % (WINDOW_HEIGHT-3) + 2))
    apple_y=$((RANDOM % (WINDOW_WIDTH-3) + 2))

    # Якщо координати яблука збігаються з координатами гравця, то генеруємо нові координати
    while coords_contain "$apple_x" "$apple_y" ; do
        apple_x=$((RANDOM % (WINDOW_HEIGHT-3) + 2))
        apple_y=$((RANDOM % (WINDOW_WIDTH-3) + 2))
    done

    # Відображення яблука
    write_char_at_position "$apple_x" "$apple_y" "$APPLE_CHAR"
}

# Головний цикл гри
run_game_loop() {
    # Встановлення початкових координат гравця в центрі вікна
    local x=$((WINDOW_HEIGHT/2))
    local y=$((WINDOW_WIDTH/2))

    # Створення гравця
    coords_append "$x" "$y"
    write_char_at_position "$x" "$y" "$PLAYER_CHAR"

    # Створення яблука
    spawn_apple

    # Відображення рекорду
    write_char_at_position $((WINDOW_HEIGHT/2 + 1)) $((WINDOW_WIDTH+5)) "Highest score: $highscore"

    
    # Цикл гри
    while true; do
        # Зчитування вводу з клавіатури з таймаутом
        read -r -t "$GAME_TICK_LENGTH" -n 1 -s holder && input="$holder"
        
        # Якщо ввід не є прийнятним, він ігнорується
        if [[ ! $input =~ [^wasde] ]]; then
            direction="$input"
        fi
        
        # В залежності від напрямку руху гравця, змінюються його координати.
        # Також тут реалізовано вихід з гри та ігронування вводу доки він не буде прийнятним
        case "$direction" in
            w) ((x--));;
            s) ((x++));;
            a) ((y--));;
            d) ((y++));;
            e) break;;
            *) continue
                # *)
        esac

        # Якщо відлагоджувальний режим включений, то відображається додаткова інформація
        if [ "$DEBUG" -eq 0 ] ; then
            write_char_at_position $((WINDOW_HEIGHT+1)) "$WINDOW_WIDTH" "LC: $last_coords"
            write_char_at_position $((WINDOW_HEIGHT+2)) "$WINDOW_WIDTH" "RX: $rx"
            write_char_at_position $((WINDOW_HEIGHT+3)) "$WINDOW_WIDTH" "RY: $ry"
            write_char_at_position $((WINDOW_HEIGHT+4)) "$WINDOW_WIDTH" "Coords: $coordinates"
        fi

        # Відображення рахунку
        write_char_at_position $((WINDOW_HEIGHT/2)) $((WINDOW_WIDTH+5)) "Score: $score"
        
        # Якщо гравець не з'їв яблуко, то видаляється хвіст змії
        if [ "$x" -ne "$apple_x" ] || [ "$y" -ne "$apple_y" ] ; then
            coords_pop
            IFS=',' read -r rx ry <<< "$last_coords"
            write_char_at_position "$rx" "$ry" " "
        fi
        
        # Перевірка чи гравець не вийшов за межі вікна та перенесення на протилежний бік вікна
        if [ "$x" -lt 2 ]; then
            x=$((WINDOW_HEIGHT-2))
        fi
        
        if [ "$x" -gt $((WINDOW_HEIGHT-2)) ]; then
            x=2
        fi
        
        if [ "$y" -lt 2 ]; then
            y=$((WINDOW_WIDTH-2))
        fi
        
        if [ "$y" -gt $((WINDOW_WIDTH-2)) ]; then
            y=2
        fi
        
        # Перевірка чи гравець не зіткнувся з собою (тобто програв)
        if coords_contain "$x" "$y" ; then
            write_char_at_position $((WINDOW_HEIGHT/2)) $((WINDOW_WIDTH/2-3)) "*DEAD*"
            break
        fi

        # Додавання нової координати гравця та відображення нової голови змії
        coords_append "$x" "$y"
        write_char_at_position "$x" "$y" "$PLAYER_CHAR"

        # Якщо гравець з'їв яблуко, то генерується нове яблуко та збільшується рахунок
        if [ "$x" -eq "$apple_x" ] && [ "$y" -eq "$apple_y" ] ; then
            spawn_apple
            score=$((score+1))
        fi

        # Видалення хвоста змії
        if ! coords_contain "$rx" "$ry" ; then
            write_char_at_position "$rx" "$ry" " "
        fi
    done

    if [ "$highscore" -lt "$score" ] ; then
        echo "$score" > "$HIGHSCORE_FILE"
    fi
}
