---
title: Linux换源
date: 2025-07-11 00:24:45
categories: Linux
tags: [Linux]
---

# Linux换源

## Ubuntu 18.04

### 备份源

```bash
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
```

### 更新源

```bash
sudo sed -i 's|http://.*archive.ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list && sudo sed -i 's|http://.*security.ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list && sudo apt update
```
