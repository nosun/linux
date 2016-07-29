## iptable 基础

#### 查看设置  

    iptables -L -n

#### 清除规则
不管有没有配置过规则，在重新进行配置之前，需要先清除规则。若要清除规则（有必要时）:  

      iptables -F        //清除预设表filter中的所有规则链的规则
      iptables -X        //清除预设表filter中使用者自定链中的规则

#### 设定预设规则

对于防火墙的设置，有两种策略：一种是全部通讯口都允许使用，只是阻止一些我们知道的不安全的或者容易被利用的口；另外一种，则是先屏蔽所有的通讯口，而只是允许我们需要使用的通讯端口。

	iptables -P INPUT DROP
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD DROP
	
	!注意! -P 中的 P 需要大写，表示Protocol。 

可以看出INPUT,FORWARD两个链采用的是允许什么包通过，而OUTPUT链采用的是不允许什么包通过。
当超出了IPTABLES里filter表里的两个链规则(INPUT、FORWARD)时，不在这两个规则里的数据包怎么处理呢，那就是DROP(放弃)。应该说这样配置是很安全的，我们要控制流入数据包。

而对于OUTPUT链，也就是流出的包我们不用做太多限制，而是采取ACCEPT，也就是说，不在这个规则里的包怎么办呢，那就是通过。

#### 关于 -m 参数

iptables可以使用扩展模块来进行数据包的匹配，语法就是 -m module_name, 所以
-m tcp 的意思是使用 tcp 扩展模块的功能 (tcp扩展模块提供了 --dport, --tcp-flags, --sync等功能）

其实只用 -p tcp 了话， iptables也会默认的使用 -m tcp 来调用 tcp模块提供的功能。但是 -p tcp 和 -m tcp是两个不同层面的东西，一个是说当前规则作用于 tcp 协议包，而后一是说明要使用iptables的tcp模块的功能 (--dport 等)

#### 添加/删除规则

先来添加INPUT规则，因为INPUT预设的是DROP，所以要添加ACCEPT规则。

首先是22端口，这个的用处地球人都知道。

	iptables -A INPUT -p tcp --dport 22 -j ACCEPT

给Web服务器开启80端口:

	iptables -A INPUT -p tcp --dport 80 -j ACCEPT

给FTP服务开启20和21端口:

	iptables -A INPUT -p tcp --dport 20 -j ACCEPT
	iptables -A INPUT -p tcp --dport 21 -j ACCEPT

给邮件服务开启25和110端口:

	iptables -A INPUT -p tcp --dport 25 -j ACCEPT
	iptables -A INPUT -p tcp --dport 110 -j ACCEPT

#### 有关安全

对于OUTPUT规则，因为预设的是ACCEPT，所以要添加DROP规则，减少不安全的端口链接。例如：

	iptables -A OUTPUT -p tcp --sport 31337 -j DROP
	iptables -A OUTPUT -p tcp --dport 31337 -j DROP

具体要DROP掉哪些端口，可以查询相关的资料，可以把一些黑客常用的扫描端口全部DROP掉，多多少少提高一点服务器的安全性。

#### 允许IP：

	iptables -A INPUT -s 192.168.0.18 -p tcp --dport 22 -j ACCEPT

#### 允许IP段：

	iptables -A INPUT -s 192.168.0.1/255 -p tcp --dport 22 -j ACCEPT

对于FORWARD规则，因为预设的是DROP，所以要添加ACCEPT规则。

#### 开启转发功能：

	iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
	iptables -A FORWARD -i eth1 -o eh0 -j ACCEPT

#### 丢弃损坏的TCP包：

	iptables -A FORWARD -p TCP ! --syn -m state --state NEW -j DROP

#### 处理IP碎片数量，防止攻击，允许100个/s ：

	iptables -A FORWARD -f -m limit --limit 100/s --limit-burst 100 -j ACCEPT

#### 保存  
	
     iptables-save >/etc/iptables.up.rules

     把刚才设置的规则保存到指定的地方，文件名可以自定义。

     iptables-restore >/etc/iptables.up.rules

#### 调用

     iptables-restore < /etc/iptables.rules

#### 开机执行

    vi /etc/network/interfaces
    查找
    iface ath0 inet dhcp
    在其后面添加（如果没有找到可以添加在最后）：

     pre-up iptables-restore >/etc/iptables.up.rules //开机时自动调用已经存在的Iptables设置
     post-down iptables-save >/etc/iptables.up.rules //关机时自动保存当前的Iptables设置

之后保存退出。

对于重启，其实是没有必要的，因为 Ubuntu 的 iptables 是写入到内核执行的，会自动平滑重启（也就是实时更新）。

### ubuntu example

	*filter
	
	# Allows all loopback (lo0) traffic and drop all traffic to 127/8 that doesn't use lo0
	-A INPUT -i lo -j ACCEPT
	
	# Accepts all established inbound connections
	-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	
	# Allows all outbound traffic
	-A OUTPUT -j ACCEPT
	
	# Allows HTTP and MySQLconnections from anywhere (the normal ports for websites)
	-A INPUT -p tcp --dport 80 -j ACCEPT
	
	# Allow some server client
	-A INPUT -s li914-120.members.linode.com -p tcp --dport 22 -j ACCEPT
	-A INPUT -s li914-120.members.linode.com -p tcp --dport 3306 -j ACCEPT
	-A INPUT -s li886-65.members.linode.com -p tcp --dport 22 -j ACCEPT
	-A INPUT -s li886-65.members.linode.com -p tcp --dport 3306 -j ACCEPT
	
	# upload work 
	-A INPUT -s li895-185.members.linode.com -p tcp --dport 22 -j ACCEPT
	-A INPUT -s li895-185.members.linode.com -p tcp --dport 3306 -j ACCEPT
	
	# some client
	-A INPUT -s 218.247.254.50 -p tcp --dport 22 -j ACCEPT
	-A INPUT -s 218.247.254.50 -p tcp --dport 3306 -j ACCEPT
	-A INPUT -s 124.205.37.58 -p tcp --dport 22 -j ACCEPT
	-A INPUT -s 124.205.37.58 -p tcp --dport 3306 -j ACCEPT
	-A INPUT -s 124.193.188.229 -p tcp --dport 22 -j ACCEPT
	-A INPUT -s 124.193.188.229 -p tcp --dport 3306 -j ACCEPT
	
	# Allow ping
	-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
	
	# log iptables denied calls (access via 'dmesg' command)
	-A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7
	
	# Reject all other inbound - default deny unless explicitly allowed policy:
	-A INPUT -j REJECT
	-A FORWARD -j REJECT
	COMMIT

### 命令

iptables -I INPUT  -s 42.89.73.109 -j DROP


### iptable presist

正常情况下，我们写入的iptables规则将会在系统重启时消失。即使我们使用iptables-save命令将iptables规则存储到文件，在系统重启后也需要执行iptables-restore操作来恢复原有规则。(当然，你也可以通过在network中的if.post.up.d中配置启动规则来达到开机自动启动iptables的方法)

这里我们有一个更好的iptables持久化方案，让防火墙规则重启后依旧有效。即使用iptables-persistent工具。

首先，安装：

sudo apt-get install iptables-persistent

安装完后即可使用以下命令保存或载入规则：
Ubuntu 14.04

sudo invoke-rc.d iptables-persistent save
sudo invoke-rc.d iptables-persistent reload

或者
	
sudo /etc/init.d/iptables-persistent save 
sudo /etc/init.d/iptables-persistent reload

Ubuntu 16.04

sudo netfilter-persistent save
sudo netfilter-persistent reload

生成的规则将被存储在以下文件中

/etc/iptables/rules.v4
/etc/iptables/rules.v6

### resource

https://www.zivers.com/post/1186.html

### 计算网段
https://www.dan.me.uk