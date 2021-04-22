---
title: 梅林单线复用Internet+IPTV
date: 2017-10-09 15:51:10
tags:
- router
- merlin
categories:
- 笔记
---

**此方法已无效，无法拿到 backupsettings.conf 了，电信后台修复了这个BUG**

由于装修时网络布线问题，需要把电信光猫的IPTV业务在路由器中和Internet业务分开，达到单线复用

## 设备

- 路由器: `华硕ac68u` 刷了 `梅林7.5`
- 电信光猫版本: `TEWA-500E`

<!-- more -->

## 开始

电信光猫之所以可以做到将Internet和IPTV的流量分开，是由于设置了VLAN，所以需要把光猫的VLAN设置让路由器来接管，在路由器上配置Internet和IPTV的VLAN。

### 找到原有的VLAN配置

首先需要拿到光猫的超级管理员的账号密码。

`TEWA-500E`的获取方式比较简单

0. 登录

1. 登录之后，在地址栏中输入 `192.168.1.1/backupsettings.conf` 会下载到光猫的配置文件

2. 打开配置文件，搜索关键字 `telecom` (忽略大小写) 可以找到密码的配置，在`<Password>`中间

  ```xml
  <X_CT-COM_TeleComAccount>
    <Password>密码</Password>
  </X_CT-COM_TeleComAccount>
  ```

3. 重新登录光猫 账号: `telecomadmin`，密码: `找到的密码`

以超级管理员账号登录后，可以看到VLAN的配置

![image](https://qiniu.wrzsj.top/blog/asset/img/gBwg5J@75_discount)
![image](https://qiniu.wrzsj.top/blog/asset/img/gBwkS0@75_discount)

需要记下上面两个的VLAN ID

Internet的连接模式**可以**设为桥接（非必须），设为桥接后，则需要在路由器完成拨号。

从上图中可以看到，IPTV的VLAN ID是43，Internet的VLAN ID是1372。

然后在VLAN绑定中添加一组

![image](https://qiniu.wrzsj.top/blog/asset/img/gBwZy1@75_discount)

### 在路由器中(梅林固件)，手动配置VLAN

配置如下

![image](https://qiniu.wrzsj.top/blog/asset/img/gBwwcd@75_discount)

### 连线

将光猫的`lan1`口接入路由器的`wan`（如果Internet业务为桥接模式的话，需要在路由器上完成PPPoE拨号），然后将路由器的`lan4`口接入IPTV盒子。大功告成！
