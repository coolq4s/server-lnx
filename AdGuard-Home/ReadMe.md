### Install AdGuard Home

```
git clone https://github.com/coolq4s/server-lnx.git && mv server-lnx/AdGuard-Home/Install-AGH.sh Install-AGH.sh && chmod +x Install-AGH.sh && ./Install-AGH.sh
```
### Upstream

```
#CloudFlare
https://1.1.1.1/dns-query
tcp://1.1.1.1:53
tcp://1.0.0.1:53
tcp://1.1.1.1
tcp://1.0.0.1
#Google
https://8.8.8.8/dns-query
https://8.8.4.4/dns-query
tcp://8.8.8.8:53
tcp://8.8.8.8
#Quad9
https://149.112.112.9/dns-query
https://dns10.quad9.net/dns-query
#Yandex
https://77.88.8.8/dns-query

```

### Option :
-  DNS Setting <br>
   √ Load Balancing <br>
   √ Fall Back DNS
      ```
      8.8.8.8
      8.8.4.4
      1.1.1.1
      1.0.0.1
      ```
   √ Bootstrap
      ```
      8.8.8.8
      1.1.1.1
      9.9.9.10
      149.112.112.10
      ```
   √ Use private reverse DNS resolvers <br>
   √ Enable reverse resolving of clients IP addresses <br>
   √ Upstream timeout : 1 <br>
   √ Rate limit : 0 <br>
   √ Subnet prefix length for IPv4 addresses : default (24) <br>
   √ Subnet prefix length for IPv6 addresses : default (56) <br>
   √ Enable EDNS <br>
   √ Enable DNSSEC <br>
   √ Disable resolving of IPv6 <br>
   √ Blocking mode : Default <br>
   √ Block response TTL : 10 <br>
   √ Enable cache <br>
   √ Cache Size : 4194304 <br>
   √ Override minimum TTL : 60 <br>
   √ Override maximum TTL : 900 <br>
   √ Optimistic caching <br>

-  Blocklist
   OISD : <br>
   ```
   https://big.oisd.nl/
   ```
   OISD 18+ : <br>
   ```
   https://nsfw.oisd.nl/
   ```
   AdGuard DNS filter : <br>
   ```
   https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt
   ```
   HaGeZi's Windows/Office Tracker Blocklist : <br>
   ```
   https://adguardteam.github.io/HostlistsRegistry/assets/filter_63.txt
   ```
   NoCoin Filter List : <br>
   ```
   https://adguardteam.github.io/HostlistsRegistry/assets/filter_8.txt
   ```
   AdGuard DNS Popup Hosts filter : <br>
   ```
   https://adguardteam.github.io/HostlistsRegistry/assets/filter_59.txt
   ```
   The Big List of Hacked Malware Web Sites : <br>
   ```
   https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt
   ```

-  Whitelist <br>
   AnuDEEP : <br>
   ```
   https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt
   ```
   Ultimate : <br>
   ```
   https://raw.githubusercontent.com/Ultimate-Hosts-Blacklist/whitelist/master/domains.list
   ```
   Advance : <br>
   ```
   https://raw.githubusercontent.com/Levi2288/AdvancedBlockList/main/Lists/whitelist.txt
   ```
   Adguard : <br>
   ```
   https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/allowlist.txt
   ```
   AGH : <br>
   ```
   https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/refs/heads/master/BaseFilter/sections/allowlist.txt
   ```
   AGH-Stealth : <br>
   ```
   https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/refs/heads/master/BaseFilter/sections/allowlist_stealth.txt
   ```

### CUSTOM FILTER
```
! ===============================================
! WHITELIST DOMAIN DETECTION INTERNET
! Windows + Android + Apple + Linux Connectivity
! ===============================================
! Microsoft Connectivity Detection
@@||msftncsi.com^
@@||msftconnecttest.com^
@@||ctldl.windowsupdate.com^
127.0.0.1 settings-win.data.microsoft.com
127.0.0.1 v10.events.data.microsoft.com
! Google/Android Connectivity Detection
@@||clients3.google.com^
@@||connectivitycheck.android.com^
@@||connectivitycheck.gstatic.com^
@@||android.clients.google.com^
@@||tools.google.com^
! Apple Connectivity Detection
@@||apple.com^
@@||captive.apple.com^
@@||gsp1.apple.com^
@@||mesu.apple.com^
@@||icloud.com^
! Linux Connectivity Detection
@@||connectivity-check.ubuntu.com^
@@||archive.ubuntu.com^
@@||fedoraproject.org^
@@||archlinux.org^
@@||ifconfig.me^
@@||icanhazip.com^
@@||checkip.amazonaws.com^
! Google Services
@@||google.com^
@@||gstatic.com^
@@||googleapis.com^
@@||play.googleapis.com^
! Microsoft Services
@@||microsoft.com^
@@||windows.com^
@@||live.com^
@@||onenote.com^
@@||office.com^
! Apple Services
@@||me.com^
@@||mac.com^
@@||appstore.com^
@@||itunes.com^
! Linux Services
@@||ubuntu.com^
@@||debian.org^
@@||redhat.com^
! NTP Time Servers (All Platforms)
@@||time.windows.com^
@@||time.google.com^
@@||time.apple.com^
@@||pool.ntp.org^
@@||ntp.ubuntu.com^
@@||0.ubuntu.pool.ntp.org^
@@||1.ubuntu.pool.ntp.org^
! Package Managers
@@||ppa.launchpad.net^
@@||deb.debian.org^
@@||ftp.debian.org^
@@||security.ubuntu.com^
@@||security.debian.org^
@@||mirrors.fedoraproject.org^
@@||mirrors.archlinux.org^
! Push Notifications
@@||push.apple.com^
@@||api.push.apple.com^
```
