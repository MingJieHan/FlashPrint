server {
    listen      443 ssl;
    listen      [::]:443 ssl;
    
    server_name flashprint.hanmingjie.com;

    ssl_certificate_key /root/flashprint/flashprint.hanmingjie.com.key;
    ssl_certificate /root/flashprint/flashprint.hanmingjie.com.pem;


    ssl_session_cache    shared:SSL:1m;
    ssl_session_timeout  5m;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    ssl_prefer_server_ciphers  on;
    
    location /static/ {
        autoindex on;
        alias /root/flashprint/static/;
        
        access_log off;
        expires 30d;
        add_header Cache-Control public;

        tcp_nodelay off;

        open_file_cache max=3000 inactive=120s;
        open_file_cache_valid 45s;
        open_file_cache_min_uses 2;
        open_file_cache_errors off;
    }
    
    location /images/ {
        autoindex on;
        alias /root/flashprint/images/;
        
        access_log off;
        expires 1d;
        add_header Cache-Control public;

        tcp_nodelay off;

        open_file_cache max=3000 inactive=120s;
        open_file_cache_valid 45s;
        open_file_cache_min_uses 2;
        open_file_cache_errors off;
    }
    
    client_max_body_size 200M;
    
    location / {
        proxy_pass http://127.0.0.1:9088;
        proxy_ssl_session_reuse off;
        proxy_set_header X-Forwarded-Host $server_name;
        proxy_set_header X-Real-IP $remote_addr;
        add_header P3P 'CP="ALL DSP COR PSAa PSDa OUR NOR ONL UNI COM NAV"';
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        add_header Front-End-Https on;
        proxy_redirect off;
    }
    
    if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
      set $date $1$2$3;
    }
    
    error_log /root/flashprint/error_SSL.log;
    access_log /root/flashprint/access_SSL_$date.log;
}


server {
    listen      80;
    listen      [::]:80;
    
    server_name flashprint.hanmingjie.com;
    
    
    location /static/ {
        autoindex on;
        alias /root/flashprint/static/;
        
        access_log off;
        expires 30d;
        add_header Cache-Control public;

        tcp_nodelay off;

        open_file_cache max=3000 inactive=120s;
        open_file_cache_valid 45s;
        open_file_cache_min_uses 2;
        open_file_cache_errors off;
    }
    
    location /images/ {
        autoindex on;
        alias /root/flashprint/images/;
        
        access_log off;
        expires 1d;
        add_header Cache-Control public;

        tcp_nodelay off;

        open_file_cache max=3000 inactive=120s;
        open_file_cache_valid 45s;
        open_file_cache_min_uses 2;
        open_file_cache_errors off;
    }
    
    client_max_body_size 200M;
    
    location / {
        proxy_pass http://127.0.0.1:9088;
        proxy_ssl_session_reuse off;
        proxy_set_header X-Forwarded-Host $server_name;
        proxy_set_header X-Real-IP $remote_addr;
        add_header P3P 'CP="ALL DSP COR PSAa PSDa OUR NOR ONL UNI COM NAV"';
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        add_header Front-End-Https on;
        proxy_redirect off;
    }
    
    location /.well-known/pki-validation/ {
        autoindex on;
        alias /root/flashprint/verify/;
    }
    
    error_log /root/flashprint/error.log;
    access_log /root/flashprint/access.log;
    
    #when verity your domain file 
    #return 301 https://$host$request_uri;
}

