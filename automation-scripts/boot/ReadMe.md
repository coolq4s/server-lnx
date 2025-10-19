## Fix STB not boot up properly
If your machine is failure to boot in STB machine or other linux distro, use this command maybe help your case.

### Instruction :

1. Create new file with this command
    ```
    sudo nano /etc/systemd/system/stb-network-fix.service
    ```
2. Add  this code in opened file
    ```
    [Unit]
    Description=Fix STB B860H Network Stability
    After=network.target
    Wants=network.target

    [Service]
    Type=oneshot
    ExecStart=/sbin/ethtool -s eth0 speed 100 duplex full autoneg off
    ExecStart=/bin/sleep 5
    RemainAfterExit=yes
    Restart=on-failure
    RestartSec=5s

    [Install]
    WantedBy=multi-user.target
    ```
3. Restart and reload service
    ```
    sudo systemctl daemon-reload
    sudo systemctl restart stb-network-fix.service
    ```
4. Check configuration applied
    ```
    ethtool eth0 | grep -E "Speed|Duplex|Auto-negotiation"
    ```
    Output :
    <pre>
    Speed: 100Mb/s
    Duplex: Full
    Auto-negotiation: Off
    </pre>
