---
title: Oracle VM VirtualBox 创建的 Ubuntu 打不开终端界面
date: 2025-07-10 23:30:29
categories: 虚拟机
tags: [VirtualBox, 坑]
---

# Oracle VM VirtualBox 创建的 Ubuntu 打不开终端界面

## 前言

最近打算开始研究c++，在用 Oracle VM VirtualBox 创建 Ubuntu 虚拟机，但是发现创建的 Ubuntu 虚拟机无法打开终端界面，并且乱码，经过一番搜索，发现可能是编码问题，下面是解决方法。

## 解决方法

1. 打开 Ubuntu 虚拟机，进入图形界面。

2. 输入以下命令：

CTRL + ALT + F3 # 进入命令行模式（需要返回桌面时CTRL + ALT + F1）

![alt text](/img/Oracle VM VirtualBox 创建的 Ubuntu 打不开终端界面/终端界面.png)

```bash
# 进入root用户
su
cd /etc/default
vi locale
# 将文件中的 LANG 值修改为 en_US.UTF-8
locale-gen --purge
reboot # 重启虚拟机
```
