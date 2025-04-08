## Part 1: LVM 

---

###  Commands and Explanation:

```bash
# List available disks to find the second one
lsblk

# Initialize /dev/sdb as a physical volume
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
nano /etc/fstab
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
passwd --stdin user1  # (type: redhat)

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

# Add both user2 and user3 to 'wheel' group (admin group)
usermod -aG wheel user2
usermod -aG wheel user3

# Give user3 full sudo/root permissions
visudo
# Add this line at the end:
# user3 ALL=(ALL) ALL
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

# Verify that the file exists
ls -l /var/tmp/admin

# Change ownership to user1
chown user1:user1 /var/tmp/admin

# Verify the owner is now user1
ls -l /var/tmp/admin

# Set permissions so only user1 can read/write/execute
chmod 700 /var/tmp/admin
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
nano /etc/selinux/config
# Inside the file, set:
# SELINUX=enforcing
```

---


