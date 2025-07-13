---
title: VIM插件
date: 2025-07-14 00:10:02
categories: vim
tags: [vim, plugin]
---

# VIM插件

## 使用vim-plug管理插件

[vim-plug](https://github.com/junegunn/vim-plug)

## 配置文件

以下是我目前.vimrc文件的配置

```shell
" 基本配置
syntax on                     " 设置语法高亮
set nu                        " 设置行数显示
set tabstop=4                 " 设置tab缩进长度为4空格
set autoindent                " 设置自动缩进，适用所有类型文件
set cindent                   " 针对C语言的自动缩进功能，在C语言的编程环境中，比autoindent更加精准
set list lcs=tab:\|\          " 设置tab提示符号为 "|"，注意最后一个反斜杠后面要留有空格
set cc=0                      " 设置高亮的列，这里设置为0，代表关闭
set cursorline                " 突出显示当前行
" 插件列表
call plug#begin()
" 一些基本且符合直觉的配置
Plug 'tpope/vim-sensible'
" git管理
Plug 'tpope/vim-fugitive'
" 目录树
Plug 'scrooloose/nerdtree'
" 代码结构
Plug 'majutsushi/tagbar'
" 突出光标所在单词
Plug 'rrethy/vim-illuminate'
" 模糊搜索
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" Plugins for UI
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" 图标
Plug 'ryanoasis/vim-devicons'

call plug#end()
```
