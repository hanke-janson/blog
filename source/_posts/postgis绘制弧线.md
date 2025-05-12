---
layout: postgis
title: postgis 绘制弧线
date: 2025-05-13 00:18:52
categories: Database
tags: [postgresql, postgis]
---

# postgis绘制弧线

## 注意事项

### 处理csv文件时，遇到的问题

如果csv文件中存在BOM字节，会出现获取不到第一列数据的问题

解决方法：用notepad++打开csv文件查看其编码格式，可能是UTF-8 BOM编码，将其转为UTF-8编码

### 序列

创建表时创建序列可以通过serial直接创建

```sql
create table no_fly_zone(id serial PRIMARY KEY,name varchar,area geometry);
```

在使用Mysql时，创建表结构时可以通过关键字auto_increment来指定主键是否自增。但在Postgresql数据库中，虽然可以实现字段的自增，但从本质上来说却并不支持Mysql那样的自增。

**Postgresql的自增机制**：Postgresql中字段的自增是通过序列来实现的。

整体机制是：

- 1、序列可以实现自动增长；
- 2、表字段可以指定默认值。
- 3、结合两者，将默认值指定为自增序列便实现了对应字段值的自增。

Postgresql提供了三种serial数据类型：`smallserial`，`serial`，`bigserial`。

它们与真正的类型有所区别，在创建表结构时会先创建一个序列，并将序列赋值给使用的字段。
也就是说，这三个类型是为了在创建唯一标识符列时方便使用而封装的类型。

- bigserial创建一个bigint类型的自增，
- serial创建一个int类型的自增，
- smallserial创建一个smallint类的自增。

#### 序列函数

![序列函数](/img/postgis绘制弧线/序列函数.png)

### 截断表数据时需要重置序列

在MySQL中，TRUNCATE可以重置ID，使ID重新从1开始自增，但PostgreSQL中， TRUNCATE并不能重置ID，需要通过重置序列来达到目的。

```sql
TRUNCATE TABLE 表名;
ALTER SEQUENCE 序列名 RESTART WITH 1;
```

## 绘制弧线

### 绘制一个怎样的弧线？

![需要绘制的弧线图](/img/postgis绘制弧线/需要绘制的弧线图.jpg)

用以下表来先解析csv文件存储弧线数据

```sql
create table test_table
(
    id serial PRIMARY KEY,
    name varchar,
    a1 geometry,
    a2 geometry,
    c2 geometry,
    radius1 integer,
    b2 geometry,
    b3 geometry,
    radius2 integer,
    c3 geometry,
    a3 geometry,
    a4 geometry,
    c4 geometry,
    radius3 integer,
    b4 geometry,
    b1 geometry,
    radius4 integer,
    c1 geometry,
    lines geometry,
    coordinate geometry
);
```

用以下表来存储绘制结果

```sql
create table no_fly_zone
(
    id serial PRIMARY KEY,
    name varchar,
    area geometry
);
```

### 绘制过程

点通过下面函数进行定义

```sql
SELECT ST_PointFromText('POINT(120.52833333333334 43.22833333333333)',4490);
```

弧形通过下面函数进行定义

> CIRCULARSTRING(起点, 弧线上任意一点, 终点) 若起点与终点相同，则定义了一个圆

```sql
select st_astext(st_curvetoline('CIRCULARSTRING(2 0, 4 4, 3 0)', 4490))
```

插入数据

相关函数见：[make_circularstring](/img/postgis绘制弧线/make_circularstring.sql)

```sql
insert into no_fly_zone (area) values (
st_curvetoline(make_circularstring(
    ARRAY[ST_GeomFromText('POINT(10 10)',4490), ST_GeomFromText('POINT(18 10)',4490), ST_GeomFromText('POINT(10 20)',4490)]
)))
```

将弧线和直线合并后以WKT的形式输出

```sql
select ST_AsText(st_linemerge(st_union(
        ARRAY [
            ST_MakeLine(
                    ARRAY [a1, a2, c2]
                ),
            st_curvetoline(make_circularstring(
                    ARRAY [c2, ST_GeomFromText('POINT(3 5.2)', 4490), b2]
                ))
            ]
    ))) from no_fly_zone;
```

sql将一个表中的两个字段的数据导入到另一个表中

```sql
insert
    into
    test_table (
    "name",
    "coordinate")
select
    "name",
    "area"
from
    no_fly_zone;
```
