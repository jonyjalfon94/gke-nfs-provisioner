apt-get update -y
apt-get install nfs-kernel-server -y
mkdir /nfsshare
chown nobody:nogroup /nfsshare
chmod 755 /nfsshare
echo "/nfsshare    192.168.0.0/18(rw,sync,no_subtree_check)" >> /etc/exports
systemctl restart nfs-server