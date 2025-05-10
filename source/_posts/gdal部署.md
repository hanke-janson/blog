---
title: gdal部署
date: 2025-05-10 16:52:51
categories: GIS
tags: [GDAL, Dockerfile]
---

# GDAL部署

## amd架构

```dockerfile
FROM alpine:3.17
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
    apk update && \
    apk add -U tzdata curl openssh-client busybox-extras fontconfig mkfontscale && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" >> /etc/timezone && \
	# mkfontscale && mkfontdir && fc-cache && \
	# jre8环境
    apk add -U openjdk8-jre && \
	# gdal java绑定环境
    apk add -U java-gdal
	# gdal实用工具
	# apk add -U gdal-tools
```
