---
title: 使用ctb进行地形切片
date: 2025-05-03 04:44:50
categories: GIS
tags: [CTB, 地形切片]
---

# ctb地形切片

```bash
# 拉取镜像
docker pull tumgis/ctb-quantized-mesh
# 地形切片
docker run -dit  --name "ctb" -v E:\BaiduNetdiskDownload\test-docker:/data tumgis/ctb-quantized-mesh ctb-tile --output-dir /data/terrain /data/tif/taiwan.tif
# 生成 layer.json 文件
ctb-tile --output-dir /data/terrain -l /data/tif/ctb-data/China.tif
```

# 地形修正

使用ctb切出来的地形 在球体上加载 可能会出现只显示半个球的情况，这时需要修正地形数据

1. 先修改`layer.json`文件（修改可见区域）

- 将"available"字段中第一行的`startX`的值修改为0，`endX`的值修改为1
- 文件内容如下：

```
{
  "tilejson": "2.1.0",
  "name": "China",
  "description": "",
  "version": "1.1.0",
  "format": "heightmap-1.0",
  "attribution": "",
  "schema": "tms",
  "tiles": [ "{z}/{x}/{y}.terrain?v={version}" ],
  "projection": "EPSG:4326",
  "bounds": [ 0.00, -90.00, 180.00, 90.00 ],
  "available": [
    [ { "startX": 0, "startY": 0, "endX": 1, "endY": 0 } ]
  ,[ { "startX": 2, "startY": 1, "endX": 3, "endY": 1 } ]
  ,[ { "startX": 5, "startY": 2, "endX": 7, "endY": 3 } ]
  ,[ { "startX": 11, "startY": 4, "endX": 14, "endY": 6 } ]
  ,[ { "startX": 22, "startY": 8, "endX": 28, "endY": 12 } ]
  ,[ { "startX": 45, "startY": 16, "endX": 56, "endY": 25 } ]
  ,[ { "startX": 90, "startY": 33, "endX": 112, "endY": 51 } ]
  ,[ { "startX": 180, "startY": 66, "endX": 224, "endY": 102 } ]
  ,[ { "startX": 360, "startY": 133, "endX": 448, "endY": 204 } ]
  ,[ { "startX": 721, "startY": 266, "endX": 896, "endY": 408 } ]
  ,[ { "startX": 1442, "startY": 533, "endX": 1792, "endY": 816 } ]
  ,[ { "startX": 2884, "startY": 1067, "endX": 3585, "endY": 1633 } ]
  ,[ { "startX": 5768, "startY": 2135, "endX": 7170, "endY": 3266 } ]
  ]
}

```

2. 补全terrain数据

- 补全 `0/0/0.terrain`文件
  补充的地形可为任意地形
