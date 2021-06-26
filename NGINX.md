# Nginx Set-up

-- Add in /etc/hosts

```
127.0.0.1  beta.websimio.test
```

-- Add in servers/apps.conf for nginx conf

```
server {
        listen       443 ssl;
        server_name  beta.websimio.test;
        ssl_certificate      ssl/localhost.crt;
        ssl_certificate_key  ssl/localhost.key;
        ssl_session_cache    shared:SSL:1m;
        ssl_session_timeout  5m;
        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers  on;
        location ^~ /api/ {
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host $host;
                proxy_cache_bypass $http_upgrade;
                proxy_pass http://localhost:5000/;
        }
    }

server {
        listen       80;
        server_name  beta.websimio.test;

        location ^~ /api/ {
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host $host;
                proxy_cache_bypass $http_upgrade;
                proxy_pass http://localhost:5000/;
        }
}
```
