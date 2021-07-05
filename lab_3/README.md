# Лабораторная работа 3.

## Цели работы

Работа с LVM.

## Задачи

1. Уменьшить том под / до 8G
2. Выделить том под /var
3. /var - сделать в mirror
4. Выделить том под /home
5. /home - сделать том для снэпшотов
6. Прописать монтирование в fstab
7. Создать файлы в /home/
8. Снять снэпшот
9. Удалить часть файлов
10. Восстановиться со снэпшота

---

[Лог выполнения работы](./files/typescript)

---

## Выполнение

### Уменьшить том под / до 8G

1. Создаем отдельную структуру LVM, на которую будем проводить копирование файлов перед изменением раздела.

        pvcreate /dev/sdb
        vgcreate vgr /dev/sdb
        lvcreate -n lvr -l +100%FREE /dev/vgr
        
2. Форматируем свежесозданный раздел в XFS, монтируем в /mnt и снимаем дамп с текущего корня.

        mkfs.xfs /dev/vgr/lvr
        mount /dev/vgr/lvr /mnt
        xfsdump -J - /dev/cl/root | xfsrestore -j - /mnt

3. Монтируем часть разделов (включая /boot) в /mnt и чрутимся внутрь.

        for i in /proc /sys /dev /run /boot; do mount --bind $i /mnt$i; done
        chroot /mnt
        
4. Генерируем новый конфиг grub2 и обновляем initramfs.
        
        cd /boot
        grub2-mkconfig -o ./grub2/grub.cfg
        for i in `ls initramfs-*img`; do dracut -v $i `echo $i | sed "s/initramfs-//g;s/.img//g"` --force; done
        
5. Выходим из chroot, перезагружаем машину, командой `lsblk` проверяем что загрузились действительно с lvr.

6. Изменяем изначальный раздел - пересоздаем LV с размером в 8 Gb.

        lvremove /dev/cl/root
        lvcreate -n root -L 8G /dev/cl
        
7. Повторяем действия 2-4, но теперь уже в качестве источника дампа выступает `/dev/vgr/lvr`, а назначением - `/dev/cl/root`.

### Выделить том под /var (с зеркалированием)

1. Создаем зеркало, форматируем в xfs.

        pvcreate /dev/sd{c,d}
        vgcreate vgv /dev/sd{c,d}
        lvcreate -L 950M -m1 -n lvv vgv
        mkfs.ext4 /dev/vgv/lvv

2. Монтируем в /mnt, переносим все с текущего /var

        mount /dev/vgv/lvv /mnt
        cp -aR /var/* /mnt

3. Удаляем содержимое изначальной директории /home, монтируем туда наш раздел с lvm, обновляем fstab.

        rm -rf /var/*
        umount /mnt
        mount /dev/vgv/lvv /var
        echo "`blkid | grep lvv | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
        
4. Перезагружаем машину.
5. Удаляем неактуальную группу томов.

        lvremove lvr
        vgremove vgr
        pvremove /dev/sdb

### Выделить том под /home

1. Создаем том, форматируем в xfs.

        lvcreate -n lvh -L 2G /dev/cl
        mkfs.xfs /dev/cl/lvh

2. Монтируем в /mnt, копируем данные с оригинального /home.

        mount /dev/cl/lvh /mnt
        cp -aR /home/* /mnt

3. Удаляем содержимое изначальной директории /home, монтируем туда наш раздел с lvm, обновляем fstab.

        rm -rf /home/*
        umount /mnt
        mount /dev/cl/lvh /home
        echo "`blkid | grep lvh | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab

### Работа со снэпшотами

1. Создаем файлы в /home

        touch /home/file_{1..30}

2. Создаем снимок

        lvcreate -L 100MB -s -n hsnp /dev/cl/lvh

3. Удаляем часть файлов

        rm /home/file_{1..15}
        
4. Восстанавливаем файлы - отмонтируем /home, применяем ранее созданный снапшот, монтируем /home обратно.

        umount /home
        lvconvert --merge /dev/cl/hsnap
        mount /home
        
5. Проверяем восстановление файлов.
        
