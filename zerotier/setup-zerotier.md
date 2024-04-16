## Install ZeroTier in SBC (Single Board Computer)

Route between ZeroTier Network and Physical Networks Armbian Server in any SBC like OrangePi/STB B860H.

### Pre-Require :
- Install `net-tools` software
```
apt install net-tools
```

### How to install :
1. Enable IP Forwarding
   - Edit file in directory `/etc/sysctl.conf` with nano or vim and find or add line `net.ipv4.ip_forward=1`
   - For simple use, you can use this command :
     ```
     sysctl -w net.ipv4.ip_forward=1
     ```

2. Configure `iptables`
   - Find ZeroTier interface name with command.
     ```
     ifconfig
     ```
     You can find name `ztxxxxxxxxxxxxxx`, initial interface is `zt`, its ZeroTier interface
   - Modify physical network interface name, ZeroTier interface name. Type this command to linux cli
     ```
     PHY_IFACE=eth0
     ```
     _press enter_
     ```
     ZT_IFACE=zt44xaj2sx
     ```
     _press enter_
     
   - Add rules to iptables.
     Type this command :
     ```
     iptables -t nat -A POSTROUTING -o $PHY_IFACE -j MASQUERADE
     ```
     _and_
     ```
     iptables -A FORWARD -i $ZT_IFACE -o $PHY_IFACE -j ACCEPT
     ```
     _and_
     ```
     iptables -A FORWARD -i $PHY_IFACE -o $ZT_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
     ```

    - Save iptables rules for next boot
      Type this command :
      ```
      apt install iptables-persistent
      ```
      _and_
      ```
      bash -c iptables-save > /etc/iptables/rules.v4
      ```
