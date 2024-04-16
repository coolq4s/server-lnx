##Install ZeroTier in SBC (S)
Route between ZeroTier Network and Physical Networks Armbian Server in any SBC like OrangePi/STB B860H.

Pre-Require :
- Install `net-tools` tool
```
apt install net-tools
```

How to install :
1. Enable IP Forwarding
   - Edit file in directory `/etc/sysctl.conf` with nano or vim and find or add line `net.ipv4.ip_forward=1`.
   - For simple use, you can use this command
     ```
     sysctl -w net.ipv4.ip_forward=1
     ```

2. Configure `iptables`
   - Find ZeroTier interface name with command
     ```
     ifconfig
   - Modify physical network interface name, ZeroTier interface name. Type this command to linux cli
     ```
     PHY_IFACE=eth0
     ```press enter`
     ZT_IFACE=zt44xaj2sx
     ```

     b. [Add rules to iptables]

         iptables -t nat -A POSTROUTING -o $PHY_IFACE -j MASQUERADE

         iptables -A FORWARD -i $ZT_IFACE -o $PHY_IFACE -j ACCEPT

         iptables -A FORWARD -i $PHY_IFACE -o $ZT_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT

      c. [Save iptables rules for next boot]

          apt install iptables-persistent
          bash -c iptables-save > /etc/iptables/rules.v4
