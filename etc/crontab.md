## php
## mysql
## openresty
## iptables
## redis
1. 去除警告: redis 刚安装完毕启动时会有两个warning, 需要对系统的参数进行设置.
2. 注意启动的权限: redis 服务不要用 root 账号进行启动,否则会产生不必要的安全问题,可以在启动脚本中设置启动的 user 和 group
3. 绑定端口: redis 可以进行端口绑定, 为了安全考虑, 端口最好不开放到公网,如果需要开放到公网,最好配合防火墙使用,以及设置密码.
4. 设置密码: 如果redis 的端口需要暴露到公网, 一定要设置密码进行防护.
## thumbor
1. 测试的时候可以开启 unsafe 接口, 测试完毕不要忘记关闭.
## sysv-rc-conf
## zsh
## supervisord
## openssl
## swoole
## ssdb