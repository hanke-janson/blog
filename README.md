# blog
Hexo搭建

## 安装Hexo

```shell
npm install hexo-cli -g # 全局安装hexo的命令行程序
hexo init blog # 初始化项目
cd blog # 切换到项目目录
yarn install # 安装项目依赖
yarn server # 启动hexo服务
```
然后在浏览器中访问 http://localhost:4000 就可以看到博客页面了。

## 格式化检查

```shell
yarn prettier --check ./source
yarn prettier --write ./source
```

## 压缩

1. 安装依赖：
```shell
yarn add gulp --save-dev
yarn add gulp-minify-css gulp-babel gulp-uglify gulp-htmlmin gulp-htmlclean gulp-imagemin imagemin-jpegtran imagemin-svgo imagemin-gifsicle imagemin-optipng --save-dev
```
2. 在 `yarn build` 执行后执行压缩命令 `gulp`

## 更换主题(fluid主题)

下载fluid主题：
```shell
cd blog
yarn add hexo-theme-fluid --save
```
然后在博客目录下创建 _config.fluid.yml，将主题的 _config.yml (opens new window)内容复制过去

修改配置文件`_config.yml`中的相关字段：
```yaml
# 指定主题
theme: fluid
# 指定语言，会影响主题显示的语言，按需修改
language: zh-CN
# 在生成文章的时候生成一个同名的资源目录用于存放图片文件
post_asset_folder: true
```

## 创建「关于页」

首次使用主题的「关于页」需要手动创建：
```shell
yarn new page about
```
创建成功后，编辑博客目录下 /source/about/index.md，添加 layout 属性。
```text
---
title: about
date: 2025-05-03 02:27:47
layout: about
---
```

## 创建文章

```shell
yarn new 文章标题
```
