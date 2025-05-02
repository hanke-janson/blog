---
title: 使用mb-util工具处理png格式的底图瓦片
date: 2025-05-03 04:56:37
categories: GIS
tags: [GIS, mb-util, png, mbtiles, 瓦片]
---

# 注意事项

1. 获得的png瓦片数据不能直接使用，必须先进行mbtiles转换后，再根据tms模式导出png才可，否则会出现瓦片错位的情况。

```shell
python mb-util --scheme=tms mbtiles文件路径 png输入文件夹路径（不存在的才行）
```

2. 如果y需要反转，需要加参数 `--scheme=tms`

# 将 png格式 转成 mbtiles格式 (这里用的都是默认参数)

```shell
python mb-util --image_format=png E:\map_arcgis\map_arcgis-img E:\map_arcgis\mbtiles\arcgis_img_0-4.mbtiles
```

# 将 mbtiles格式 转为 png格式

```shell
python mb-util --image_format=png E:\map_arcgis\mbtiles\arcgis_img_0-4.mbtiles E:\map_arcgis\map_arcgis-img（不存在的才行）
```

> 注意： UE使用的瓦片需要指定tms模式

```shell
python mb-util --scheme=tms --image_format=png E:\map_sea_mbtiles\sea_1-7.mbtiles E:\map_sea\map-sea-tms（不存在的才行）
```

# 参考链接

[mb-util](https://github.com/mapbox/mbutil)

[MBUtil实现mbtiles文件和地图切片之间的格式转换](https://www.jianshu.com/p/5f969c3b78a4)
