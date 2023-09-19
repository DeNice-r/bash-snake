#!/bin/bash
# Обмежена реалізація структури Черга (FIFO) на основі рядка, оскільки можливості мови bash обмежені

# Додавання координати в кінець списку координат
coords_append() {
    local x=$1
    local y=$2
    coordinates+="($x,$y) "
}

# Перевірка чи координати містяться в списку координат
coords_contain() {
    local x="$1"
    local y="$2"
    local element_to_check="($x,$y)"
    # echo "Ele: $element_to_check"
    # Перевірка чи координати містяться в списку координат за допомогою регулярного виразу
    if [[ $coordinates == *"$element_to_check"* ]]; then
        return 0
    else
        return 1
    fi
}

# Видалення найстарішої координати зі списку координат
coords_pop() {
    # Отримання найстарішої координати
    local temp="${coordinates%% *}"
    
    # Видалення дужок з координати та занесення в глобальну змінну
    temp="${temp//(/}"
    last_coords="${temp//)/}"
    
    # Видалення найстарішої координати зі списку координат
    coordinates="${coordinates#* }"
}
