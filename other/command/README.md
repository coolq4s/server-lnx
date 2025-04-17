### Usefull Command
- Clear temporary files
```
rm -rf /tmp
```
- Clear unused package in cache
```
apt-get clean
```
- Can't resolve domain, edit file in `nano /etc/sysctl.conf`
```
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
```
