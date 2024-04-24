### Required
- **[Apache2](https://github.com/coolq4s/server-lnx/blob/25cbaca85fdcb2983960329e531d5780068e9867/apache2/README.md)**

### Import page

- 404 Page
  After installed apache2 to system, you can import this page to your local server using this command
```
git clone https://github.com/coolq4s/server-lnx.git && mv server-lnx/html/404/index.html /var/www/html/ && rm -rf server-lnx
```

### View the result
- Get the server local IP Address or type `ifconfig` to see your machine IPs
- Type your local server IP Address in your browser (default port is 80). Ex : `192.168.0.100` or `http://192.168.0.100`