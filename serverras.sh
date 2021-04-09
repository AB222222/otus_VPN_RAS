#! /usr/bin/env bash
systemctl stop firewalld
systemctl disable firewalld
echo 'net.ipv4.conf.all.forwarding=1'  >> /etc/sysctl.conf
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
systemctl restart network
yum install nano epel-release -y
yum update -y
yum install openvpn easy-rsa -y
cd /etc/openvpn/
mkdir easy-rsa
cd /usr/share/easy-rsa/3.0.8
cp -rf * /etc/openvpn/easy-rsa/
cd /etc/openvpn/easy-rsa/
./easyrsa init-pki
echo 'server' | ./easyrsa build-ca nopass
./easyrsa gen-dh
echo 'server' | ./easyrsa gen-req server nopass
echo 'yes' | ./easyrsa sign-req server server
mkdir /etc/openvpn/keys/
chmod 750 /etc/openvpn/keys
cp -a /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/keys/
cp -a /etc/openvpn/easy-rsa/pki/dh.pem /etc/openvpn/keys/dh2048.pem
cp -a /etc/openvpn/easy-rsa/pki/issued/server.crt /etc/openvpn/keys/
cp -a /etc/openvpn/easy-rsa/pki/private/server.key /etc/openvpn/keys/
cd /etc/openvpn/easy-rsa
echo 'client' | ./easyrsa gen-req client nopass
echo 'yes' | ./easyrsa sign-req client client
cp -a /etc/openvpn/easy-rsa/pki/issued/client.crt /etc/openvpn/keys/
cp -a /etc/openvpn/easy-rsa/pki/private/client.key /etc/openvpn/keys/
mv /vagrant/server.conf /etc/openvpn/
mkdir /etc/openvpn/ccd && mkdir /var/log/openvpn
# # # echo "iroute 192.168.10.0 255.255.255.0" > /etc/openvpn/ccd/client
cp /etc/openvpn/keys/ca.crt /opt/ca.crt
cp /etc/openvpn/keys/client.crt /opt/client.crt
cp /etc/openvpn/keys/client.key /opt/client.key
cp /etc/openvpn/keys/dh2048.pem /opt/dh2048.pem
chmod -R 0777 /opt/
setenforce 0
systemctl -f enable openvpn@server.service
systemctl start openvpn@server.service
