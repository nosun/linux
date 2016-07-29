### 负载均衡

通过nginx将多台内网webServer以对称的方式组成一个服务器组，将请求均匀的分发到每台服务器上。

nginx常用负载均衡方式：
1、 轮训+Weight
根据权重大小，定位最终的访问服务器

3、 Fair
根据后端服务器响应时间，定位最终的访问服务器

4、 ip_hash
采用nginx自带模块ip_hash，将来自某IP的客户端请求通过哈希算法定位到同一台后端服务器上。

缺点：
1） 如果客户端出口IP为动态IP，将会导致IP切换后定位到新的后端服务器，需要重新建立session
2） 后端服务器如果down，session将会丢失

5、 url_hash
采用nginx开发者提供的第三方模块ngx_http_upstream_hash_module，可根据请求的URL、传入的HTTP标头，或其他参数进行hash，指定后端服务器。
缺点：
1）不支持权重、重试次数等配置
2）后端服务器如果down，session将会丢失

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

    upstream MyServer {
	server 192.168.1.199:8099 max_fails=3 fail_timeout=30s;
	server 192.168.1.200:8099 max_fails=3 fail_timeout=30s;
	ip_hash;
    }
    server {
        listen     80;
        server_name  jokerzhang.cn;
        access_log	off;
        #access_log  logs/jokerzhang.log;

        location ~ ^/myweb {
              proxy_pass     http://MyServer;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
   	}
}

```