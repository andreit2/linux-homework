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
1.1 С помощью setsebool
правим конфиг nginx, сменив порт на нестандартный
```
server {
        listen       7777;
        #listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;
```

Сервис nginx не стартует, смотрим логи
```
type=AVC msg=audit(1634714891.519:484): avc:  denied  { name_bind } for  pid=2051 comm="nginx" src=7777 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
type=SYSCALL msg=audit(1634714891.519:484): arch=c000003e syscall=49 success=no exit=-13 a0=6 a1=55a14d21c738 a2=10 a3=7ffed84a1d30 items=0 ppid=1 pid=2051 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)
```
Вариант решения проблемы команда:
```setsebool -P nis_enabled 1```
Стартуем nginx
```
[vagrant@hw13 ~]$ sudo systemctl start nginx
[vagrant@hw13 ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2021-10-20 09:46:42 UTC; 3s ago
  Process: 2305 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 2303 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 2302 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 2307 (nginx)
   CGroup: /system.slice/nginx.service
           ├─2307 nginx: master process /usr/sbin/nginx
           └─2308 nginx: worker process
```
Проверяем на каком порту:
```
[vagrant@hw13 ~]$ sudo netstat -tulpn | grep nginx
tcp        0      0 0.0.0.0:7777            0.0.0.0:*               LISTEN      2307/nginx: master
```

С вывода видно что nginx работает на нестандартном 7777 порту.

1.2 добавление нестандартного порта в имеющийся тип

Вернем ```setsebool -P nis_enabled 1 обратно в 0 ```:
```
[vagrant@hw13 ~]$ sudo setsebool -P nis_enabled 0
```
Мы опять все поломали
```
[vagrant@hw13 ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Wed 2021-10-20 10:28:00 UTC; 14s ago
  Process: 2305 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 2699 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
  Process: 2698 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 2307 (code=exited, status=0/SUCCESS)

Oct 20 10:28:00 hw13 systemd[1]: Starting The nginx HTTP and reverse proxy server...
Oct 20 10:28:00 hw13 nginx[2699]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Oct 20 10:28:00 hw13 systemd[1]: nginx.service: control process exited, code=exited status=1
Oct 20 10:28:00 hw13 nginx[2699]: nginx: [emerg] bind() to 0.0.0.0:7777 failed (13: Permission denied)
Oct 20 10:28:00 hw13 nginx[2699]: nginx: configuration file /etc/nginx/nginx.conf test failed
Oct 20 10:28:00 hw13 systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
Oct 20 10:28:00 hw13 systemd[1]: Unit nginx.service entered failed state.
Oct 20 10:28:00 hw13 systemd[1]: nginx.service failed.
```
Выясним на каком порту можно держать nginx

```
[vagrant@hw13 ~]$ sudo semanage port -l | grep http_port
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
```

Порта 7777 нету в данном списке, значит надо добавить:

```
[vagrant@hw13 ~]$ sudo semanage port -a -t http_port_t -p tcp 7777
```
Запускаем, проверяем, работает.

```
[vagrant@hw13 ~]$ sudo systemctl start nginx
[vagrant@hw13 ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2021-10-20 10:33:25 UTC; 6s ago
  Process: 2729 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 2727 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 2726 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 2731 (nginx)
   CGroup: /system.slice/nginx.service
           ├─2731 nginx: master process /usr/sbin/nginx
           └─2733 nginx: worker process

Oct 20 10:33:25 hw13 systemd[1]: Starting The nginx HTTP and reverse proxy server...
Oct 20 10:33:25 hw13 nginx[2727]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Oct 20 10:33:25 hw13 nginx[2727]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Oct 20 10:33:25 hw13 systemd[1]: Started The nginx HTTP and reverse proxy server.
```

1.3 формирование и установка модуля SELinux

Вернем шаг 1.2 в исходное состояние:
```
[vagrant@hw13 ~]$ sudo semanage port -d -t http_port_t -p tcp 7777
```
Посмотрим, какой модуль надо доустановить.

```
[vagrant@hw13 ~]$ ls -Z /usr/sbin/nginx
-rwxr-xr-x. root root system_u:object_r:httpd_exec_t:s0 /usr/sbin/nginx
```
```
[root@hw13 vagrant]# audit2allow -M httpd_add --debug < /var/log/audit/audit.log
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i httpd_add.pp
```
Выполняем команду согласно рекомендации и проверяем:
```
[root@hw13 vagrant]# semodule -i httpd_add.pp
[root@hw13 vagrant]# systemctl start nginx
[root@hw13 vagrant]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2021-10-20 10:33:25 UTC; 28min ago
  Process: 2729 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 2727 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 2726 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 2731 (nginx)
   CGroup: /system.slice/nginx.service
           ├─2731 nginx: master process /usr/sbin/nginx
           └─2733 nginx: worker process

Oct 20 10:33:25 hw13 systemd[1]: Starting The nginx HTTP and reverse proxy server...
Oct 20 10:33:25 hw13 nginx[2727]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Oct 20 10:33:25 hw13 nginx[2727]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Oct 20 10:33:25 hw13 systemd[1]: Started The nginx HTTP and reverse proxy server.
```
из вывода видно что nginx работает, проверяем на каком порту:

```
[root@hw13 vagrant]# netstat -tulpn | grep nginx
tcp        0      0 0.0.0.0:7777            0.0.0.0:*               LISTEN      2731/nginx: master
```
