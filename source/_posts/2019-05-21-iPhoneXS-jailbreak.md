---
title: iPhoneXS jailbreak
date: 2019-05-21 17:45:56
categories:
- 笔记
tags:
- jailbreak
---

手中的 iPhone XS 为了这次越狱，一直坚持停留在iOS12.1版本，不过也没什么升级动力。
昨天惊喜的发现 YouTube 上有人上传了 [`Top 75 Best FREE iOS 12.1.2 Jailbreak Tweaks! A12 Compatible Tweaks!`](https://www.youtube.com/watch?v=2YceB70p2Ms) 视频，满怀期待地点进去看，果然是有越狱工具 release 了！

根据视频里的内容，使用 [`Chimera`](https://chimera.sh/) 作为越狱工具，在手机上安装好后，就可以直接一键越狱了。
刚开始没注意可以在已知漏洞中选择一个作为越狱方式，儿直接点了jailbreak 按钮，结果中途重启了好几次，但最终也完成了越狱，并且安装上了 `Sileo`, cydia 的替代品。
后来的折腾中，发现使用 `m***2` 这个漏洞，可以非常顺滑地完成越狱，不会遇到重启。

完成越狱后，非常兴奋地点开 `Sileo`，但是却出现了让我耗费许多时间才得以解决的问题，`Sileo` 无法更新源列表，已更新就会报404的错，这样一来就几乎无法安装任何插件。
Google了一番也没看见靠谱的解决方法，看了好多无非都是让你重新越狱，或者让你打开 `Sileo` 的网络权限，可是这个时候的 `Sileo` 根本不会出现在网络权限app列表中。继续Google，终于找到了解决方案：

- 使用爱思助手，下载 `乐网` 到手机上
- 打开 `乐网` 使用全局模式
- 打开 `Sileo` 就可以刷新源列表了！
- 后来就可以在网络权限里找到 `Sileo` 了！

OK，既然 `Sileo` 可以正常联网了，已经迫不及待地想去安装插件了，但是又遇到了另一个棘手的问题。
