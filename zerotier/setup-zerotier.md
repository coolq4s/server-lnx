## Install ZeroTier in SBC (Single Board Computer)

Route between ZeroTier Network and Physical Networks Armbian Server in any SBC like OrangePi/STB B860H.

### Pre-Require :
- Linux Server
- Run the terminal with `root`/`sudo`/`administrator privilege` account 
- Install `net-tools` software
```
apt install net-tools
```
> - I'm using Armbian system (DEBIAN Based System) in OrangePi Zero2 and STB B860H, different os or machine maybe not working
> - You can use any OS to remote the machine if ZeroTier supported
- Have a ZeroTier account
- Create a network node in [ZeroTier dashboard](https://my.zerotier.com/) in `Networks` menu.
### Simple installation
- Run this command to your terminal
```
git clone https://github.com/coolq4s/server-lnx.git && mv server-lnx/zerotier/zero.sh zero.sh && chmod +x zero.sh && bash zero.sh
```
> [!IMPORTANT]
> See & follow the message
> If you don't pay attention to the message displayed, there may be an error

### Manual installationl

1. Install the ZeroTier first.
   ```
   apt install zerotier-one
   ```
   or
   ```
   curl -s https://install.zerotier.com | sudo bash
   ```
2. Be sure ZeroTier has installed and running.
   ```
   zerotier-cli status
   ```
   the output will be like this
   > 200 info *2xxxxxx7* 1.10.X ONLINE

   *2xxxxxx7* is a user-id
3. Find and copy `network-id` in [ZeroTier dashboard](https://my.zerotier.com/)
   Example `network-id` : `88****************5`
4. Join network node.
   ```
   zerotier-cli join `network-id`
   ```
   Be sure you has join a network node, to checking join status.
   ```
   zerotier-cli listnetworks
   ```
   you can see a `network-id`, `status`, `user-id`, etc

5. Enable IP Forwarding
   - Edit file in directory `/etc/sysctl.conf` with `nano` or `vim` and find or add line `net.ipv4.ip_forward=1`
   - For simple use, you can use this command.
     ```
     sysctl -w net.ipv4.ip_forward=1
     ```

6. Configure `iptables`
   - Find ZeroTier interface name with command.
     ```
     ifconfig
     ```
     You can find name `ztxxxxxxxxxxxxxx`, initial interface is `zt`, its ZeroTier interface. Then find where is interface get internet Ex. `eth0`
   - Modify physical network interface name, ZeroTier interface name. Type this command to linux cli
     ```
     PHY_IFACE=********
     ```
     _press enter_
     ```
     ZT_IFACE=zt********
     ```
     _press enter_
     
     > `eth0` is internet source, if using wlan you can change `PHY_IFACE` value to your wlan interface, ex. `PHY_IFACE=wlan0`, you can find your internet source by typing command `ifconfig` and you can see all interface in your machine. For simple, find the what interface using netmask and remember that interface name.
   - Add rules to `iptables`.
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
     ```
     apt install iptables-persistent
     ```
     _and_
     ```
     bash -c iptables-save > /etc/iptables/rules.v4
     ```
7. Done.


> - You can test the network by reboot a machine if needed.
> - Be sure you have allow `user-id` in ZeroTier network node by checklist the `user-id` section
> - Add IP's you want to manage has been added in [ZeroTier dashboard](https://my.zerotier.com/)
> - Adding remote machine to network node.
> - For Android, you can download ZeroTier via Play Store and add a `network-id` to your phone. Checklist a `user-id` in network node in [ZeroTier dashboard](https://my.zerotier.com/).


> [!TIP]
> Report bug to me, if `Pre-Require` has been fulfilled.
> Tested in OrPiZero2, B860H (SSD), Android, Windows, Linux
