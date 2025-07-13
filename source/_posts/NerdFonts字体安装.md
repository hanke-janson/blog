---
title: NerdFonts字体安装
date: 2025-07-14 00:18:20
categories: 字体
tags: [Nerd Fonts]
---

# Nerd Fonts字体安装

官网：[https://github.com/ryanoasis/nerd-fonts](https://www.nerdfonts.com/)

## 安装步骤

> 注意:
> 此方法可以在所有使用 [fontconfig](https://www.freedesktop.org/wiki/Software/fontconfig/) 进行系统字体管理的 _linux_ 发行版上使用。

首先，从项目仓库获取必要的文件

```shell
git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git
```

此命令仅下载必要的文件，省略了 _patched-fonts_ 中包含的字体，以便不使用将不会使用的字体来增加本地仓库的体积，从而允许选择性安装。

进入新创建的文件夹，然后使用以下命令下载字体集

```shell
cd ~/nerd-fonts/
git sparse-checkout add patched-fonts/Meslo
```

该命令会将字体下载到 _patched-fonts_ 文件夹中，完成后，您可以使用提供的 install.sh 脚本安装它们，键入

```shell
./install.sh Meslo
```

_install.sh_ 脚本将字体复制到用户文件夹 ~/.local/share/fonts/，并调用 _fc-cache_ 程序在系统上注册它们。完成后，字体将可用于终端模拟器。

参考：
[rocky-linux/documentation](https://docs.rocky-linux.cn/books/nvchad/nerd_fonts/)
