## Installation Speedtest-CLI

1. Find your architecture type :\
   ```uname -m```
   
   > Use Option 1, if reply is ```armv7l```\
   > Use Option 2, if reply is ```aarch64```


   - Option 1 :\
     ``` wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-armhf.tgz ```

   - Option 2 :\
     ``` wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-aarch64.tgz ```

2. Extract and Install
   ```
   tar -xvzf ookla-speedtest-*-linux-*.tgz
   sudo mv speedtest /usr/local/bin/
   sudo chmod +x /usr/local/bin/speedtest
   ```

3. Done
