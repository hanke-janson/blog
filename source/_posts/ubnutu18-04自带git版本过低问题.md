---
title: ubnutu18.04自带git版本过低问题
date: 2025-07-12 14:12:39
categories: Linux
tags: [git, ubnutu]
---

# ubnutu18.04自带git版本过低问题

Ubuntu 18.04 默认自带的Git 版本可能比较旧，可以通过以下步骤升级到最新版本：

添加Git PPA 源:打开终端，输入以下命令添加Git 官方的PPA 源：

```bash
sudo add-apt-repository ppa:git-core/ppa
```

按回车键确认添加。
更新软件包列表并安装Git:

```bash
sudo apt update
sudo apt install git
```

输入 y 确认安装。
验证Git 版本:安装完成后，运行以下命令验证Git 版本：

```bash
git --version
```

如果显示的是最新的版本号，说明升级成功。
