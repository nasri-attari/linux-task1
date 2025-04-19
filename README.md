## Part 1: LVM 

---

###  Commands and Explanation:

```bash
# Add new virtual disk for second disk (settings,storage)

# create physical volume 
pvcreate /dev/sdb

# create volume group
vgcreate -s 16M vg1 /dev/sdb

# create logical volume with 50 extends 
lvcreate -l 50 -n lv1 vg1

# format logical volume as ext4
mkfs -t ext4 /dev/vg1/lv1

# get the id for lv1 
blkid /dev/vg1/lv1

# add to fstab file to mount automatically when reboot 
mkdir /mnt/data
vi /etc/fstab
(ADD:  UUID=4b50fbd0-3f78-4d73-9ad1-83fea611109d /mnt/data               ext4    defaults        0 0)

# mount lines in fstab files without reboot
mount -a
```

---

## Part 2: Users, Groups, and Permissions

---

### Commands and Explanation:

```bash
# add user1
useradd user1 -u 601 -s /sbin/nologin

# user1 password
passwd user1    (write: 'redhat')

# add new group
groupadd TrainingGroup

# add user1 to TrainigGroup
usermod -aG TrainingGroup user1

# add two new users
useradd user2
useradd user3
passwd user2    (write: 'redhat')
passwd user3    (write: 'redhat')

# add new group
groupadd AdminGroup

# add users to AdminGroup
usermod -aG AdminGroup user2
usermod -aG AdminGroup user3

# make useer3 with root permissions
usermod -aG wheel user3
```

---

## Part 3: SSH 

---

### Commands and Explanation:

```bash
# connect before make keys
 ssh nasri@10.0.2.6

 # generate keys
 ssh-keygen

 # copy public key to the other machine 
 ssh-copy-id nasri@10.0.2.6

```

---

## Part 4: File Permissions 

---

### Commands and Explanation:

```bash
# copy files
cp /etc/fstab /var/tmp

# give user1 read write permissions 
setfacl -m u:user1:rw /var/tmp/fstab

# no any permissions to user2
setfacl -m u:user2:- /var/tmp/fstab
```

---

## Part 5: SELinux Enforcing Mode

---

###  Commands and Explanation:

```bash
# enforcing mode permanent
vi /etc/selinux/config
(set: SELINUX=enforcing)

# check SE status
sestatus
```

---

## Part 6: Bash Script and Process Management

---

### Commands and Explanation:

```bash
# run background process for 10 minutes
sleep 600 &

# try kill 
kill pid 
kill -9 pid
```

---

## Part 7: Yum Repository 

---

###  Commands and Explanation:

```bash 
# install tmux, apache server
yum install tmux
yum install httpd

# create local yum repo
yum install createrepo
yum install yum-utils
mkdir /var/www/html/localrepo
createrepo /var/www/html/localrepo/

vi /etc/yum.repos.d/localrepo.repo
( add these lines )
[localrepo]
name=Local Repository
baseurl=http://localhost/localrepo/
enabled=1
gpgcheck=0


cd /var/www/html/localrepo/
wget https://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/
yumdownloader --resolve --destdir=/var/www/html/localrepo/ zabbix-server-mysql zabbix-agent zabbix-web zabbix-sender zabbix-get mariadb-libs php-pgsql

systemctl restart httpd
createrepo /var/www/html/localrepo/
yum clean all
yum makecache
 # disable all other repos and keep the local
yum-config-manager --disable \*
yum-config-manager --enable localrepo

# install zabbix rpms from new local repo
yum install zabbix-server-mysql zabbix-agent zabbix-web zabbix-sender zabbix-get php

```

---

## Part 8: Network Management (Using Ip Tables)

---

### Commands and Explanation:

```bash
# open ports 80 and 443
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# save new added ports to make them permenant
service iptables save

# block ssh connection from my colleugue
iptables -A INPUT -p tcp --dport 22 -s 192.168.1.100 -j REJECT
```

---

## Part 9: Cronjob

---

### Commands and Explanation:

```bash
# write the script 
vi /home/nasri/Documents/logs.txt

#########script########
#!/bin/bash 
time=$(date "+%d/%m/%Y  %H:%M:%S")

echo "time: $time" >> /home/nasri/Documents/logs.txt
w >> /home/nasri/Documents/logs.txt
#######################

# make it executable 
chmod +x /home/nasri/Documents/T1P9.sh

# add the cronjob run at 1:30 every day 
crontab -e
30 1 * * * /home/nasri/Documents/T1P9.sh
```

----

## Part 10: MariaDB 

---

### Step 1: Install MariaDB from Local Repo

```bash
# install mariadb from local repo
cd /var/www/html/localrepo/

# get rpms but it didnt work using yumdownloader so i get the rpms manullay from vault.centos.org
yumdownloader --resolve --destdir=/var/www/html/localrepo/ mariadb-server mariadb    
get the rpms manually from -> https://vault.centos.org/7.9.2009/os/x86_64/Packages/
wget http://vault.centos.org/7.9.2009/os/x86_64/Packages/mariadb-server-5.5.68-1.el7.x86_64.rpm
wget http://vault.centos.org/7.9.2009/os/x86_64/Packages/mariadb-5.5.68-1.el7.x86_64.rpm
wget http://vault.centos.org/7.9.2009/os/x86_64/Packages/mariadb-libs-5.5.68-1.el7.x86_64.rpm
wget http://vault.centos.org/7.9.2009/os/x86_64/Packages/mariadb-devel-5.5.68-1.el7.x86_64.rpm
wget http://vault.centos.org/7.9.2009/os/x86_64/Packages/perl-DBD-MySQL-4.023-6.el7.x86_64.rpm

createrepo /var/www/html/localrepo/
yum install mariadb-server

# open port for mariadb
iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
service iptables save 

# create data base, add new user and handle permissions

mysql -u root -p
CREATE DATABASE T1P10;

CREATE USER 'attari'@localhost IDENTIFIED BY '1234';
GRANT ALL PRIVILEGES ON *.* TO 'attari'@localhost IDENTIFIED BY '1234';
FLUSH PRIVILEGES;

mysql -u attari -p

CREATE DATABASE studentdb;
USE studentdb;


CREATE TABLE students (
    student_number VARCHAR(10) PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    program_enrolled VARCHAR(50),
    graduation_year INT
); 

INSERT INTO students VALUES
('110-001', 'Allen', 'Brown', 'mechanical', 2017),
('110-002', 'David', 'Brown', 'mechanical', 2017),
('110-003', 'Mary', 'Green', 'electrical', 2018),
('110-004', 'Dennis', 'Green', 'electrical', 2018),
('110-005', 'Joseph', 'Black', 'electrical', 2018),
('110-006', 'Dennis', 'Black', 'computer science', 2020),
('110-007', 'Ritchie', 'Salt', 'computer science', 2020),
('110-008', 'Robert', 'Salt', 'computer science', 2020),
('110-009', 'David', 'Suzuki', 'computer science', 2020),
('110-010', 'Mary', 'Chen', 'computer science', 2020);


# handle permission to remote the database from another vm 
GRANT ALL PRIVILEGES ON *.* TO 'attari'@'%' IDENTIFIED BY 'yourpassword' WITH GRANT OPTION;
FLUSH PRIVILEGES;

# remote from another vm
mariadb -h 10.0.2.15 -P 3306 -u attari -p
```

---







