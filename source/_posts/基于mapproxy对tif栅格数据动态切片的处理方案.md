---
title: 基于mapproxy对tif栅格数据动态切片的处理方案
date: 2025-05-10 16:34:08
categories: GIS
tags: [Mapserver, Mapcache, Mapproxy, WMS, WMTS, Tiff]
---

# 基于mapproxy对tif栅格数据动态切片的处理方案

## 整体流程

1 mapserver和mapcache服务的搭建

2 对tiff文件进行预处理(通过gdal外建金字塔)

3 编写map文件发布wms服务

4 编写mapcache.xml文件发布wmts服务（动态读取配置文件方法暂时未找到）

5 编写mapproxy.yaml文件发布wmts服务，该方式的优势在于地图的样式处理以及可以动态的读取配置文件(注: 在服务启动的时候指定配置文件)

## 1 服务搭建

### 1 mapserver的镜像安装

直接拉取 [mapserver](<[camptocamp/mapserver Tags | Docker Hub](https://hub.docker.com/r/camptocamp/mapserver/tags) >) 镜像

```bash
docker pull camptocamp/mapserver
```

```bash
docker run -d -p 60080:80 -v /mnt/mapserver_test/mapfiles:/etc/mapserver --name mapserver camptocamp/mapserver:7.6
```

这里挂载的目录mapfiles，里面放map文件

### 2 mapcache的镜像安装

dockerfile：

```dockerfile
FROM ubuntu:18.04
COPY ./mapcache-rel-1-14-0.tar.gz  /etc/mapcache-rel-1-14-0.tar.gz
ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive
RUN sed -i 's#http://archive.ubuntu.com/#http://mirrors.tuna.tsinghua.edu.cn/#' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y build-essential cmake apache2 apache2-dev libpng-dev libjpeg-dev libcurl4-gnutls-dev libpcre3-dev libpixman-1-dev libfcgi-dev libgdal-dev libgeos-dev libsqlite3-dev libtiff-dev libdb-dev liblmdb-dev libaprutil1-dev libsqlite3-dev libhiredis-dev libdb5.3-dev && \
    cd /etc && tar -zxvf ./mapcache-rel-1-14-0.tar.gz  && \
    cd ./mapcache-rel-1-14-0 && mkdir build && \
    cd build && cmake .. && \
    make && make install && \
    mkdir /etc/mapcache && mkdir /etc/mapcache/config && \
    cp ../mapcache.xml /etc/mapcache/config/ && \
    cp ../mapcache.xml.sample /etc/mapcache/config/ && \
    service apache2 start

```

> 在/etc/apache2/conf-enabled目录下新建mapcache.conf，这里配置mapcache.xml文件的路径（要挂载出去的）
>
> ```conf
> LoadModule mapcache_module    /usr/lib/apache2/modules/mod_mapcache.so
> <IfModule mapcache_module>
>    <Directory /etc/mapcache/config>
>       Require all granted
>    </Directory>
>    MapCacheAlias /mapcache "/etc/mapcache/config/mapcache.xml"
> </IfModule>
> ServerName localhost
> ```
>
> ```bash
> chmod 777 /etc/mapcache
> chmod 777 /etc/tiles
> a2enmod actions cgi alias headers mapcache
> service apache2 restart
> ```

构建镜像

```bash
docker build -t mapcache:v1.0 .
```

启动mapcache容器

```bash
docker run -dit -p 60081:80 \
-v /mnt/mapserver_test/mapcache/config:/etc/mapcache/config \
-v /mnt/mapserver_test/mapcache/tiles:/etc/mapcache/tiles \
--name mapcache mapcache:v1.0
```

这里挂载的目录config，里面放mapcache.xml文件

这里挂载的目录tiles，里面放动态切片缓存文件

### 3 mapproxy安装(因为mapcache修改配置文件需要重启apache所以选用mapproxy)

从[github](https://github.com/mapproxy/mapproxy)安装，[官网](https://mapproxy.org/)不怎么更新了，最新[文档](http://mapproxy.github.io/mapproxy/)

[官方docker安装](http://mapproxy.github.io/mapproxy/install_docker.html#quickstart)

```bash
# 以下是加速过的镜像
# 以-dev结尾，启动通过mapproxy-utilserve-develop提供的集成 Web 服务器 mapproxy
docker pull togettoyou/ghcr.io.mapproxy.mapproxy.mapproxy:1.16.0-dev
docker tag togettoyou/ghcr.io.mapproxy.mapproxy.mapproxy:1.16.0-dev ghcr.io/mapproxy/mapproxy/mapproxy:1.16.0-dev
# 已经安装了所有内容，但没有运行 HTTP WebServer。您可以使用它来实现您的自定义设置。
docker pull togettoyou/ghcr.io.mapproxy.mapproxy.mapproxy:1.16.0
docker tag togettoyou/ghcr.io.mapproxy.mapproxy.mapproxy:1.16.0 ghcr.io/mapproxy/mapproxy/mapproxy:1.16.0
# 以-nginx结尾，与预配置的nginx HTTP 服务器捆绑在一起，使您可以在生产环境中立即使用 MapProxy。
docker pull togettoyou/ghcr.io.mapproxy.mapproxy.mapproxy:1.16.0-nginx
docker tag togettoyou/ghcr.io.mapproxy.mapproxy.mapproxy:1.16.0-nginx ghcr.io/mapproxy/mapproxy/mapproxy:1.16.0-nginx
```

```bash
docker run --rm --name "mapproxy_test" -p 60083:80 -d -t -v `pwd`/mapproxyconfig:/mapproxy/config ghcr.io/mapproxy/mapproxy/mapproxy:1.16.0-nginx
```

> http://192.168.12.1:60083/mapproxy/demo/ 即可访问

MapProxy 支持 TMS 作为源 可以替代mapcache

样式 支持sld

手动安装测试

> 测试使用python3.8
>
> ```cmd
> pip install MapProxy==1.13.0
> ```
>
> ```cmd
> pip install pyproj==3.5.0
> ```
>
> > 报错: AttributeError: 'ImageDraw' object has no attribute 'textsize'
> >
> > 解决: pip install Pillow==9.5.0
>
> 检查版本
>
> ```cmd
> mapproxy-util --version
> ```
>
> 启动测试服务器
>
> ```cmd
> mapproxy-util serve-develop mapproxy.yaml -b 0.0.0.0:8011
> ```
>
> > 修改配置文件 可动态加载，但配置文件出错，mapproxy掉线
>
> mapproxy-seed 瓦片预生成
>
> ```bash
> # 验证
> mapproxy-seed -f mapproxy.yaml -s seed.yaml --dry-run
> # 预生成瓦片
> mapproxy-seed -f mapproxy.yaml -s seed.yaml
> ```

wmts 静态瓦片服务

```yaml
services:
  demo:
  wmts:
    restful: true
    restful_template: "/{Layer}/{TileMatrixSet}/{TileMatrix}/{TileCol}/{TileRow}.{Format}"
    kvp: true
  wms:
    md:
      title: MapProxy WMS Proxy
      abstract: This is a minimal MapProxy example.
layers:
  - name: osm
    title: Omniscale OSM WMS - osm.omniscale.net
    sources: [osm_cache]
  - name: tianditu
    title: tianditu
    sources: [tianditu_cache]

caches:
  osm_cache:
    grids: [webmercator]
    sources: [osm_wms]
  tianditu_cache:
    disable_storage: true
    grids: [tianditu_srs]
    sources: [tianditu]
sources:
  osm_wms:
    type: wms
    req:
      url: https://maps.omniscale.net/v2/demo/style.default/service?
      layers: osm
  tianditu:
    type: tile
    grid: tianditu_srs
    url: file:///E:/map_tianditu-img/%(z)s/%(x)s/%(y)s.png
grids:
  webmercator:
    base: GLOBAL_WEBMERCATOR
  tianditu_srs:
    srs: "EPSG:4490"
    bbox: [-180, -85.05112877980659, 180, 85.05112877980659]
    origin: nw
globals:
```

## 2 对tiff文件进行外建金字塔

环境: gdal

使用 gdaladdo 工具对tif文件进行外建金字塔

```bash
gdaladdo -ro --config COMPRESS_OVERVIEW DEFLATE .\XX12-1_CCD_000304934_MMB07_001_01_002_003_L2.tiff 2 4 8 16
```

## 3 通过mapserver对tif文件进行wms服务发布

一份数据对应一个map文件

```map
MAP
  IMAGETYPE      "PNG"
  EXTENT         358666.700 3885743.400  394493.400 3913242.200
  SIZE           256 256
  SHAPEPATH      "D:/mapserver/testTiff/tiff-data"
  IMAGECOLOR     255 255 255
  DEBUG          5
  # 设置 调试日志 目录 级别
  CONFIG "MS_ERRORFILE" "D:/mapserver/testTiff/tiff-data/ms_error.txt"
  PROJECTION
   "init=epsg:32654"
  END
  LAYER
    NAME         "XX12-1_CCD_000304934_MMB07_001_01_002_003_L2"
    DATA         "XX12-1_CCD_000304934_MMB07_001_01_002_003_L2.tiff"
   UNITS        meters
    STATUS       DEFAULT
    TYPE         RASTER
  END
  WEB
    METADATA
      "tile_map_edge_buffer" "10"
      "tile_metatile_level" "0"
       "wms_enable_request" "*"
    END #metadata
  END #web
END
```

```
http://localhost/cgi-bin/mapserv.exe?map=D:\mapserver\testTiff\tiff-data\XX12-1_CCD_000304934_MMB07_001_01_002_003_L2.map&layers=XX12-1_CCD_000304934_MMB07_001_01_002_003_L2&mode=map
```

## 4 通过mapcache 基于mapserver对tif文件进行wmts服务发布

所有图层都要写到这一个配置文件中

```xml
<?xml version="1.0" encoding="UTF-8"?>

<!-- see the accompanying mapcache.xml.sample for a fully commented configuration file -->

<mapcache>
   <cache name="wmts_cache" type="disk">
      <!-- 配置容器内路径，把这个路径给挂载出来 -->
      <base>/etc/mapcache/tiles/cache</base>
      <detect_blank/>
      <!-- 创建切片文件或符号链接失败时应重试的次数, -->
      <creation_retry>3</creation_retry>
   </cache>
   <!-- XX12-1_CCD_000304934_MMB07_001_01_002_003_L2 -->

   <!-- source name可以写map文件的图层名称 -->
   <source name="XX12-1_CCD_000304934_MMB07_001_01_002_003_L2" type="wms">
      <http>
         <!-- 配置mapserver cgi url -->
         <url>http://192.168.1.83/cgi-bin/mapserv.exe?</url>
      </http>
      <getmap>
         <params>
            <FORMAT>image/png</FORMAT>
            <LAYERS>XX12-1_CCD_000304934_MMB07_001_01_002_003_L2</LAYERS>
            <!-- mapserver中的map文件路径 -->
            <MAP>D:\mapserver\testTiff\tiff-data\XX12-1_CCD_000304934_MMB07_001_01_002_003_L2.map</MAP>
         </params>
      </getmap>
   </source>
   <!-- tileset的name是mapcache wmts请求时的layer名 -->
   <tileset name="XX12-1_CCD_000304934_MMB07_001_01_002_003_L2">
      <source>XX12-1_CCD_000304934_MMB07_001_01_002_003_L2</source>
      <cache>wmts_cache</cache>
      <!--<grid>GoogleMapsCompatible</grid>-->
      <!-- 与mapfile中一致 在grid中自定义坐标系 -->
      <grid>XX12-1_CCD_000304934_MMB07_001_01_002_003_L2</grid>
      <format>PNG</format>
      <metatile>5 5</metatile>
      <metabuffer>10</metabuffer>
      <!-- 图块过期时间 -->
      <expires>3600</expires>
   </tileset>
   <!-- 自定义坐标系 -->
   <grid name="XX12-1_CCD_000304934_MMB07_001_01_002_003_L2">
      <metadata>
         <title>EPSG:32654</title>
         <WellKnownScaleSet>EPSG:32654</WellKnownScaleSet>
      </metadata>
      <!-- 写坐标的范围，去epsg.io查 -->
      <extent>358666.700 3885743.400  394493.400 3913242.200</extent>
      <srs>EPSG:32654</srs>
      <!-- 若是投影坐标m，地理坐标dd -->
      <units>m</units>
      <size>256 256</size>
      <!-- 网格定义的每个缩放级别的分辨率列表 参照官网 https://www.osgeo.cn/mapserver/mapcache/config.html -->
      <resolutions>156543.0339280410 78271.51696402048 39135.75848201023 19567.87924100512 9783.939620502561 4891.969810251280 2445.984905125640 1222.992452562820 611.4962262814100 305.7481131407048 152.8740565703525 76.43702828517624 38.21851414258813 19.10925707129406 9.554628535647032 4.777314267823516 2.388657133911758 1.194328566955879 0.5971642834779395</resolutions>
   </grid>
   <!-- SV1-02_20201223_L2A0001250286_8042200089370002_01-PAN -->

   <!-- source name可以写map文件的图层名称 -->
   <source name="SV1-02_2020" type="wms">
      <http>
         <!-- 配置mapserver cgi url -->
         <url>http://192.168.1.83/cgi-bin/mapserv.exe?</url>
      </http>
      <getmap>
         <params>
            <FORMAT>image/png</FORMAT>
            <LAYERS>SV1-02_20201223_L2A0001250286_8042200089370002_01-PAN</LAYERS>
            <!-- mapserver中的map文件路径 -->
            <MAP>D:\mapserver\testTiff\tiff-data\SV1-02_20201223_L2A0001250286_8042200089370002_01-PAN.map</MAP>
         </params>
      </getmap>
   </source>
   <!-- tileset的name是mapcache wmts请求时的layer名 -->
   <tileset name="SV1-02_2020">
      <source>SV1-02_2020</source>
      <cache>wmts_cache</cache>
      <!--<grid>GoogleMapsCompatible</grid>-->
      <!-- 与mapfile中一致 在grid中自定义坐标系 -->
      <grid>SV1-02_20201223_L2A0001250286_8042200089370002_01-PAN</grid>
      <format>PNG</format>
      <metatile>5 5</metatile>
      <metabuffer>10</metabuffer>
      <expires>3600</expires>
   </tileset>
   <!-- 自定义坐标系 -->
   <grid name="SV1-02_20201223_L2A0001250286_8042200089370002_01-PAN">
      <metadata>
         <title>EPSG:32654</title>
         <WellKnownScaleSet>EPSG:32654</WellKnownScaleSet>
      </metadata>
      <!-- 写坐标的范围，去epsg.io查/或者数据本身的范围 -->
      <extent>368705.000 3895063.000  386800.000  3912905.000</extent>
      <srs>EPSG:32654</srs>
      <!-- 若是投影坐标m，地理坐标dd -->
      <units>m</units>
      <size>256 256</size>
      <!-- 网格定义的每个缩放级别的分辨率列表 参照官网 https://www.osgeo.cn/mapserver/mapcache/config.html -->
      <resolutions>156543.0339280410 78271.51696402048 39135.75848201023 19567.87924100512 9783.939620502561 4891.969810251280 2445.984905125640 1222.992452562820 611.4962262814100 305.7481131407048 152.8740565703525 76.43702828517624 38.21851414258813 19.10925707129406 9.554628535647032 4.777314267823516 2.388657133911758 1.194328566955879 0.5971642834779395</resolutions>
   </grid>
   <!-- SV1-01_20170319_L2A0001250288_8042200089330001_01-PAN -->

   <!-- source name可以写map文件的图层名称 -->
   <source name="SV1-01_2017" type="wms">
      <http>
         <!-- 配置mapserver cgi url -->
         <url>http://192.168.1.83/cgi-bin/mapserv.exe?</url>
      </http>
      <getmap>
         <params>
            <FORMAT>image/png</FORMAT>
            <LAYERS>SV1-01_20170319_L2A0001250288_8042200089330001_01-PAN</LAYERS>
            <!-- mapserver中的map文件路径 -->
            <MAP>D:\mapserver\testTiff\tiff-data\SV1-01_20170319_L2A0001250288_8042200089330001_01-PAN.map</MAP>
         </params>
      </getmap>
   </source>
   <!-- tileset的name是mapcache wmts请求时的layer名 -->
   <tileset name="SV1-01_2017">
      <source>SV1-01_2017</source>
      <cache>wmts_cache</cache>
      <!--<grid>GoogleMapsCompatible</grid>-->
      <!-- 与mapfile中一致 在grid中自定义坐标系 -->
      <grid>SV1-01_20170319_L2A0001250288_8042200089330001_01-PAN</grid>
      <format>PNG</format>
      <metatile>5 5</metatile>
      <metabuffer>10</metabuffer>
      <expires>3600</expires>
   </tileset>
   <!-- 自定义坐标系 -->
   <grid name="SV1-01_20170319_L2A0001250288_8042200089330001_01-PAN">
      <metadata>
         <title>EPSG:32654</title>
         <WellKnownScaleSet>EPSG:32654</WellKnownScaleSet>
      </metadata>
      <!-- 写坐标的范围，去epsg.io查 -->
      <extent>372244.500 3894777.500 389529.000 3911999.500</extent>
      <srs>EPSG:32654</srs>
      <!-- 若是投影坐标m，地理坐标dd -->
      <units>m</units>
      <size>256 256</size>
      <!-- 网格定义的每个缩放级别的分辨率列表 参照官网 https://www.osgeo.cn/mapserver/mapcache/config.html -->
      <resolutions>156543.0339280410 78271.51696402048 39135.75848201023 19567.87924100512 9783.939620502561 4891.969810251280 2445.984905125640 1222.992452562820 611.4962262814100 305.7481131407048 152.8740565703525 76.43702828517624 38.21851414258813 19.10925707129406 9.554628535647032 4.777314267823516 2.388657133911758 1.194328566955879 0.5971642834779395</resolutions>
   </grid>
   <default_format>PNG</default_format>
   <service type="wms" enabled="true">
      <full_wmts>assemble</full_wmts>
      <resampling>bilinear</resampling>
      <format>PNG</format>
      <max_tile_age>0</max_tile_age>
   </service>
   <service type="wmts" enabled="true"/>
   <service type="demo" enabled="true"/>
   <service type="tms" enabled="false"/>
   <service type="kml" enabled="false"/>
   <service type="gmaps" enabled="false"/>
   <service type="ve" enabled="false"/>


   <errors>report</errors>
   <!--<lock_dir type="disk">
       <directory>/etc/mapcache/tiles/cache</directory>
   </lock_dir>-->
   <!-- use multiple threads when fetching multiple tiles (used for wms tile assembling -->
   <threaded_fetching>true</threaded_fetching>
   <!-- fastcgi only -->
   <log_level>debug</log_level>
   <auto_reload>true</auto_reload>
</mapcache>
```

```
http://192.168.12.1:60081/mapcache/demo/wmts
```

## 5 编写mapproxy.yaml文件发布wmts服务

```yaml
services:
  demo:
  wmts:
    restful: true
    restful_template: "/{Layer}/{TileMatrixSet}/{TileMatrix}/{TileCol}/{TileRow}.{Format}"
    kvp: true
    md:
      title: WMTS Proxy
  wms:
    srs: ["EPSG:3857", "EPSG:4326", "EPSG:32654"]
    # only offer WMS 1.1.1
    versions: ["1.1.1"]
    # limit the supported image formats.
    image_formats:
      ["image/jpeg", "image/png", "image/gif", "image/GeoTIFF", "image/tiff"]
    # return an OGC service exception when one or more sources return errors
    # or no response at all (e.g. timeout)
    on_source_errors: raise
    # maximum output size for a WMS requests in pixel, default is 4000 x 4000
    # compares the product, eg. 3000x1000 pixel < 2000x2000 pixel and is still
    # permitted
    max_output_pixels: [2000, 2000]
    # some WMS clients do not send all required parameters in feature info
    # requests, MapProxy ignores these errors unless you set strict to true.
    strict: true
    featureinfo_types: ["text", "html", "xml"]
layers:
  - name: XX12-1_CCD_000304934_MMB07_001_01_002_003_L2
    title: XX12-1_CCD_000304934_MMB07_001_01_002_003_L2
    sources: [XX12-1_CCD_000304934_MMB07_001_01_002_003_L2_cache]
caches:
  XX12-1_CCD_000304934_MMB07_001_01_002_003_L2_cache:
    grids: [XX12-1_CCD_000304934_MMB07_001_01_002_003_L2_srs]
    sources: [XX12-1_CCD_000304934_MMB07_001_01_002_003_L2]
    format: image/png
    request_format: image/png
sources:
  XX12-1_CCD_000304934_MMB07_001_01_002_003_L2:
    type: wms
    supported_srs: ["EPSG:3785", "EPSG:4326"]
    req:
      url: http://192.168.1.83/cgi-bin/mapserv.exe?
      layers: XX12-1_CCD_000304934_MMB07_001_01_002_003_L2
      map: D:\mapserver\testTiff\tiff-data\XX12-1_CCD_000304934_MMB07_001_01_002_003_L2.map
grids:
  webmercator:
    base: GLOBAL_WEBMERCATOR
  XX12-1_CCD_000304934_MMB07_001_01_002_003_L2_srs:
    srs: "EPSG:32654"
    bbox: [358666.700, 3885743.400, 394493.400, 3913242.200]
    origin: nw
globals:
```

# 关于数据的样式调整

栅格数据、矢量数据

利用表达式对像素值进行判断赋值，mapproxy可以直接显示mapfile上的样式

```mapfile
 LAYER
        NAME "XX12-1_CCD_000304934_MMB07_001_01_002_003_L2"
        DATA "XX12-1_CCD_000304934_MMB07_001_01_002_003_L2.tiff"
        UNITS        meters
        STATUS       DEFAULT
        TYPE         RASTER
        PROCESSING "BANDS=1" # 设置颜色通道
        PROCESSING "SCALE=0,661" # 设置灰度值范围
        PROCESSING "GAMMA=1.0" # 设置伽马校正
        CLASSITEM "[pixel]"
        CLASS
            NAME "Low Value"
            EXPRESSION ([pixel] < 300) # 根据灰度值进行分级
            STYLE
                COLOR 0 0 255 # 蓝色
            END
        END

        CLASS
            NAME "High Value"
            EXPRESSION ([pixel] >= 300) # 根据灰度值进行分级
            STYLE
                COLOR 255 0 0 # 红色
            END
        END
    END
```

mapcache需要单独配置样式

# 关于tif数据自定义投影的问题

两种解决方式：

1 直接设置坐标系为自动(方便)

> 但是 在mapproxy中设置坐标时不太方便，需要对bbox进行转换，这里可以使用proj

```map
PROJECTION
   AUTO
END
```

2 将tif数据坐标进行重投影，地理坐标系为4326，投影为 3857即可

然后map文件中定义 坐标系为

```map
PROJECTION
        "init=epsg:3857"
END
```

在mapproxy中同理

# 关于tif数据去黑边

```map
MAP
    IMAGETYPE "png8"
    ...
    # 设置背景色 洋红  透明
    IMAGECOLOR "#FF00FF00"
       ...
    LAYER
        ...
        PROCESSING "BANDS=1" # 设置颜色通道
        PROCESSING "SCALE=0,255" # 设置灰度值范围
        PROCESSING "NODATA=0" # 0 是您想要设为透明的值
    END
    ...
    # 设置输出格式 这里使用RGBA,启用透明，去黑边及背景
    OUTPUTFORMAT
        NAME "png8"
        DRIVER AGG/PNG
        MIMETYPE "image/png"
        IMAGEMODE RGBA
        EXTENSION "png"
        FORMATOPTION "GAMMA=1.0"
    END
END
```

mapserver相对geoserver支持外建金字塔

# 测试

| 请求文件                             | 是否建立金字塔 | GeoServer请求时间 | MapServer请求时间 |
| ------------------------------------ | -------------- | ----------------- | ----------------- |
| 重投影后的tif数据 708Mb              | 否             | 17.79s            | 8.58s             |
| 重投影后的tif数据 708Mb 金字塔 589MB | 是             | 185ms             | 0ms~1.18s         |
