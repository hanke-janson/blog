---
title: postgis数据库备份
date: 2025-05-12 23:43:19
categories: Database
tags: [postgresql, postgis]
---

# postgis数据库备份

```bash
# 基础镜像Dockerfile
# https://github.com/postgis/docker-postgis?tab=readme-ov-file
# 启动 postgis 镜像命令
# 配置postgis
docker run -t --name postgis-apline -p 5433:5432 --restart always \
           -e POSTGIS_GDAL_ENABLED_DRIVERS='ENABLE_ALL' \
           -e POSTGIS_ENABLE_OUTDB_RASTERS=1 \
           -e GDAL_DATA='/usr/share/gdal' \
           -e POSTGRES_USER='postgres' \
           -e POSTGRES_PASSWORD='123456' \
           -e ALLOW_IP_RANGE=0.0.0.0/0 \
           -d postgres-postgis:14-apline3.8
```

# pg数据库的备份

## 相关插件

- [pg_rman](https://github.com/ossc-db/pg_rman/)

- [ptrack](https://github.com/postgrespro/ptrack)

- pg_dump 【默认存在】

- pg_dumpall 【默认存在】

- pg_basebackup 【默认存在】

## 使用

### pg_rman 使用指南

[【参考digoal博客】](https://github.com/digoal/blog/blob/master/201608/20160826_01.md)

#### 使用前的相关配置

> `mkdir -p /var/lib/postgresql/data/pg_log` log_directory 日志目录
>
> `mkdir -p /var/lib/postgresql/data/arc_log` wal文件归档目录
>
> 给目录赋权限
>
> `chown postgres:postgres -R /var/lib/postgresql/data/arc_log`
>
> `su postgres -c "chmod 700 -R /var/lib/postgresql/data/arc_log"`
>
> `chown postgres:postgres -R /var/lib/postgresql/data/pg_log`
>
> `su postgres -c "chmod 700 -R /var/lib/postgresql/data/pg_log"`
>
> `vi /var/lib/postgresql/data/postgresql.conf` 编辑postgresql的配置文件
>
> postgresql.conf 修改项：
>
> - wal_level = replica
> - log_destination = 'csvlog'
> - log_directory = 'pg_log'
> - archive_mode = on
> - archive_command = 'test ! -f /var/lib/postgresql/data/arc_log/%f && cp %p /var/lib/postgresql/data/arc_log/%f'
>
> 重启postgres容器

#### pg_rman 配置验证

> `su - postgres`
>
> `psql`
>
> `show log_destination;`
>
> `show log_directory;`
>
> `show archive_command;`

#### 初始化pg_rman backup catalog

`backup catalog` 这个目录将用于存放备份的文件，
同时这个目录也会存放一些元数据，例如备份的配置文件，数据库的systemid，时间线文件历史等等。

初始化命令需要两个参数，分别为备份目标目录，以及数据库的$PGDATA

`mkdir -p /var/lib/postgresql/backup`

`pg_rman init -B /var/lib/postgresql/backup -D /var/lib/postgresql/data`

查看pg_rman的配置文件信息

```bash
cd /var/lib/postgresql/backup
cat pg_rman.ini
```

可选添加相关配置

> COMPRESS_DATA = YES --压缩数据
>
> KEEP_ARCLOG_FILES = 10 --保存归档文件个数
>
> KEEP_ARCLOG_DAYS = 10 --保存归档的天数
>
> KEEP_DATA_GENERATIONS = 3 --备份冗余度
>
> KEEP_DATA_DAYS = 10 --保存备份集时间
>
> KEEP_SRVLOG_FILES = 10 --保存日志文件个数
>
> KEEP_SRVLOG_DAYS = 10 --保存日志文件天数

#### pg_rman 命令行用法

##### 备份命令

全量备份：备份整个数据库集群。

```bash
pg_rman backup -b full -B /var/lib/postgresql/backup -D /var/lib/postgresql/data
```

增量备份：仅备份使用相同时间轴在上次验证备份后修改的文件或页面。

```bash
pg_rman backup -b incremental -B /var/lib/postgresql/backup -D /var/lib/postgresql/data
```

存档WAL备份：仅备份存档WAL文件

```bash
pg_rman backup -b archive -B /var/lib/postgresql/backup -D /var/lib/postgresql/data
```

备份集校验(建议在备份后尽快验证备份文件。未验证的备份不能用于还原或增量备份)

```bash
pg_rman validate -B /var/lib/postgresql/backup
```

删除备份集

> 按指定时间从catalog删除备份集
>
> 例如只需要备份集能恢复到2017-08-30 17:27:49，在这个时间点以前，不需要用来恢复到这个时间点的备份全删掉。但是会保留一次全备份。
> 加上-f会强制删除

```bash
pg_rman delete "2017-08-30 17:27:49"
```

> 根据备份策略来删除备份集
>
> 修改配置文件--- pg_rman.ini
>
> KEEP_DATA_GENERATIONS = 3 -- 备份集冗余度是3
>
> KEEP_DATA_DAYS = 10 -- 备份集保留日期是10d

清除备份集

> 物理删除已从catalog删除的备份集
>
> 上面从备份集中删除的备份，备份集文件夹并没有一起删除

```bash
pg_rman purge
```

##### 查看命令

查看备份集

```bash
pg_rman show [StartTime] -B /var/lib/postgresql/backup
```

显示更多详细信息

```bash
pgh_rman show detail -B /var/lib/postgresql/backup
```

##### 恢复命令

恢复前应停止postgreSQL服务器，另外，不要删除原始数据库集群，
因为pg_rman必须从中检查时间线ID或数据校验和状态。
恢复命令将保存未归档的事务日志并删除所有数据库文件。
可以重试恢复，直到创建新的备份。
恢复文件后，pg_rman 创建并配置\$PGDATA/pg_rman_recovery.conf，并将include 指令附加到\$PGDATA/postgresql.conf。
如果include过去恢复pg_rman 时添加了指令，请将其删除。它创建\$PGDATA/recovery.signal文件

```bash
pg_rman restore -B /var/lib/postgresql/backup -D /var/lib/postgresql/data
```

恢复到指定时间戳

```bash
pg_rman restore  --recovery-target-time "2019-02-15 13:56:45" --hard-copy  -B /var/lib/postgresql/backup -D /var/lib/postgresql/data
```

建议恢复成功后尽快进行全量备份，并删除pg_rman手动配置的恢复相关参数。

#### 相关参数含义

`StartTime` 备份开始时的时间戳

`EndTime` 备份结束时的时间戳

`Mode` 备份模式

- `FULL` 全量备份
- `INCR` 增量备份
- `ARCH` 归档WAL备份

`Data` 读取数据文件的大小

`ArcLog` 读取存档WAL文件的大小

`SrvLog` 读取服务器日志文件的大小

`Total` 备份大小（=书面大小）

`Compressed` 备份是否已压缩

`TLI / CurTLI` PostgreSQL的时间轴ID

`ParentTLI` PostgreSQL的前时间轴ID

`Status` 备份状态-

- `OK` 备份已成功完成并经过验证
- `DONE` 备份成功完成
- `RUNNING` 备份仍在运行
- `DELETING` 正在删除备份
- `DELETED` 备份已被删除
- `ERROR` 备份期间发生一些错误
- `CORRUPT` 备份不可用，因为它没有通过验证

# pg相关概念

## 表空间的作用

[参考链接：postgresql-管理表空间](https://blog.csdn.net/Java_Fly1/article/details/133437922)

在 PostgreSQL 中，表空间（tablespace）表示数据文件的存放目录，这些数据文件代表了数据库的对象，
例如表或索引。当我们访问表时，系统通过它所在的表空间定位到对应数据文件所在的位置。

![数据库集群.png](/img/postgis数据库备份/数据库集群.png)

PostgreSQL 中的表空间与其他数据库系统不太一样，它更偏向于一个物理上的概念，表空间的引入为 PostgreSQL 的管理带来了以下好处：

- 如果数据库集群所在的初始磁盘分区或磁盘卷的空间不足，又无法进行扩展，可以在其他分区上创建一个新的表空间以供使用
- 管理员可以根据数据库对象的使用统计优化系统的性能。
  例如，可以将访问频繁的索引存放到一个快速且可靠的磁盘上，比如昂贵的固态硬盘。
  与此同时，将很少使用或者对性能要求不高的归档数据表存储到廉价的低速磁盘上。

## LSN和WAL

WAL即Write-Ahead Logging，预写日志记录，
在写入对数据文件（表和索引所在的位置）的更改时，将描述更改的日志记录刷新到永久存储。

LSN即Log sequence number，日志序列号，这是WAL日志唯一的、全局的标识。

wal日志中写入是有顺序的，比方说一条记录是先加100再乘200，如果顺序错乱变成先乘200再加100，那结果可是差之千里了，
所以必须得记录wal日志的写入顺序，LSN就是负责这个的，给每条产生的wal日志记录一个编号。
