# Fix STB not boot up properly
If your machine is failure to boot in STB machine or other linux distro, use this command maybe help your case.

## Instruction :
**- Restart service**

1. Check first the parameters
    ```console
    ethtool eth0 | grep -E "Speed|Duplex|Auto-negotiation"
    ```
    Example output :
   <pre>
    Speed: 100Mb/s
    Duplex: Half
    Auto-negotiation: on    </pre>
    If output like that you must change the speed of Interface.

3. Create new file with this command
    ```console
    sudo nano /etc/systemd/system/stb-network-fix.service
    ```
4. Add  this code in opened file <br>
    ## ⚠️  Attention : <br>
    If your ethernet speed is 100Mbps use existing command. If speed is 1Gbps use `1000` instead of `100` in this line `ExecStart=/sbin/ethtool -s eth0 speed [100 or 1000]duplex full`
    <br>
    <br>

    ```ini
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
5. Edit rc.local, add this command before `exit 0`
    ```
    ethtool -s eth0 speed 100 duplex full autoneg off
    sleep 5
    ```
5. Restart and reload service
    ``` console
    sudo systemctl daemon-reload
    sudo systemctl restart stb-network-fix.service
    ```
6. Check configuration applied
    ```console
    ethtool eth0 | grep -E "Speed|Duplex|Auto-negotiation"
    ```
    Output :
    <pre>
    Speed: 100Mb/s
    Duplex: Full
    Auto-negotiation: Off </pre>
    If `off` the command is applied, `reboot`to see the effect.
7. Check service status
    ```console
    sudo systemctl status stb-network-fix.service
    ```
    - inactive (dead) = It's NORMAL for oneshot service if task completed
    - active (exited) = Normal, script completed execute
    - active (running) = Abnormal, that script is oneshot parameter
8. Check log of service
    ```console
    journalctl -u stb-network-fix.service | tail -10
    ```
9. Reboot, type `reboot`
<br>
<br>

**- Reboot if service is critical fail**
1. Backup system file need to edit
    ```console
    sudo cp /boot/extlinux/extlinux.conf /boot/extlinux/extlinux.conf.backup
    ```
    or
    ```console
    sudo cp /etc/sysctl.conf /etc/sysctl.conf.backup
    ```
   
2. Edit system file
    ```console
    sudo nano /boot/extlinux/extlinux.conf
    ```
3. Add this code `panic=10 panic_on_oops=1 systemd.crash_reboot=1` in end of `APPEND` line <br>
    Ex : <br>
    Before edit:<br>
    `APPEND root=UUID=xxxxxx rootfstype=ext4 rootflags=data=writeback rw console=tty1 console=ttyAML0,115200n8 no_console_suspend consoleblank=0 fsck.fix=yes fsck.repair=yes net.ifnames=0` <br>
    After edit:<br>
    `APPEND root=UUID=xxxxxx rootfstype=ext4 rootflags=data=writeback rw console=tty1 console=ttyAML0,115200n8 no_console_suspend consoleblank=0 fsck.fix=yes fsck.repair=yes net.ifnames=0 panic=10 panic_on_oops=1`

4. Edit system file
    ```console
    sudo nano /etc/sysctl.d/kernel-panic.conf
    ```
5. Paste this code
    ```console
    kernel.panic = 10
    kernel.panic_on_oops = 1
    kernel.panic_on_rcu_stall = 1
    net.core.netdev_max_backlog = 1000
    vm.dirty_ratio = 10
    ```
6. Apply service
    ```console
    sudo sysctl -p /etc/sysctl.d/kernel-panic.conf
    ```
7. Check code is inputted
    ```bash
    echo "Panic: $(cat /proc/sys/kernel/panic)"
    echo "Panic on Oops: $(cat /proc/sys/kernel/panic_on_oops)"
    echo "Panic on RCU Stall: $(cat /proc/sys/kernel/panic_on_rcu_stall)"
    echo "Core Netdev Max Backlog: $(cat /proc/sys/net/core/netdev_max_backlog)"
    echo "Dirty Ratio: $(cat /proc/sys/vm/dirty_ratio)"
    ```
8. Verify the script is work
    ```console
    cat /proc/cmdline | grep panic
    cat /proc/sys/kernel/panic
    ```
    Output :
    <pre>root=UUID=###-###-###-### rootflags=data=writeback console=***,*** console=tty0 rw no_console_suspend consoleblank=0 fsck.fix=yes fsck.repair=yes net.ifnames=0 splash plymouth.ignore-serial-consoles panic=10 panic_on_oops=1
   10</pre>
9. To testing kernel panic
    ```console
    echo c | sudo tee /proc/sysrq-trigger
    ```
    Note : Machine will be reboot
10. If reboot the script is work properly
