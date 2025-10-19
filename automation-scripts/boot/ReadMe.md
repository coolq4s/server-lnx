<style>
.custom-warning {
  background: linear-gradient(135deg, #fff3e0 0%, #ffecb3 100%);
  border: 2px solid #ff9800;
  border-left: 6px solid #ff5722;
  padding: 18px;
  margin: 20px 0;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(255, 87, 34, 0.1);
  color: #bf360c;
  font-weight: 500;
}
</style>


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
3. Add  this code in opened file (Warning)
    <div class="custom-warning">
    🚨 __PERHATIAN KHUSUS__ 🚨
    
    Pastikan Anda telah membackup data sebelum menjalankan perintah ini!  
    Operasi ini **tidak dapat dibatalkan** dan akan mempengaruhi sistem.
    </div>


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
