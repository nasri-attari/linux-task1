## Part 1: LVM 

---

###  Commands and Explanation:

```bash
# List available disks to find the second one
lsblk

# initialize /dev/sdb as a physical volume
pvcreate /dev/sdb

# Verify physical volume
pvs

# Create a volume group named vg-data with 16M physical extend size
vgcreate vg-data /dev/sdb --physicalextentsize 16M

# Create a logical volume with 50 extends, name it lv-data
lvcreate -l 50 -n lv-data vg-data

# Verify logical volume
lvs

# Format the logical volume as ext4
mkfs.ext4 /dev/vg-data/lv-data

# Create mount directory
mkdir -p /mnt/data

# Mount the new volume temporarily
mount /dev/vg-data/lv-data /mnt/data

# Check if mounted correctly
df -h /mnt/data

# Edit /etc/fstab to make the mount permanent
vi /etc/fstab
# Add this line to the end:
# /dev/vg-data/lv-data /mnt/data ext4 defaults 0 0

# Test the fstab entry
mount -a

# Verify again
df -h /mnt/data
```

---

## Part 2: Users, Groups, and Permissions

---

### Commands and Explanation:

```bash
# Create user1 with UID 601 and disable shell access
useradd -u 601 -s /sbin/nologin user1

# Set password for user1
passwd --stdin user1

# Create a new group
groupadd TrainingGroup

# Add user1 to TrainingGroup
usermod -aG TrainingGroup user1

# Verify user1's groups
groups user1

# Add user2
useradd user2
echo "redhat" | passwd --stdin user2

# Add user3
useradd user3
echo "redhat" | passwd --stdin user3

# Create a Admin group
groupadd admin

# Add both user2 and user3 to wheel group
usermod -aG admin user2
usermod -aG admin user3

# Give user3 root permissions
visudo
Add --> user3 ALL=(ALL) ALL
```

---

## Part 3: SSH 

---

### Commands and Explanation:

```bash
# Start the SSH service 
systemctl start sshd

# Check the SSH service status
systemctl status sshd

# Enable SSH service to start on boot
chkconfig sshd on

# Connect using password to verify SSH works
ssh nasri@10.0.2.15

# Generate a new SSH key pair 
ssh-keygen

# Copy your public key to the remote machine
ssh-copy-id nasri@10.0.2.15
```

---

## Part 4: File Permissions 

---

### Commands and Explanation:

```bash
# Copy the original fstab file to /var/tmp/admin
cp /etc/fstab /var/tmp/admin

# Set ownership to root 
chown root:root /var/tmp/admin

# Set default permissions 
chmod 600 /var/tmp/admin

# Give user1 full permissions
setfacl -m u:user1:rw /var/tmp/admin

# Deny all permissions for user2
setfacl -m u:user2:0 /var/tmp/admin
 
 # View the ACL 
getfacl /var/tmp/admin
```

---

## Part 5: SELinux Enforcing Mode

---

###  Commands and Explanation:

```bash
# Check current SELinux status
sestatus

# If not in enforcing mode, switch to enforcing temporarily
setenforce 1

# Edit SELinux config file to make enforcing mode permanent
vi /etc/selinux/config
# Inside the file
# SELINUX=enforcing
```

---

## Part 6: Bash Script and Process Management

---

###  Script File:
The script is saved as [`part6.sh`](./part6.sh)

---

### Commands and Explanation:

```bash
# Create the shell script file
vi part6.sh

# Make the script executable
chmod +x part6.sh

# Run the script in the background
./part6.sh &

# OR find the process by name
ps aux | grep part6.sh

# Kill the process using its PID 
kill 1234
```

---

## Part 7: Yum Repository 

---

###  Commands and Explanation:

```bash
# Install tmux
yum install tmux

# Install Apache web server (httpd)
yum install httpd
systemctl start httpd
systemctl enable httpd
systemctl status httpd

# Install MariaDB
yum install -y mariadb-server
systemctl start mariadb
systemctl enable mariadb

# Secure MySQL installation
mysql_secure_installation

# Create directory to hold Zabbix repo files
mkdir -p /var/www/html/zabbix
cd /var/www/html/zabbix

# Install wget to download files
yum install -y wget

# Download all Zabbix packages
wget -r -np -nH --cut-dirs=4 -R "index.html*" \
https://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/

# Install and run createrepo to generate metadata
yum install -y createrepo
createrepo /var/www/html/zabbix

# Make sure the web server is running to serve the repo
systemctl status httpd

vi /etc/yum.repos.d/zabbix-local.repo

The Yum repo config is saved as [`part7.txt`](./part7.txt)

# Clean all cached metadata
yum clean all

# Check current repositories
yum repolist

# Disable all repos
yum-config-manager --disable \*

# Enable only your local Zabbix repo
yum-config-manager --enable zabbix-local

# Confirm enabled repos
yum repolist

yum install -y zabbix-server-mysql zabbix-agent zabbix-web-mysql \
zabbix-apache-conf zabbix-get zabbix-sender

# Verify installation
rpm -qa | grep zabbix

# Start, enable and check status of services
systemctl start zabbix-server
systemctl enable zabbix-server
systemctl status zabbix-server

systemctl start zabbix-agent
systemctl enable zabbix-agent
systemctl status zabbix-agent

open this URL in a browser (http://localhost/zabbix)
```

---

## Part 8: Network Management (Using firewall-cmd)

---

### Commands and Explanation:

```bash
# Open port 443 HTTPS permanently
firewall-cmd --zone=public --add-port=443/tcp --permanent

# Open port 80 HTTP permanently
firewall-cmd --zone=public --add-port=80/tcp --permanent

# Reload firewall to apply changes
firewall-cmd --reload

# Verify that ports are opened
firewall-cmd --list-ports

# Block SSH (port 22) from IP address 192.168.1.100
firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.100" port port="22" protocol="tcp" reject' --permanent

# Reload firewall to apply the blocking rule
firewall-cmd --reload

# List all rules to verify
firewall-cmd --list-all
```

---

## Part 8: Network Management (Using Ip Tables)

---

### Commands and Explanation:

```bash
# Open port 443 (HTTPS) permanently
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Open port 80 (HTTP) permanently
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Block SSH (port 22) from IP address 192.168.1.100
iptables -A INPUT -p tcp --dport 22 -s 192.168.1.100 -j REJECT

# Save ip tables
service iptables save

# List ip tables
iptables -L -n
```

---

## Part 9: Cronjob

---

### Script File:
The logging script is saved in this repo as [`part9.sh`](./part9.sh)

---

### Commands and Explanation:

```bash
# Open the script 
vi /usr/local/bin/log-logged-users.sh

# (part9.sh contents)

# Make the script executable
chmod +x /usr/local/bin/log-logged-users.sh

# Edit the crontab to schedule the task
crontab -e
# Add this line:
# 30 1 * * * /usr/local/bin/log-logged-users.sh

# Verify that the cronjob was added
crontab -l
```

----

## Part 10: MariaDB 

---

### Step 1: Install MariaDB from Local Repo

```bash
# Install MariaDB using only the local Zabbix repo
yum --disablerepo=\* --enablerepo=zabbix-local install mariadb-server -y

# Start and enable the service
systemctl start mariadb
systemctl enable mariadb

# Open port 3306 permanently for MariaDB
iptables -A INPUT -p tcp --dport 3306 -j ACCEPT

# Save the iptables 
service iptables save

# Login to MariaDB as root
mysql -u root -p

-- Create the student database
CREATE DATABASE studentdb;

-- Create a new user with password
CREATE USER 'studentuser'@'localhost' IDENTIFIED BY 'Student@123';

-- Grant permissions to the new user
GRANT ALL PRIVILEGES ON *.* TO 'studentuser'@'localhost' = PASSWORD('Student@123');
FLUSH PRIVILEGES;

-- Use the new database
USE studentdb;

# Login as the new user
mysql -u studentuser -p

USE studentdb;
SELECT * FROM students;

-- Create the students table
CREATE TABLE students (
    student_number VARCHAR(10) PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    program VARCHAR(50),
    graduation_year INT
);

-- Insert 10 student records
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
```

---







