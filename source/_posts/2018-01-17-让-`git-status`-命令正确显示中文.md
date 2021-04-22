---
title: 让 `git status` 命令正确显示中文
date: 2018-01-17 16:22:46
tags:
- git
categories:
- 笔记
---
环境是 `macOS` 。每当使用 `git status` 时，只要修改了带有中文的文件，在控制台输出的中文部分都会被转义成 `Unicode` ，阅读体验不太好。

![image](https://qiniu.wrzsj.top/blog/asset/img/gBwC5W)

为了更好的体验，我修改了 `git` 的一个核心设置: `git config --global core.quotepath false` ，从此，再无困扰。

![image](https://qiniu.wrzsj.top/blog/asset/img/gBwcXw)
