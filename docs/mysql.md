## Mysql 常用指令

### 库操作
```
CREATE DATABASE IF NOT EXISTS yourdbname DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
```
### 授权操作

建立新用户
```
create user 'yourname'@'%' identified by 'yourpass'；
```

授权
```
grant all on image.* to 'yourname'@'%';
```

授权 授权的权利
```
GRANT USAGE ON *.* TO 'someuser'@'somehost' WITH GRANT OPTION;
```

刷新生效

```
flush privileges
````

全局授权

Global privileges are administrative or apply to all databases on a given server. To assign global privileges, use ON *.* syntax:
	
```
GRANT ALL ON *.* TO 'someuser'@'somehost';
GRANT SELECT, INSERT ON *.* TO 'someuser'@'somehost';
```

数据库授权

Database privileges apply to all objects in a given database. To assign database-level privileges, use ON db_name.* syntax:

```
GRANT ALL ON mydb.* TO 'someuser'@'somehost';
GRANT SELECT, INSERT ON mydb.* TO 'someuser'@'somehost';
```

撤销授权

```
revoke all on *.* from dba@localhost; 
```

## 表操作

### 查看表数据状况
```
show TABLE STATUS FROM sweetylily where table ='log'
```

### 查看表结构

    show databases;
    show tables;
    describe table;
    show create table products \G;

### 分析执行

   explain
   show processlist;   

### alter
#### 增加列

    alter table products_sn add created_time int not null default 0;

#### 修改列属性

    alter table products_sn_sync_log modify amount int not null default 0; 
    
#### 增加分区

```
ALTER TABLE terms_products PARTITION BY RANGE COLUMNS(tid)(
 PARTITION p0 VALUES LESS THAN (1000) ENGINE = InnoDB,
 PARTITION p1 VALUES LESS THAN (2000) ENGINE = InnoDB,
 PARTITION p2 VALUES LESS THAN (MAXVALUE) ENGINE = InnoDB);
```

#### 增加索引

    create index pid on terms_products(pid);

#### 清空表

```
   TRUNCATE comments;
   TRUNCATE products_comments;
   truncate widget_fivestars;
```

#### 求差集

    select ps.sn,ps.pid,ps.site from products_sn ps left join products p on ps.sn = p.sn where p.sn is null

#### 查询数据库中的表

常用于对数据库表的批量操作

    select table_name from information_schema.TABLES where table_schema ="dbname" and table_name like "field_women%"

#### concat && concat group

    SELECT GROUP_CONCAT(CONCAT( 'ALTER TABLE ' ,TABLE_NAME ,' ENGINE=InnoDB; ') SEPARATOR '' ) FROM information_schema.TABLES AS t WHERE TABLE_SCHEMA = '[ DBNAME]' AND TABLE_TYPE = 'BASE TABLE';


### join

#### delete join
```
DELETE pa FROM pets_activities pa JOIN pets p ON pa.id = p.pet_id WHERE p.order > order AND p.pet_id = pet_id
```

#### update join

```
update terms t inner join page_variables p on t.pvid = p.pvid  set t.visible = 0 where t.vid = 1 and p.meta_description ='' ;
```

### function

#### lower

```
UPDATE table SET colname=LOWER(colname);
```
#### 日期处理

date,month,year,DATE_FORMAT

#### 近期表操作


create table tmp1 as (select * from tmp_image_bridal where sn not in (select sn from tmp_image))

insert into tmp_image(`pid`,`sn`,`site`,`status`) select `pid`,`sn`,`site`,`status` from tmp1

update terms t inner join page_variables p on t.pvid = p.pvid  set t.visible = 0 where t.vid = 1 and p.meta_description ='' ;

update terms t inner join page_variables p on t.pvid = p.pvid set t.meta_description = '' where t.tid =

select sn from products where (sn not like "LW_%") 

select oi.p_sn, count(oi.p_sn) as num 
from orders_items oi 
INNER JOIN orders o 
on oi.oid =o.oid 
where o.status_payment = 1 
and o.status >=0 
and 
o.created > 1454256000 
GROUP BY oi.p_sn 
order by oi.p_sn asc

select o.delivery_country,o.delivery_province,o.delivery_city,oi.p_sn,
DATE_FORMAT(FROM_UNIXTIME(o.event_date),'%Y-%m-%d') as event_date,
DATE_FORMAT(FROM_UNIXTIME(o.payment_time),'%Y-%m-%d') as payment_date 
from orders o 
INNER JOIN orders_items oi 
on o.oid = oi.oid 
where o.`status` =2 and o.status_payment = 1 and event_date >0 

### 恢复单库
```
mysqldump -uroot -p123455 --all-databases >/tmp/all.sql
```
一般备份情况,是讲多个DB备份到一个*,.sql文件中,怎么从*.sql中恢复one database?
```
mysql -h ip -Pport -u name -p'passwd' --one-database db_name < /*.sql
```

### concat

```
select GROUP_CONCAT(CONCAT('truncate table ',t.table_name,';') SEPARATOR '' ) from 
(select table_name from information_schema.tables 
where table_schema = 'ucenterdress' 
and (table_name like "field_%" or table_name like "type_%")
)as t
```