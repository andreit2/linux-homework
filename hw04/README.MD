1. Определить алгоритм с наилучшим сжатием.
Создаем пул zfs_pool:
```
zpool create zfs_pool mirror sdb sdc
```
Создаем разные файловые системы:
```
sudo zfs create zfs_pool/test_gzip
sudo zfs set compression=on zfs_pool/test_gzip
sudo zfs set compress=gzip zfs_pool/test_gzip
```
