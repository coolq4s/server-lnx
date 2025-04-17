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

  and
  add this line in bottom of config
```
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
```
  and delete hashtag (#) in line `ipv4.forward`
