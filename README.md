# otus_VPN_RAS

Запускаем vagrant, ждём окончания выполнения.

На хосте создаём директорию /home/client, даём на неё права на запись:

```
me@me-HP-260-G3-DM:/home$ sudo mkdir client

me@me-HP-260-G3-DM:/home$ sudo chmod 777 client/
```

Копируем в эту директорию сертификаты слиента RAS:

```
me@me-HP-260-G3-DM:~/otus-linux/DZ_VPN_RAS$ vagrant ssh -c 'cat /opt/ca.crt' > /home/client/ca.crt
Connection to 127.0.0.1 closed.
me@me-HP-260-G3-DM:~/otus-linux/DZ_VPN_RAS$ vagrant ssh -c 'cat /opt/client.crt' > /home/client/client.crt
Connection to 127.0.0.1 closed.
me@me-HP-260-G3-DM:~/otus-linux/DZ_VPN_RAS$ vagrant ssh -c 'cat /opt/client.key' > /home/client/client.key
Connection to 127.0.0.1 closed.
me@me-HP-260-G3-DM:~/otus-linux/DZ_VPN_RAS$ vagrant ssh -c 'cat /opt/dh2048.pem' > /home/client/dh2048.pem
Connection to 127.0.0.1 closed.
me@me-HP-260-G3-DM:~/otus-linux/DZ_VPN_RAS$
```

Копируем сертификаты в директорию клиента openvpn:

```
me@me-HP-260-G3-DM:/home/client$ sudo cp c* /etc/openvpn/client/
me@me-HP-260-G3-DM:/home/client$ cd /etc/openvpn/client
me@me-HP-260-G3-DM:/etc/openvpn/client$ ll
total 24
drwxr-xr-x 2 root root 4096 апр  9 08:30 ./
drwxr-xr-x 4 root root 4096 ноя  1 07:42 ../
-rw-r--r-- 1 root root 1170 апр  9 08:30 ca.crt
-rw-r--r-- 1 root root 4494 апр  9 08:30 client.crt
-rw-r--r-- 1 root root 1732 апр  9 08:30 client.key
me@me-HP-260-G3-DM:/etc/openvpn/client$
```

В директорию /etc/openvpn копируем файл конфига client.conf и стартуем клиент openvpn:

```
me@me-HP-260-G3-DM:/etc/openvpn/client$ systemctl start openvpn@client 
me@me-HP-260-G3-DM:/etc/openvpn/client$ systemctl status openvpn@client
● openvpn@client.service - OpenVPN connection to client
     Loaded: loaded (/lib/systemd/system/openvpn@.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2021-04-09 08:51:01 MSK; 30s ago
       Docs: man:openvpn(8)
             https://community.openvpn.net/openvpn/wiki/Openvpn24ManPage
             https://community.openvpn.net/openvpn/wiki/HOWTO
   Main PID: 16488 (openvpn)
     Status: "Initialization Sequence Completed"
      Tasks: 1 (limit: 14131)
     Memory: 1.5M
     CGroup: /system.slice/system-openvpn.slice/openvpn@client.service
             └─16488 /usr/sbin/openvpn --daemon ovpn-client --status /run/openvpn/client.status 10 --cd /etc/openvpn --script-security 2 --config /etc/openvpn/client.conf --writepid /run/openvpn/client.>

апр 09 08:51:02 me-HP-260-G3-DM ovpn-client[16488]: Outgoing Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
апр 09 08:51:02 me-HP-260-G3-DM ovpn-client[16488]: Incoming Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
апр 09 08:51:02 me-HP-260-G3-DM ovpn-client[16488]: ROUTE_GATEWAY 192.168.1.254/255.255.255.0 IFACE=enp2s0 HWADDR=80:e8:2c:30:06:f1
апр 09 08:51:02 me-HP-260-G3-DM ovpn-client[16488]: TUN/TAP device tun0 opened
апр 09 08:51:02 me-HP-260-G3-DM ovpn-client[16488]: TUN/TAP TX queue length set to 100
апр 09 08:51:02 me-HP-260-G3-DM ovpn-client[16488]: /sbin/ip link set dev tun0 up mtu 1500
апр 09 08:51:02 me-HP-260-G3-DM ovpn-client[16488]: /sbin/ip addr add dev tun0 local 10.8.0.6 peer 10.8.0.5
апр 09 08:51:02 me-HP-260-G3-DM ovpn-client[16488]: /sbin/ip route add 10.8.0.0/24 via 10.8.0.5
апр 09 08:51:02 me-HP-260-G3-DM ovpn-client[16488]: WARNING: this configuration may cache passwords in memory -- use the auth-nocache option to prevent this
апр 09 08:51:02 me-HP-260-G3-DM ovpn-client[16488]: Initialization Sequence Completed
me@me-HP-260-G3-DM:/etc/openvpn/client$ cat /var/log/openvpn.log
```

Соединение с сервером RAS установлено.

На сервере видим:

```
[root@serverras ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 84949sec preferred_lft 84949sec
    inet6 fe80::5054:ff:fe4d:77d3/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:30:0c:1b brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.150/24 brd 192.168.10.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe30:c1b/64 scope link 
       valid_lft forever preferred_lft forever
4: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    link/none 
    inet 10.8.0.1 peer 10.8.0.2/32 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::871:9e50:e2cc:618b/64 scope link flags 800 
       valid_lft forever preferred_lft forever
[root@serverras ~]# cat /var/log/openvpn.log
Fri Apr  9 05:22:59 2021 OpenVPN 2.4.10 x86_64-redhat-linux-gnu [Fedora EPEL patched] [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] built on Dec  9 2020
Fri Apr  9 05:22:59 2021 library versions: OpenSSL 1.0.2k-fips  26 Jan 2017, LZO 2.06
Fri Apr  9 05:22:59 2021 Diffie-Hellman initialized with 2048 bit key
Fri Apr  9 05:22:59 2021 ROUTE_GATEWAY 10.0.2.2/255.255.255.0 IFACE=eth0 HWADDR=52:54:00:4d:77:d3
Fri Apr  9 05:22:59 2021 TUN/TAP device tun0 opened
Fri Apr  9 05:22:59 2021 TUN/TAP TX queue length set to 100
Fri Apr  9 05:22:59 2021 /sbin/ip link set dev tun0 up mtu 1500
Fri Apr  9 05:22:59 2021 /sbin/ip addr add dev tun0 local 10.8.0.1 peer 10.8.0.2
Fri Apr  9 05:22:59 2021 /sbin/ip route add 10.8.0.0/24 via 10.8.0.2
Fri Apr  9 05:22:59 2021 Could not determine IPv4/IPv6 protocol. Using AF_INET
Fri Apr  9 05:22:59 2021 Socket Buffers: R=[87380->87380] S=[16384->16384]
Fri Apr  9 05:22:59 2021 Listening for incoming TCP connection on [AF_INET][undef]:1194
Fri Apr  9 05:22:59 2021 TCPv4_SERVER link local (bound): [AF_INET][undef]:1194
Fri Apr  9 05:22:59 2021 TCPv4_SERVER link remote: [AF_UNSPEC]
Fri Apr  9 05:22:59 2021 MULTI: multi_init called, r=256 v=256
Fri Apr  9 05:22:59 2021 IFCONFIG POOL: base=10.8.0.4 size=62, ipv6=0
Fri Apr  9 05:22:59 2021 IFCONFIG POOL LIST
Fri Apr  9 05:22:59 2021 MULTI: TCP INIT maxclients=1024 maxevents=1028
Fri Apr  9 05:22:59 2021 Initialization Sequence Completed
Fri Apr  9 05:51:01 2021 TCP connection established with [AF_INET]10.0.2.2:36830
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 TLS: Initial packet from [AF_INET]10.0.2.2:36830, sid=86cfd091 e81bf153
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 VERIFY OK: depth=1, CN=server
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 VERIFY OK: depth=0, CN=client
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_VER=2.4.7
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_PLAT=linux
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_PROTO=2
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_NCP=2
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_LZ4=1
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_LZ4v2=1
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_LZO=1
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_COMP_STUB=1
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_COMP_STUBv2=1
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_TCPNL=1
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 Control Channel: TLSv1.2, cipher TLSv1/SSLv3 ECDHE-RSA-AES256-GCM-SHA384, 2048 bit RSA
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 [client] Peer Connection Initiated with [AF_INET]10.0.2.2:36830
Fri Apr  9 05:51:01 2021 client/10.0.2.2:36830 MULTI_sva: pool returned IPv4=10.8.0.6, IPv6=(Not enabled)
Fri Apr  9 05:51:01 2021 client/10.0.2.2:36830 MULTI: Learn: 10.8.0.6 -> client/10.0.2.2:36830
Fri Apr  9 05:51:01 2021 client/10.0.2.2:36830 MULTI: primary virtual IP for client/10.0.2.2:36830: 10.8.0.6
Fri Apr  9 05:51:02 2021 client/10.0.2.2:36830 PUSH: Received control message: 'PUSH_REQUEST'
Fri Apr  9 05:51:02 2021 client/10.0.2.2:36830 SENT CONTROL [client]: 'PUSH_REPLY,dhcp-option DNS 10.8.0.1,route 10.8.0.0 255.255.255.0,topology net30,ping 10,ping-restart 120,ifconfig 10.8.0.6 10.8.0.5,peer-id 0,cipher AES-256-GCM' (status=1)
Fri Apr  9 05:51:02 2021 client/10.0.2.2:36830 Data Channel: using negotiated cipher 'AES-256-GCM'
Fri Apr  9 05:51:02 2021 client/10.0.2.2:36830 Outgoing Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
Fri Apr  9 05:51:02 2021 client/10.0.2.2:36830 Incoming Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
[root@serverras ~]# ping 10.8.0.6
PING 10.8.0.6 (10.8.0.6) 56(84) bytes of data.
64 bytes from 10.8.0.6: icmp_seq=1 ttl=64 time=2.61 ms
64 bytes from 10.8.0.6: icmp_seq=2 ttl=64 time=1.99 ms
64 bytes from 10.8.0.6: icmp_seq=3 ttl=64 time=2.48 ms
^C
--- 10.8.0.6 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2007ms
rtt min/avg/max/mdev = 1.999/2.368/2.617/0.266 ms
[root@serverras ~]# ping 10.8.0.1
PING 10.8.0.1 (10.8.0.1) 56(84) bytes of data.
64 bytes from 10.8.0.1: icmp_seq=1 ttl=64 time=0.069 ms
64 bytes from 10.8.0.1: icmp_seq=2 ttl=64 time=0.086 ms
^C
--- 10.8.0.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 999ms
rtt min/avg/max/mdev = 0.069/0.077/0.086/0.012 ms
[root@serverras ~]# 
```

На клиенте (хосте) видим:

```
[root@serverras ~]# cat /var/log/openvpn.log
Fri Apr  9 05:22:59 2021 OpenVPN 2.4.10 x86_64-redhat-linux-gnu [Fedora EPEL patched] [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] built on Dec  9 2020
Fri Apr  9 05:22:59 2021 library versions: OpenSSL 1.0.2k-fips  26 Jan 2017, LZO 2.06
Fri Apr  9 05:22:59 2021 Diffie-Hellman initialized with 2048 bit key
Fri Apr  9 05:22:59 2021 ROUTE_GATEWAY 10.0.2.2/255.255.255.0 IFACE=eth0 HWADDR=52:54:00:4d:77:d3
Fri Apr  9 05:22:59 2021 TUN/TAP device tun0 opened
Fri Apr  9 05:22:59 2021 TUN/TAP TX queue length set to 100
Fri Apr  9 05:22:59 2021 /sbin/ip link set dev tun0 up mtu 1500
Fri Apr  9 05:22:59 2021 /sbin/ip addr add dev tun0 local 10.8.0.1 peer 10.8.0.2
Fri Apr  9 05:22:59 2021 /sbin/ip route add 10.8.0.0/24 via 10.8.0.2
Fri Apr  9 05:22:59 2021 Could not determine IPv4/IPv6 protocol. Using AF_INET
Fri Apr  9 05:22:59 2021 Socket Buffers: R=[87380->87380] S=[16384->16384]
Fri Apr  9 05:22:59 2021 Listening for incoming TCP connection on [AF_INET][undef]:1194
Fri Apr  9 05:22:59 2021 TCPv4_SERVER link local (bound): [AF_INET][undef]:1194
Fri Apr  9 05:22:59 2021 TCPv4_SERVER link remote: [AF_UNSPEC]
Fri Apr  9 05:22:59 2021 MULTI: multi_init called, r=256 v=256
Fri Apr  9 05:22:59 2021 IFCONFIG POOL: base=10.8.0.4 size=62, ipv6=0
Fri Apr  9 05:22:59 2021 IFCONFIG POOL LIST
Fri Apr  9 05:22:59 2021 MULTI: TCP INIT maxclients=1024 maxevents=1028
Fri Apr  9 05:22:59 2021 Initialization Sequence Completed
Fri Apr  9 05:51:01 2021 TCP connection established with [AF_INET]10.0.2.2:36830
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 TLS: Initial packet from [AF_INET]10.0.2.2:36830, sid=86cfd091 e81bf153
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 VERIFY OK: depth=1, CN=server
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 VERIFY OK: depth=0, CN=client
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_VER=2.4.7
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_PLAT=linux
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_PROTO=2
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_NCP=2
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_LZ4=1
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_LZ4v2=1
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_LZO=1
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_COMP_STUB=1
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_COMP_STUBv2=1
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 peer info: IV_TCPNL=1
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 Control Channel: TLSv1.2, cipher TLSv1/SSLv3 ECDHE-RSA-AES256-GCM-SHA384, 2048 bit RSA
Fri Apr  9 05:51:01 2021 10.0.2.2:36830 [client] Peer Connection Initiated with [AF_INET]10.0.2.2:36830
Fri Apr  9 05:51:01 2021 client/10.0.2.2:36830 MULTI_sva: pool returned IPv4=10.8.0.6, IPv6=(Not enabled)
Fri Apr  9 05:51:01 2021 client/10.0.2.2:36830 MULTI: Learn: 10.8.0.6 -> client/10.0.2.2:36830
Fri Apr  9 05:51:01 2021 client/10.0.2.2:36830 MULTI: primary virtual IP for client/10.0.2.2:36830: 10.8.0.6
Fri Apr  9 05:51:02 2021 client/10.0.2.2:36830 PUSH: Received control message: 'PUSH_REQUEST'
Fri Apr  9 05:51:02 2021 client/10.0.2.2:36830 SENT CONTROL [client]: 'PUSH_REPLY,dhcp-option DNS 10.8.0.1,route 10.8.0.0 255.255.255.0,topology net30,ping 10,ping-restart 120,ifconfig 10.8.0.6 10.8.0.5,peer-id 0,cipher AES-256-GCM' (status=1)
Fri Apr  9 05:51:02 2021 client/10.0.2.2:36830 Data Channel: using negotiated cipher 'AES-256-GCM'
Fri Apr  9 05:51:02 2021 client/10.0.2.2:36830 Outgoing Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
Fri Apr  9 05:51:02 2021 client/10.0.2.2:36830 Incoming Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
[root@serverras ~]# ping 10.8.0.6
PING 10.8.0.6 (10.8.0.6) 56(84) bytes of data.
64 bytes from 10.8.0.6: icmp_seq=1 ttl=64 time=2.61 ms
64 bytes from 10.8.0.6: icmp_seq=2 ttl=64 time=1.99 ms
64 bytes from 10.8.0.6: icmp_seq=3 ttl=64 time=2.48 ms
^C
--- 10.8.0.6 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2007ms
rtt min/avg/max/mdev = 1.999/2.368/2.617/0.266 ms
[root@serverras ~]# ping 10.8.0.1
PING 10.8.0.1 (10.8.0.1) 56(84) bytes of data.
64 bytes from 10.8.0.1: icmp_seq=1 ttl=64 time=0.069 ms
64 bytes from 10.8.0.1: icmp_seq=2 ttl=64 time=0.086 ms
^C
--- 10.8.0.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 999ms
rtt min/avg/max/mdev = 0.069/0.077/0.086/0.012 ms
[root@serverras ~]# 
```


