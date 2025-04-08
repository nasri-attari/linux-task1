## Part 1: LVM 

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
