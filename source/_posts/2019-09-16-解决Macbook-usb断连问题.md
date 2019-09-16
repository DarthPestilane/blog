---
title: 解决Macbook usb断连问题
date: 2019-09-16 09:48:32
categories:
- 笔记
tags:
- mac
---

有一天想用macbook的usb接口给苹果手机充电，连上之后出现连接不稳定，充电断断续续的情况。
换了另一台手机和另一根数据线，也出现这样的情况，当时以为是电脑出问题了。
后来在网上找到了解决方法。

执行下面两个命令，可以让usbd服务重启，从而解决连接不稳定的问题。

```sh
sudo killall -STOP -c usbd # will pause the issue related process
```

```sh
sudo killall -CONT usbd # will resume the process
```
