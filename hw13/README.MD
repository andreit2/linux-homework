## Домашнее задание: Практика с SELinux
# 1. Запустить nginx на нестандартном порту 3-мя разными способами:
- переключатели setsebool;
- добавление нестандартного порта в имеющийся тип;
- формирование и установка модуля SELinux. 

# 2. Обеспечить работоспособность приложения при включенном selinux.
- развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems;
- выяснить причину неработоспособности механизма обновления зоны (см. README);
- предложить решение (или решения) для данной проблемы;
- выбрать одно из решений для реализации, предварительно обосновав выбор;
- реализовать выбранное решение и продемонстрировать его работоспособность. 

## Решение:
Подготовим виртуалку и установим необходимые пакеты: ```nginx, net-tools, setools-console, policycoreutils-python```

```
[vagrant@hw13 ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2021-10-19 16:41:12 UTC; 2min 47s ago
  Process: 13308 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 13306 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 13305 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 13310 (nginx)
```
Проверяем на каком порту запущен nginx
```
[vagrant@hw13 ~]$ sudo netstat -tulpn | grep nginx
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      13310/nginx: master
tcp6       0      0 :::80                   :::*                    LISTEN      13310/nginx: master
```
1.1 переключатели setsebool
правим конфиг nginx, сменив порт на нестандартный
```
server {
        listen       7777;
        #listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;
```

