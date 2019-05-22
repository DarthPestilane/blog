---
title: iPhoneXS Jailbreak
date: 2019-05-21 17:45:56
categories:
- 笔记
tags:
- jailbreak
---

## 起因

手中的 iPhone XS 为了这次越狱，一直坚持停留在 `iOS12.1` 版本，不过也没什么升级动力。昨天惊喜地发现 YouTube 上有人上传了 [`Top 75 Best FREE iOS 12.1.2 Jailbreak Tweaks! A12 Compatible Tweaks!`](https://www.youtube.com/watch?v=2YceB70p2Ms) 视频，满怀期待地点进去看，果然是有越狱工具 release 了！

## 开始越狱

根据视频里的内容，使用 [`Chimera`](https://chimera.sh/) 作为越狱工具，在手机上安装好后，就可以直接一键越狱了。刚开始没注意到可以在已知漏洞中选择一个作为越狱方式，而直接点了 Jailbreak 按钮，结果中途重启了好几次，但最终也完成了越狱，并且安装上了 `Sileo`（Cydia 的替代品）。后来的折腾中，发现使用 `m***2` 这个漏洞，可以非常顺滑地完成越狱，不会遇到重启。

<!-- more -->

## 插件安装

完成越狱后，非常兴奋地点开 `Sileo`，但是却出现了让我耗费许多时间才得以解决的问题。`Sileo` 无法更新源列表，一刷新就会报404的错，这样一来就几乎无法安装任何插件。 Google 了一番也没看见靠谱的解决方法，看了好多无非都是让你重新越狱，或者让你打开 `Sileo` 的网络权限，可是这个时候的 `Sileo` 根本不会出现在网络权限app列表中。于是继续 Google，终于找到了解决方案：

- 使用爱思助手，下载 `乐网` 到手机上
- 打开 `乐网` 使用全局模式
- 此时打开 `Sileo` 就可以刷新源列表了！
- 后来就可以在网络权限里找到 `Sileo` 了！

OK，既然 `Sileo` 可以正常联网了，已经迫不及待地想去安装插件了，但是又遇到了另一个棘手的问题。当成功安装好插件并完成 respring 后，插件既没有生效，而且也不会在 `设置` 中显示该插件选项，于是又开始 Google，又尝试了很多没有用的方法，比如重新安装 `rockebootstrap`、`preferenceLoader` 等插件，其实这些插件已经是最新版本了。最后通过 ssh 连上手机，找到插件的配置文件的位置，并手动拷贝到另一个目录下才得以解决：

首先使用 ssh 连接到手机：`ssh root@your_ip`，初始密码是 `alpine`，登录后记得马上把密码改了。经过简单的探索，发现安装后的插件的配置文件（`.plist` 和 `.dylib`）都会存放在 `/Library/MobileSubstrate/DynamicLibraries` 目录下，而要想使插件生效，则需要将这些配置文件放到 `/Library/TweakInject` 目录中，于是手动 copy 并 respring 后，所有插件都生效了，并且其选项也出现在 `设置` 中。

这个问题的出现可能来自于越狱工具本身，其现象是没有自动复制插件的配置到正确路径。虽然插件可以正常使用了，但是按照这样手动 copy 的方式来完成插件的安装是很不方便的，依然需要思考更好的方案。

其实很容易就发现 `/Library/TweakInject` 这个目录是个软链接，target 是 `/usr/lib/TweakInject`，也就是说插件的配置文件最终都被 copy 到了这里。于是我将 `/Library/MobileSubstrate/DynamicLibraries` 备份后，也做成了软链接，target 也是 `/usr/lib/TweakInject`，respring 后安装了一个新的插件，结果新插件成功生效，原有的插件依然可用！至此，插件安装的问题算是成功解决了。

## 感想

越狱成功，挺高兴的，因为可以安装许多有用的插件了，这些插件将iOS系统变得更加方便顺手。此时想起一句话：

> 越狱之后，iOS才能发挥出它真正的强大。

使用 `Chimera` 越狱，体验是很好的，不过还是存在bug，比如 `Sileo` 网络权限问题和插件安装问题，解决方法都挺简单但是搜索方法的过程就不太容易了，不能立马Google到，这或许也反映出越狱的需求真的在逐渐减少。然而 `Sileo` 相比 `Cydia` 实在是好太多了，至少是这个时代的产品，而 `Cydia` 明显已经过时了。想想上一次越狱还是2015年左右，当时用的是 iPhone 5c，iOS 版本是 7.x，那时的越狱体验是真的好啊，尤其是盘古，一次性成功，完美越狱，插件可用，不需要折腾。

虽然现在处于半完美越狱状态，重启之后将恢复到非越狱状态，但在我看来这也是一种不错的选择。