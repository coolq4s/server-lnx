### Install Local Server with Apache2

1. Install apache2
   ```
   apt install Apache2
   ```
2. Checking apache2
   ```
   sudo service apache2 status
   ```
   > status must be Active (running) in green text
3. Copy your `index.html` to `/var/www/html/`
   `mv your/directory/index.html /var/www/html/`