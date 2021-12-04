#!/usr/bin/env bash

work_time=25                   # Working duration
break_time=5                   # Break duration
lbreak_time=30                 # Long break duration#

work_icon="messagebox_warning"
break_icon="dialog-information"
lbreak_icon="dialog-information"

# Comente a linha abaixo para notificações em português
ENG="1"

red="#50FA7B"
green="#FF5555"
WORK="%{F$red}%{F-}"
PAUSE="%{F$green}%{F-}"
IDLE=""

# red=$(awk 'NR==2' < ~/.cache/wal/colors)
# green=$(awk 'NR==3' < ~/.cache/wal/colors)
# WORK="%{F$red}%{T4}%{T-}%{F-}"
# PAUSE="%{F$green}%{T4}%{T-}%{F-}"
# IDLE="%{T7}%{T-}"

# _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
#  End of configuration
# _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

FILE="/tmp/start_pomo"
PFILE="/tmp/pause_pomo"

if [ -f "$FILE" ]; then
    i=$(cut -d ' ' -f1 "$FILE")
    left=$(cut -d ' ' -f2 "$FILE")
else
    i=1
    left=0
    if [ -f "$PFILE" ]; then
        rm "$PFILE"
    fi
fi

timer() {
    start=$(date +%s);
    if [ "$left" -ne "0" ]; then
        end=$(( start + left ));
    else
        end=$(( start + $1 * 60 ));
        printf "%s %02d:%02d\n" "$2" "$1" "00"
    fi

    now="$start";

    while [ "$now" -lt "$end" ]; do

        while [ -f "$PFILE" ] && [ -f "$FILE" ]; do
            sleep 1
            now=$(date +%s);
            end=$(( now + left ))
        done

        if [ ! -f "$FILE" ]; then
            return

        else
            echo "$i $left" > "$FILE"
            sleep 1;
            now=$(date +%s);
            left=$(( end-now ))

            printf "%s %02d:%02d\n" "$2" "$(( left / 60 ))" "$(( left % 60 ))"
        fi
    done
}

send_noti() {
    if [ ! -f "$FILE" ] || [ "$left" -ne "0" ]; then
        return
    fi
    if [ "$ENG" = "1" ]; then
        case "$1" in
            'w')
                notify-send 'Work Time' "Work for the next $work_time minutes" -i "$work_icon"
                ;;
            'p')
                notify-send 'Time to take a break' "Take a break for the next $break_time minutes" -i "$break_icon"
                ;;
            'l')
                notify-send 'Long break' "Take a long for the next $lbreak_time minutes" -i "$lbreak_icon"
                ;;
        esac
    else
        case "$1" in
            'w')
                notify-send 'Hora de trabalhar' "Trabalhe pelos próximos $work_time minutos" -i messagebox_warning
                ;;
            'p')
                notify-send 'Hora de descançar' "Descanse pelos próximos $break_time minutos" -i dialog-information
                ;;
            'l')
                notify-send 'Descanço longo' "Descanse bem pelos próximos $lbreak_time minutos" -i dialog-information
                ;;
        esac
    fi

}

step(){
    case "$1" in
        1 | 3 | 5)
            send_noti 'w'
            timer "$work_time" "$WORK"
            ;;
        2 | 4)
            send_noti 'p'
            timer "$break_time" "$PAUSE"
            ;;
        6)
            send_noti 'l'
            timer "$lbreak_time" "$PAUSE"
            ;;
        7)
            i=0
            ;;
    esac
    (( i++ ))
}

while true
do
    while [ ! -f "$FILE" ]; do
        i=1
        left=0
        echo "$IDLE"
        sleep 1
    done
    step "$i"
done
