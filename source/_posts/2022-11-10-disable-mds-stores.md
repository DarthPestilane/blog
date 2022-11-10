---
title: disable mds_stores
date: 2022-11-10 15:04:04
categories:
- 笔记
tags:
- mac
---

记几个命令行，用来暂停/恢复 spotlight 搜索的索引进程:

---

As you know, the mds and mds_stores are Spotlight activities.

The reason why your Spotlight is so active could be a number of things; it could be you have an app or multiple apps constantly changing some folder contents.

First let's check whether Spotlight is the cause of the fans running so much. To test this, run the following in your terminal:

```sh
sudo mdutil -a -i off # 暂停索引建立
```

this turns off indexing of files, and should result in a clear slow down of the fans if `mds` and/or `mds_stores` are to blame.

To turn indexing back on, run:

```sh
sudo mdutil -a -i on # 恢复索引建立
```

After this you could run the complete re-indexing of your hard drive (be aware this could be an over night job),
it will delete your Spotlight data base forcing it to start over.

```sh
sudo rm -rf /System/Volumes/Data/.Spotlight-V100/*
```

The next and final step would be to add others to your (do not scan), privacy settings.

> 参考自: https://apple.stackexchange.com/questions/144474/mds-and-mds-stores-constantly-consuming-cpu

---

`mdutil` 用法:

```sh
$ mdutil --help
mdutil: unrecognized option `--help'
Usage: mdutil -pEsa -i (on|off) -d volume ...
       mdutil -t {volume-path | deviceid} fileid
	Utility to manage Spotlight indexes.
	-i (on|off)    Turn indexing on or off.
	-d             Disable Spotlight activity for volume (re-enable using -i on).
	-E             Erase and rebuild index.
	-s             Print indexing status.
	-a             Apply command to all stores on all volumes.
	-t             Resolve files from file id with an optional volume path or device id.
	-p             Publish metadata.
	-V vol         Apply command to all stores on the specified volume.
	-v             Display verbose information.
	-r plugins     Ask the server to reimport files for UTIs claimed by the listed plugin.
	-L volume-path List the directory contents of the Spotlight index on the specified volume.
	-P volume-path Dump the VolumeConfig.plist for the specified volume.
	-X volume-path Remove the Spotlight index directory on the specified volume.  Does not disable indexing.
	               Spotlight will reevaluate volume when it is unmounted and remounted, the
	               machine is rebooted, or an explicit index command such as 'mdutil -i' or 'mdutil -E' is
	               run for the volume.
NOTE: Run as owner for network homes, otherwise run as root.
```
