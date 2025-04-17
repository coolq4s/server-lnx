### Usefull Command
- Clear temporary files
```
rm -rf /tmp
```
- Clear unused package in cache
```
apt-get clean
```
- Can't resolve domain, edit file with `nano /etc/sysctl.conf`
  - Delete hashtag (#) in line `net.ipv4.ip_forward=1`
  - Add this command at the bottom of `sysctl.conf`
    ```
    net.ipv6.conf.all.disable_ipv6 = 1
    net.ipv6.conf.default.disable_ipv6 = 1
    ```
  - Run `sudo sysctl -p` to configure the change
