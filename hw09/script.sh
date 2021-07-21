#!/bin/bash

if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null;
then
    trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
       # What to do
        ./sendmail.sh ${lockfile}
   rm -f "$lockfile"
   trap - INT TERM EXIT
else
   echo "Failed to acquire lockfile: $lockfile."
   echo "Held by $(cat $lockfile)"
fi

if
    sudo find ./ -name log_stat.sh -exec {} \; > log_stat.txt && mailx root@localhost < log_stat.txt && rm log_stat.txt access.log
then
    exit 0
   else 
echo "Error."
fi
#Объявляем значение X и Y
X=10
Y=10
# Указываем имя файла
F=access-4560-644067.log
#task () {
echo "Request generated:" && date && echo "Log started:" && cat $F | awk '{print $4$5}' | head -n 1
echo "-----------------------------------------------------"
#X IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
echo $X "IP adrreses with the most requestes :" && cat $F | awk -F" " '{print $1}' | sort | uniq -c | sort -rn | head -n $X | awk '{print $2 " had " $1 " requests"}' | column -t 
echo "-----------------------------------------------------"
#Y запрашиваемых адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
echo $Y "most requested URLs:" && cat $F | awk '{print $7}' | sort | uniq -c | sort -rn | head -n $Y | awk '{print $2 " requested " $1 " times. "}' | column -t
echo "-----------------------------------------------------"
#все ошибки c момента последнего запуска
echo "All errors:" && cat $F | awk '{print $9}' | grep ^4 | sort | uniq -c | sort -rn | awk '{print $2 " was " $1 " times."}' | column -t && cat $F | awk '{print $9}' | grep ^5 | sort | uniq -c | sort -rn | awk '{print $2 " was " $1 " times."}' | column -t
echo "-----------------------------------------------------"
#список всех кодов возврата с указанием их кол-ва с момента последнего запуска
echo "HTTP statuses:" && cat $F | awk '{print $9}'| grep -v "-" | sort | uniq -c | sort -rn | awk '{print $2 " was " $1 " times."}' | column -t
#}
