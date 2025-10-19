## Fix STB not boot up properly
If your machine is failure to boot in STB machine or other linux distro, use this command maybe help your case.

### Instruction :

1. Check first the parameters
    ```
    ethtool eth0 | grep -E "Speed|Duplex|Auto-negotiation"
    ```
    Example output :
    <pre>
    Speed: 100Mb/s
    Duplex: Half
    Auto-negotiation: yes </pre>

    If output like that you must change the speed of Interface.

2. Create new file with this command
    ```
    sudo nano /etc/systemd/system/stb-network-fix.service
    ```
3. Add  this code in opened file

    > [!WARNING]
    > If your ethernet speed is 100Mbps use this command.
    
<br> If speed is 1Gbps use `1000` instead of `100` in this line <br> `ExecStart=/sbin/ethtool -s eth0 speed [100 or 1000]duplex full`

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
4. Restart and reload service
    ```
    sudo systemctl daemon-reload
    sudo systemctl restart stb-network-fix.service
    ```
5. Check configuration applied
    ```
    ethtool eth0 | grep -E "Speed|Duplex|Auto-negotiation"
    ```
    Output :
    <pre>
    Speed: 100Mb/s
    Duplex: Full
    Auto-negotiation: Off </pre>
    If `off` the command is applied
