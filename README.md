# Docker-Nginx-Wordpress-MySQL


## 1. Docker installation

```
amazon-linux-extras install docker; systemctl start docker; systemctl enable docker
```

## 2. Network creation

```
docker network create mynetwork
```
## 3. Create SSL Certificate files (selfsigned used here)
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout jebincvarghese.xyz.key -out jebincvarghese.xyz.crt
```
## 4. Database container creation

```
docker container run --name db -d -e MYSQL_ROOT_PASSWORD="mysqlroot@123" -e MYSQL_DATABASE="wpdb" -e MYSQL_USER="wpuser" -e MYSQL_PASSWORD="wp@123" --network mynetwork mysql:5.6
```

## 5. Wordpress container creation

```
docker container run --name wordpress -d --network mynetwork -e WORDPRESS_DB_HOST="db" -e WORDPRESS_DB_USER="wpuser"  -e WORDPRESS_DB_PASSWORD="wp@123" -e WORDPRESS_DB_NAME="wpdb" wordpress
```

## 6. Create a custom image for nginx proxy

 a . Create default.conf

```
server {
    listen 80;
    return 301 https://jebincvarghese.xyz;
}

server {

    listen 443 ssl;
    server_name jebincvarghese.xyz;

    ssl_certificate           /etc/nginx/cert.crt;
    ssl_certificate_key       /etc/nginx/cert.key;


    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;

    location / {
	
	  proxy_pass          http://wordpress;
      proxy_set_header        Host $host;
      proxy_set_header        X-Real-IP $remote_addr;
      proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header        X-Forwarded-Proto $scheme;
      proxy_read_timeout  90;

    }
  }
  
  ```
b. Obtain SSL certificate for your domain and save private key in cert.key and the certificate in cert.crt

c. Create Dockerfile

```
FROM nginx
RUN rm -rf /etc/nginx/default.d/*
COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./cert.crt /etc/nginx/cert.crt
COPY ./cert.key /etc/nginx/cert.key
```


b. Build image 

```
docker image build -t nginx:1 .
```


## 7. Nginx proxy container creation

```
docker container run -d --name proxy --network mynetwork -p 80:80 -p 443:443 nginx:1
```


