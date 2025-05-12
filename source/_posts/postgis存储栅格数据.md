---
title: postgis存储栅格数据
date: 2025-05-12 23:58:35
categories: Database
tags: [postgresql, postgis, tiff]
---

# 栅格数据入库

```shell
.\raster2pgsql.exe -s 4326 -I -C -M D:\Dev\PostgreSQL\XX12-1.tiff -F -t auto public.mapserver  | .\psql.exe -h 192.168.11.4 -p 5432 -U postgres -d tiff -W
```

# 参考文档

[栅格数据管理、查询和应用程序](https://postgis.net/docs/using_raster_datamanagement.html)
