---
title: GIS相关数据类型简介
date: 2025-05-14 00:12:30
categories: GIS
tags: [数据类型概览]
---

# GIS相关数据类型简介

[ArcGIS 10 文档：关于地理数据格式](https://help.arcgis.com/en/arcgisdesktop/10.0/help/index.html#/About_geographic_data_formats/00r90000006r000000/)

[地信遥感数据汇](https://www.gisrsdata.com/)

## 大场景数据

### 底图影像

#### .mbtiles

数据来源：对 GoogleMap 底图爬取 -> 带有层级目录的.png -> 通过[MBUtil](https://github.com/mapbox/mbutil)工具进行转换 ->发布mbtiles文件访问

### 地形影像

#### .terrain

数据来源：可以从[earthdata.nasa网站](https://search.earthdata.nasa.gov/search)下载SRTM(Shuttle Radar Topography Mission, [SRTM](https://www.earthdata.nasa.gov/sensors/srtm))数据(.hgt)(30m分辨率数据) -> 使用ArcGIS对其进行合并转换（.hgt ->.tif）->通过[Cesiumlab](http://cesiumlab.com/)中的地形切片(.terrain) 【[Cesiumlab文档](https://m.cesiumlab.com/doc/CesiumLab/index.html#/)】-> 通过Nginx等进行发布接口

![栅格转其他格式](/img/GIS相关数据类型简介/image.png)

![合并tif数据](/img/GIS相关数据类型简介/合并tif数据.png)

tif从[ASF Data Search](https://search.asf.alaska.edu/)直接获取然后处理成terrain（可以直接使用圈画或者上传geojson/shp来指定位置），下载的数据中dem结尾的文件名为高程数据（ALOS PALSAR  12.5m）

> 注意：虽然ALOS PALSAR 精度高且免费，但有有一些缺点
>
> - 有的地方没有覆盖到，导致没有数据。
> - 有的数据存在问题，比如有的河谷高程值会存在异常。
> - 有的地方数据存在空洞
> - 并且下载后还需要进行处理、投影转换，费时间

![1686734318818](/img/GIS相关数据类型简介/1686734318818.png)

![1687165074177](/img/GIS相关数据类型简介/1687165074177.png)

这里选这个进行搜索下载，就只下载高精度地形了

![1686734480839](/img/GIS相关数据类型简介/1686734480839.png)

> 可能的高程数据格式：.asc .txt .hgt .tif .tin .dem
>
> 合并.tiff时注意像素类型的选择，如果不设置像素类型，将使用默认值 8 位，输出结果可能会不正确。
>
> 分辨率解析：0.4 弧秒（12m），1 弧秒（30m），3 弧秒（90m）

## 提高DEM精度的方法

> 该方法通过插值提高了视觉精度，但是真实数据依旧是原本的分辨率

在对dem(.tif)数据文件处理前，请务必先处理坐标系，地形应与影像的坐标系统一！！

工具：ArcGIS，FME

[提高高程精度的几种方法](http://www.360doc.com/content/19/1217/12/67466808_880307752.shtml)

> 可以通过等高线的密集与否看出分辨率是否精细

### 通过平滑等高线提升数据精度

1.生成等高线

![1687659141599](/img/GIS相关数据类型简介/1687659141599.png)

参数设置

等值线间距：间距数值单位为米，间距越小，精度越高，数据量越大

![1687661662654](/img/GIS相关数据类型简介/1687661662654.png)

2.平滑等高线

![1687665477625](/img/GIS相关数据类型简介/1687665477625.png)

参数设置

![1687665532939](/img/GIS相关数据类型简介/1687665532939.png)

> ==注==：若数据量过大，则直接创建Terrain 数据集，因为创建TIN，会内存溢出，请直接操作第6步

3.创建TIN

![1687671407106](/img/GIS相关数据类型简介/1687671407106.png)

参数设置

![1687671342755](/img/GIS相关数据类型简介/1687671342755.png)

4.TIN转栅格tif

5.将tif通过cesiumlab进行地形贴片成terrain数据集

6.通过平滑后的等高线创建terrain数据集

- 创建要素数据集

- 将等高线要素添加到要素数据集当中

- 创建Terrain

- 添加Terrain金字塔等级

- 向Terrain添加要素类

  > 在此输入要添加到Terrain数据集的要素类，需注意的是这些要素类必须与Terrain数据集位于同一要素数据集中，也就是操作第二步

- 构建Terrain（时间会很长）

> 查看terrain数据集，调整硬边的样式

![1688089559856](/img/GIS相关数据类型简介/1688089559856.png)

导出terrain

### GIS中DTM/DEM/DSM/DOM/TDOM的含义

#### DEM

数字高程模型（Digital Elevation Model），是通过有限的地形高程数据实现对地面地形的数字化模拟（即地形表面形态的数字化表达）。**它是用一组有序数值阵列形式表示地面高程的一种实体地面模型**，是数字地面模型(Digital Terrain Model，简称DTM)的一个分支，其它各种地形特征值均可由此派生。

![1687225285467](/img/GIS相关数据类型简介/1687225285467.png)

值得注意的是，虽然通过DEM通常表现出的是地理空间的图像形态，实际上，**它是一种数字阵列信息模型**（x,y,z），描述地理空间中的地形高低起伏，通过表示模型和渲染后，成为人们看到的地形图。

![1687225313971](/img/GIS相关数据类型简介/1687225313971.png)

DEM有三种主要的表示模型：规则格网模型，等高线模型和不规则三角网，上图为不规则三角网（TIN）表示模型

由于DEM数据能够反映一定分辨率的局部地形特征，通过其可提取各种类型的地表形态信息，可用于绘制等高线、坡度图、坡向图、立体透视图、立体景观图，并应用于制作正射影像（DOM）、立体地形模型与地图修测。所以，广义的DEM还包括等高线、三角网等所有表达地面高程的数字表示。

**DEM是研究分析地形、流域、地物识别的重要原始资料。**

#### DTM

数字地面模型（Digital Terrain Model），是利用一个任意坐标系中大量选择的已知x、y、z的坐标点对连续地面的一种模拟表示，或者说，DTM就是地形表面形态属性信息的数字表达，是带有空间位置特征和地形属性特征的数字描述。**x、y表示该点的平面坐标，z值可以表示高程、坡度、温度等信息，当z表示高程时，就是数字高程模型，即DEM。**地形表面形态的属性信息一般包括高程、坡度、坡向等。

![1687225491954](/img/GIS相关数据类型简介/1687225491954.png)

可以看到，DTM是一个地理坐标+多属性数字模型，通过z值的多变，可以生成不同地面数字模型，认识DTM也有助于理解DEM。

不过，无论是DTM还是DEM，都专精于地面。

#### DSM

数字地表模型（Digital Surface Model）是包含了地表建筑物、桥梁和树木等高度的地面高程模型。**和DEM相比，DEM只包含了地形的高程信息，并未包含其它地表信息，DSM是在DEM的基础上，进一步涵盖了除地面以外的其它地表信息的高程**。在一些对建筑物高度有需求的领域有重要作用。

![1687225552355](/img/GIS相关数据类型简介/1687225552355.png)

DSM表达了真实地球表面的起伏情况，让DEM的世界多了建筑物和森林等地物的身影！它表现的信息量更大，除了自然地理空间信息，还可从中直接提取社会经济信息；DSM和DTM之间的差异还可以提供非常有用的信息，例如，建筑物高度、植被冠层高度等。

![1687225578892](/img/GIS相关数据类型简介/1687225578892.png)

这张图说明了DSM和DTM的区别：上为DSM关注的地表是包括了建筑、树木等地物的表面高度，而DEM和DTM关注的地面是下图中的红色线条。

**注意**：接下来的两个DOM/TDOM，它们的属性是影像地图，而非数字模型

#### DOM

数字正射影像图（Digital Orthophoto Map）是利用DEM对经过扫描处理的数字化航空像片或遥感影像（单色或彩色），经逐像元进行辐射改正、微分纠正和镶嵌，并按规定图幅范围裁剪生成的形象数据，带有公里格网、图廓（内、外）整饰和注记的平面图。

![1687225773824](/img/GIS相关数据类型简介/1687225773824.png)

> DEM、DOM 的“M”的意义不同 (Model模型和Map地图)

比起渲染后也只能用颜色或阴影区分地形特征的DEM数字模型家族，正射影像DOM终于让人感觉“回到人间” —— 它是经过DEM高程模型几何校正、消除了地形误差的**遥感影像地图**，与人们感官的现实世界无异，我们现在看到的互联网卫星地图大多是正射影像产品。

![1687225881693](/img/GIS相关数据类型简介/1687225881693.png)

由于DOM同时具有地图几何精度和影像特征，**它也是4D基础地理信息产品模式中的重要组成部分** ，不仅可以作为实景三维城市模型的基础数据，同时也可以结合多源空间数据，提取生产数字线划图（DLG）和数字栅格地图（DRG）。

但即使DOM如此亲切自然、准确丰富，依然逃脱不了被挑毛病的命运，比如——

![1687225942070](/img/GIS相关数据类型简介/1687225942070.png)

#### TDOM

数字真正射影像图（True Orho / True Digital Ortho Map），又叫全正射影像，是基于数字表面模型（DSM），利用数字微分纠正技术，改正原始影像的几何变形。

![1687225990581](/img/GIS相关数据类型简介/1687225990581.png)![1687225997297](/img/GIS相关数据类型简介/1687225997297.png)

![1687226023058](/img/GIS相关数据类型简介/1687226023058.png)

##### 整体关系

![1687226082481](/img/GIS相关数据类型简介/1687226082481.png)

## 小场景数据

### 图层

LIDAR:点云数据(.las)可使用Cesiumlab中的点云切片进行处理，结果为 3dtiles 数据

通常使用[GeoServer](https://geoserver.org/)对图层进行发布展示

可发布的文件格式为shp/geojson/tiff/netcdf/postgis数据库/KML/KMZ

关于Geoserver对tif影像发布时的优化方案：

- geoserver只支持tif内建金字塔，可以使用[gdal](https://gdal.org/en/stable/)命令行对其处理

### 模型

[glTF规范（.gltf/.glb...）](https://www.khronos.org/gltf/)

- Cesium可加载，可使用obj2gltf/[blender](https://www.blender.org/)等对其他格式进行转换获得

.obj

- 模型通用格式，可以转成 gltf/fbx等

- [obj2gltf](https://github.com/CesiumGS/obj2gltf)使用npm进行安装，可以将obj转换gltf进行加载

  ```bash
  obj2gltf -i model.obj

  obj2gltf -i model.obj -o model.gltf

  obj2gltf -i model.obj -o model.glb
  ```

.fbx

- cesium可加载，也可以通过blender/3dmax等软件进行加载

.3ds

- 3dmax工程文件，使用3dmax打开后导出obj进行转换（注意设置材质导出路径）

.c4d

- c4d工程文件，使用c4d打开后导出obj进行转换

[3dtiles(.b3dm/.s3dm/.i3dm)](https://github.com/CesiumGS/3d-tiles)

- 三维模型数据，可使用cesiumlab对shp/osgb等数据进行转换获得
- 其中shp数据为建筑轮廓（面数据，需要带有高度/楼层字段）

实景三维模型（倾斜摄影）

- 获取方式（google map中没有大陆地区的倾斜摄影数据）见[在线获取google map倾斜摄影](https://developers.google.com/maps/documentation/tile/3d-tiles?hl=en)
  [香港区域的倾斜摄影](https://www.pland.gov.hk/pland_sc/resources/info_serv/open_data/index.html)(可下osgb/obj/3dtiles格式)
- OSGB(常用通用格式 ) -> 3dtiles(.b3dm)
- 关于osgb数据的处理方式
  - 可使用CC(contextcapture)进行查看

  - c++相关库osg

  - Cesiumlab 倾斜摄影切片功能，结果是3dtiles格式

  - 图新地球可加载显示

  - 超图可处理成s3bm格式，但易崩溃

  - [3dtiles](https://github.com/fanvanzh/3dtiles)开源工具处理
    - osgb->3d-Tiles
    - shapefile->3d-Tiles
    - fbx->3d-Tiles
    - ...

    ```bash
    3dtile.exe [FLAGS] [OPTIONS] --format <FORMAT> --input <PATH> --output <DIR>
    # from osgb dataset
    3dtile.exe -f osgb -i E:\osgb_path -o E:\out_path
    3dtile.exe -f osgb -i E:\osgb_path -o E:\out_path -c "{\"offset\": 0}"
    # use pbr-texture
    3dtile.exe -f osgb -i E:\osgb_path -o E:\out_path -c "{\"pbr\": true}"

    # from single shp file
    3dtile.exe -f shape -i E:\Data\aa.shp -o E:\Data\aa --height height

    # from single osgb file to glb file
    3dtile.exe -f gltf -i E:\Data\TT\001.osgb -o E:\Data\TT\001.glb

    # from single obj file to glb file
    3dtile.exe -f gltf -i E:\Data\TT\001.obj -o E:\Data\TT\001.glb

    # convert single b3dm file to glb file
    3dtile.exe -f b3dm -i E:\Data\aa.b3dm -o E:\Data\aa.glb

    ```

    参数说明

    ```bash
    -c, --config <JSON> 在命令行传入 json 配置的字符串，json 内容为选配，可部分实现

    json 示例：

    {
      "x": 120,
      "y": 30,
      "offset": 0 , // 模型最低面地面距离
      "max_lvl" : 20 // 处理切片模型到20级停止
    }
    -f, --format <FORMAT> 输入数据格式。

    FORMAT 可选：osgb, shape, gltf, b3dm

    osgb 为倾斜摄影格式数据, shape 为 Shapefile 面数据, gltf 为单一通用模型转gltf, b3dm 为单个3dtile二进制数据转gltf

    -i, --input <PATH> 输入数据的目录，osgb数据截止到 <DIR>/Data 目录的上一级，其他格式具体到文件名。

    -o, --output <DIR> 输出目录。输出的数据文件位于 <DIR>/Data 目录。

    --height 高度字段。指定shapefile中的高度属性字段，此项为转换 shp 时的必须参数。
    ```

    数据要求

    ```
    ①倾斜摄影数据
    倾斜摄影数据仅支持 smart3d 格式的 osgb 组织方式：

    数据目录必须有一个 “Data” 目录的总入口；
    “Data” 目录同级放置一个 metadata.xml 文件用来记录模型的位置信息；
    每个瓦片目录下，必须有个和目录名同名的 osgb 文件，否则无法识别根节点；
    正确的目录结构示意：

    - Your-data-folder
      ├ metadata.xml
      └ Data\Tile_000_000\Tile_000_000.osgb
    ② Shapefile
    目前仅支持 Shapefile 的面数据，可用于建筑物轮廓批量生成 3D-Tiles.

    Shapefile 中需要有字段来表示高度信息。

    ③ 通用模型转 glTF：
    支持 osg、osgb、obj、fbx、3ds 等单一通用模型数据转为 gltf、glb 格式。

    转出格式为 2.0 的gltf，可在以下网址验证查看： [clay-viewer](https://pissang.github.io/clay-viewer/editor/)

    ④ B3dm 单文件转 glb
    支持将 b3dm 单个文件转成 glb 格式，便于调试程序和测试数据
    ```

  - 可使用renderdoc进行对google map 倾斜数据的爬取，但是这种方式爬取出来的模型是一小块一小块的obj格式，可以用blender进行处理，不带有坐标系

动态

- czml
  - CZML是一种用来描述动态场景的JSON架构的语言，主要用于Cesium在浏览器中的展示。通过制作CZML文件，在Cesium进行数据的批量加载，省去单独循环一个一个加载对象的方式。
- KML/KMZ
  - cesium 支持kml的时序的显示，关联cesium的时间轴。kmz是kml的压缩模式，其中的文件包含kml及相关的png图片文件，kml是谷歌地球支持的一种格式，可以使用谷歌地球直接加载显示

多模型格式之间转换c++库（[Assimp](https://github.com/assimp/assimp)）

## 气象数据

常见气象数据为[NetCDF](https://www.unidata.ucar.edu/software/netcdf/)/.json/.csv格式，不管是什么格式，其中包含的数据均是多维度的，例如台风，其中的数据有经纬度对应的风速，风向等

数据来源：

### [CRU_TS气象数据](https://crudata.uea.ac.uk/cru/data/hrg/) （下载的数据为nc格式）

该网页界面各个单词代表的含义如下表，如果你需要下载温度、云量、霜天数等，找到对应的数据下载

![20211221214249](/img/GIS相关数据类型简介/20211221214249.png)

### [NCDC FTP下载](<ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite/ >) （下载的数据为ISD-Lite）

气象数据按年从1942—2021打包,文件名称为“china*isd_lite*\*\*\*\*.zip”。解压后是各个站点的全年气象数据。文件名如“508440-99999-2013”；其中，第1字段“508440”是站点ID，第3字段“2013”是年份。

数据格式ISD-Lite，是简化的ISD（Integrated Surface Data）数据。每列固定宽度，容易程序解析，也可直接当做“空格分隔的CSV”使用，也可利用Excel数据分列进行查看。具体每列的含义及数据格式见isd-lite-format.txt，有详细解释。时间是GMT时间。

> ISD-Lite 产品旨在更轻松地处理更大的集成表面数据每小时数据集的子集。 ISD-Lite 包含八个以固定宽度格式表示的常见小时时间序列气候变量。 提取的元素是：
>
> 气温（摄氏度*10）
> 露点温度（摄氏度*10）
> 海平面压力（百帕斯卡）
> 风向（角度）
> 风速（米/秒\*10）
> 总云量（编码，见格式文档）
> 一小时累计液体沉淀（毫米）
> 六小时累积液体沉淀（毫米）

### [CHELSA气象数据](https://chelsa-climate.org/)(下载的数据为.tif格式)

CHELSA (Climatologies at high resolution for the earth’s land surface areas)高分辨率陆地表层气候学数据，分辨率30弧秒，约1km，是由瑞士联邦森林雪景观研究所（Swiss Federal Institute for Forest, Snow and Landscape Research WSL）开发维护的全球降尺度气候数据。

#### 数据命名

CHELSA数据遵循以下命名方式：

```
CHELSA_[short_name]_[timeperiod]_[Version].tif
```

- short_name用来区别文件类型
- timeperiod时间
- Version版本

### [国家地球系统科学数据中心](http://www.geodata.cn/)

### [天气数据](https://rp5.ru/)(下载的数据为xls,csv格式)

参考资料:

[【数据获取】（3）气象数据免费下载(超级好用)](https://zhuanlan.zhihu.com/p/378693127)

[国家气象科学数据中心](http://data.cma.cn/)

### 模型转换

大概思路：

- 先找可以打开这个格式的软件，一般常用的建模软件有3dmax(.3ds)/c4d(.c4d)/CAD(.DWF/.DXF)/blender(.blender)/Sketchup(.skp)...
- 通过这些软件去将相关模型导出通用的obj格式
- 再将obj格式转为想要使用的格式就好了

一些模型处理工具：

- [FME](http://www.fme-china.com/html/kownledge.html) 可以对大多数数据，包括空间数据进行处理
- [fmechina csdn博客](https://blog.csdn.net/fmechina?type=blog)
- [Cesiumlab](http://www.cesiumlab.com/)
- [3dtiles](https://github.com/fanvanzh/3dtiles)
- [obj2gltf](https://github.com/CesiumGS/obj2gltf)
- [obj23dtiles](https://github.com/PrincessGod/objTo3d-tiles) 基于cesium官方的obj2gltf开发
- [fbx2gltf](https://github.com/facebookincubator/FBX2glTF/tree/main)   可以将3dmax导出的fbx格式转为gltf; 没用过，我一般都是用blender加载后直接导出gltf
- [Cesium3DTilesConverter](https://github.com/scially/Cesium3DTilesConverter) OSGB、Shp、GDB等格式转为3DTiles（基于fanvanzh/3dtiles修改，用C++和Qt重写）
- [3d-tiles-tools](https://github.com/CesiumGS/3d-tiles-tools) Cesium官方的转换工具glb->b3dm(需要自己写tileset.json)

## Python相关数据处理

见[Python 地理空间分析指南](https://github.com/hanke-janson/SimpleGIS)

## FME相关使用手册

见[FME入门](https://hanke-janson.github.io/blog/2025/05/13/FME%E5%85%A5%E9%97%A8/)

## ProJ相关使用细节

见[proj入门](https://hanke-janson.github.io/blog/2025/05/13/proj%E5%85%A5%E9%97%A8/)
