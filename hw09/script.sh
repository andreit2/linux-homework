#!/bin/bash


#Переменные
lockfile=./lockfile
X=10
Y=10
F=access-4560-644067.log
env=.env
timestamp=`cat $env | grep timestamp | awk -F"=" '{ print $2}'`
number_previous=`cat $env | grep number | awk -F"=" '{ print $2}'`
number_actual=`cat $F | wc -l`
parser() {
#echo "Request generated:" && date && echo "Log started:" && cat $F | awk '{print $4$5}' | head -n 1
#echo "-----------------------------------------------------"
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
}
time() {
    date_actual=`date '+%Y-%m-%d %H:%M:%S'`
    echo "Request generated: $timestamp - $date_actual" >> mail.txt
    sed -i "s/timestamp=.*/timestamp=$date_actual/g" $env
}
log() {
    if (($number_previous > $number_actual));
	then
	    number_previous=0
	    let n=$number_actual
	else
	    let n=$number_actual-$number_previous
	    let number_previous=$number_actual-$n+1
    fi
    sed -i "s/num=.*/num=$num_curr/g" $envfile
}

start() {
    if ( set -o noclobber; echo `ps -a | grep script.sh`  > "$lockfile") 2> /dev/null;
        then
        trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
        while true
            do
            log
            parser >> mail.txt
            mail -s "Statistic" root@localhost < mail.txt
            exit
         done
         rm -f "$lockfile"
         trap - INT TERM EXIT
    else
        echo "Failed to acquire lockfile: $lockfile."
        echo "Held by $(cat $lockfile)"
    fi
}
start
