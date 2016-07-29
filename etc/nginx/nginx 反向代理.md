### 反向代理
在只有一个公网或域名的情况，可通过nginx反向代理为内网webServer通过不同的匹配规则提供外网访问能力。

client –> nginx –> webServer

示例配置：

```
worker_processes  8;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;
pid        logs/nginx.pid;

events {
    worker_connections  2048;
    use epoll;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    server_name_in_redirect off;
    server_tokens off;

    #access_log  logs/access.log  main;
    sendfile		on;
    tcp_nopush		on;
    tcp_nodelay		on;
    keepalive_timeout  60;

    #允许客户端请求的最大的单个文件字节数
    client_max_body_size	10m;
    #客户端请求的缓冲区最大字节数
    client_body_buffer_size		128k;
    #后端服务器连接超时时间
    proxy_connect_timeout		600;
    #后端服务器等候响应时间
    proxy_read_timeout			600;
    #后端服务器回传时间
    proxy_send_timeout			600;
    #客户端请求头的缓存区
    proxy_buffer_size			8k;
    #可以保存的缓存区个数和大小
    proxy_buffers			4	32k;
    #最大可申请的缓存区大小
    proxy_busy_buffers_size		64k;
    #缓存临时文件大小
    proxy_temp_file_write_size	64k;

    server {
        listen     80;
        server_name  jokerzhang.cn;
        access_log	off;
        #access_log  logs/jokerzhang.log;

        location ~ ^/myweb {
              proxy_pass     http://192.168.1.200:8080;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
   	}
}

```