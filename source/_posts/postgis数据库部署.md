---
title: postgis数据库部署
date: 2025-05-12 23:47:50
categories: Database
tags: [postgresql, postgis]
---

# PostGIS数据库部署

相关部署Dockerfile见：[postgis-docker](/blog/img/postgis数据库部署/Dockerfile)
相关文件

- [initdb-postgis.sh](/blog/img/postgis数据库部署/initdb-postgis.sh)
- [update-postgis.sh](/blog/img/postgis数据库部署/update-postgis.sh)
- [postgis-3.4.2.tar.gz](/blog/img/postgis数据库部署/postgis-3.4.2.tar.gz)
- [pg_rman-1.3.16-pg14.tar.gz](/blog/img/postgis数据库部署/pg_rman-1.3.16-pg14.tar.gz) 备份工具（可选）

## 初始化数据库

````bash
docker run --name postgis -e POSTGRES_PASSWORD=123456 -p 5432:5432 -d postgres

# postgis 坐标转换函数环境

> 基于 PostgreSQL 和 PostGIS 的坐标转换函数，支持点、线、面的 WGS84 和 CGCS2000 与 GCJ02 和 BD09 坐标系与之间互转。

## 首先保证postgresql中存在postgis扩展

创建postgis扩展

```sql
CREATE EXTENSION postgis
-- 查看扩展版本
select * from postgis_full_version();
````

## 函数安装方式

添加扩展坐标加偏函数（来源<https://github.com/geocompass/pg-coordtransform>）这个库里的函数有一点点问题，已修改见：[coordtransform](/blog/img/postgis数据库部署/geoc-pg-coordtransform.sql)

建表时geom字段类型选用geometry

复制geoc-pg-coordtansform.sql中代码，在数据库执行

## 转换函数使用示例

```sql
-- 如果转换后结果为null，查看geom的srid是否为4326或者4490
WGS84转GCJ02
select geoc_wgs84togcj02(geom) from test_table
GCJ02转WGS84
select geoc_gcj02towgs84(geom) from test_table

WGS84转BD09
select geoc_wgs84tobd09(geom) from test_table
BD09转WGS84
select geoc_bd09towgs84(geom) from test_table

CGCS2000转GCJ02
select geoc_cgcs2000togcj02(geom) from test_table
GCJ02转CGCS2000
select geoc_gcj02tocgcs2000(geom) from test_table

CGCS2000转BD09
select geoc_cgcs2000tobd09(geom) from test_table
BD09转CGCS2000
select geoc_bd09tocgcs2000(geom) from test_table

GCJ02转BD09
select geoc_gcj02tobd09(geom) from test_table
BD09转GCJ02
select geoc_bd09togcj02(geom) from test_table
```
