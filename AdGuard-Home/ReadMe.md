### Install AdGuard Home

```
git clone https://github.com/coolq4s/server-lnx.git && mv server-lnx/AdGuard-Home/Install-AGH.sh Install-AGH.sh && chmod +x Install-AGH.sh && ./Install-AGH.sh
```
### Upstream

```
#PureDNS
108.136.97.40:53
tcp://108.136.97.40
https://puredns.org/dns-query
#CloudFlare
https://1.1.1.1/dns-query
https://1.0.0.1/dns-query
tcp://1.1.1.1:53
tcp://1.0.0.1:53
tcp://1.1.1.1
tcp://1.0.0.1
#Adguard
tcp://94.140.14.140
94.140.14.140:53
#Google
https://8.8.8.8/dns-query
https://8.8.4.4/dns-query
tcp://8.8.8.8:53
tcp://8.8.8.8
#Quad9
https://149.112.112.9/dns-query
https://dns10.quad9.net/dns-query

```

### Whitelist
- AnuDEEP <br>
```
https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt
```

- Ultimate
```
https://raw.githubusercontent.com/Ultimate-Hosts-Blacklist/whitelist/master/domains.list
```
- Advance
```
https://raw.githubusercontent.com/Levi2288/AdvancedBlockList/main/Lists/whitelist.txt
```
- Adguard
```
https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/allowlist.txt
```
- AGH
```
https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/refs/heads/master/BaseFilter/sections/allowlist.txt
```
- AGH-Stealth
```
https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/refs/heads/master/BaseFilter/sections/allowlist_stealth.txt
```
