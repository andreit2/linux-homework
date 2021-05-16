### 1. Определить алгоритм с наилучшим сжатием.

Создаем пул zfs_pool:
```
zpool create zfs_pool mirror sdb sdc
```
Создаем разные файловые системы:
```
sudo zfs create zfs_pool/test_gzip
sudo zfs set compression=on zfs_pool/test_gzip
sudo zfs set compress=gzip zfs_pool/test_gzip
sudo zfs create zfs_pool/test_gzip-1
sudo zfs set compression=on zfs_pool/test_gzip-1
sudo zfs set compress=gzip-1 zfs_pool/test_gzip-1
sudo zfs create zfs_pool/test_gzip-9
sudo zfs set compression=on zfs_pool/test_gzip-9
sudo zfs set compress=gzip-9 zfs_pool/test_gzip-9
sudo zfs create zfs_pool/test_lz4
sudo zfs set compression=on zfs_pool/test_lz4
sudo zfs set compress=lz4 zfs_pool/test_lz4
sudo zfs create zfs_pool/test_lzjb
sudo zfs set compression=on zfs_pool/test_lzjb
sudo zfs set compress=lzjb zfs_pool/test_lzjb
sudo zfs create zfs_pool/test_zle
sudo zfs set compression=on zfs_pool/test_zle
sudo zfs set compress=zle zfs_pool/test_zle
```
скачаваем файл “Война и мир” и располагаем на файловых системах
```
curl -o "War_and_Peace.txt" -J -L https://www.gutenberg.org/cache/epub/2600/pg2600.txt
sudo cp War_and_Peace.txt /zfs_pool/test_gzip
sudo cp War_and_Peace.txt /zfs_pool/test_gzip-1
sudo cp War_and_Peace.txt /zfs_pool/test_gzip-9
sudo cp War_and_Peace.txt /zfs_pool/test_lz4
sudo cp War_and_Peace.txt /zfs_pool/test_lzjb
sudo cp War_and_Peace.txt /zfs_pool/test_zle
```
Сравниваем выводы команд:
```
zfs get compression,compressratio

NAME                  PROPERTY       VALUE     SOURCE
zfs_pool              compression    off       default
zfs_pool              compressratio  1.08x     -
zfs_pool/test_gzip    compression    gzip      local
zfs_pool/test_gzip    compressratio  1.08x     -
zfs_pool/test_gzip-1  compression    gzip-1    local
zfs_pool/test_gzip-1  compressratio  1.08x     -
zfs_pool/test_gzip-9  compression    gzip-9    local
zfs_pool/test_gzip-9  compressratio  1.08x     -
zfs_pool/test_lz4     compression    lz4       local
zfs_pool/test_lz4     compressratio  1.08x     -
zfs_pool/test_lzjb    compression    lzjb      local
zfs_pool/test_lzjb    compressratio  1.07x     -
zfs_pool/test_zle     compression    zle       local
zfs_pool/test_zle     compressratio  1.08x     -
```
```
cd /zfs_pool
du -s *
1182	test_gzip
1182	test_gzip-1
1182	test_gzip-9
1182	test_lz4
1182	test_lzjb
1182	test_zle
```
#### Вывод: Для текстового файла рассмотренные алгоритмы сжатия gzip, gzip-1, gzip-9, lz4, lzjb, zle имеют одинаковую степень сжатия. 
