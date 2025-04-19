### Install AdGuard Home

```
git clone https://github.com/coolq4s/server-lnx.git && mv server-lnx/AdGuard-Home/Install-AGH.sh Install-AGH.sh && chmod +x Install-AGH.sh && ./Install-AGH.sh
```
### Upstream

```
#CloudFlare
https://1.1.1.1/dns-query
https://1.0.0.1/dns-query
tls://1.1.1.1
tls://1.0.0.1
#Adguard
tcp://94.140.14.140
tcp://[2a10:50c0::1:ff]
[2a10:50c0::1:ff]:53
94.140.14.140:53
#Google
https://8.8.8.8/dns-query
https://8.8.4.4/dns-query
tls://8.8.8.8
tls://8.8.4.4
#OpenDns
https://208.67.222.222/dns-query
tls://208.67.222.222
#CFIEC
https://dns.cfiec.net/dns-query
tls://dns.cfiec.net
#OpenDNS_Sandbox
https://doh.sandbox.opendns.com/dns-query
tls://familyshield.opendns.com
#Quad9
tls://149.112.112.9
https://149.112.112.9/dns-query
#Yandex
https://77.88.8.8/dns-query
tls://77.88.8.8
#ControlD
https://freedns.controld.com/p1
###HTTP/3
#Google
h3://8.8.8.8/dns-query
#Mixed
h3://dns.nextdns.io
h3://dns.google/dns-query
h3://dns.cloudflare.com/dns-query
h3://dns.adguard-dns.com/dns-query
h3://basic.rethinkdns.com/
h3://doh-jp.blahdns.com/dns-query
h3://doh.tiarap.org/dns-query
h3://jp.tiarap.org/dns-query
h3://freedns.controld.com/p1

```
