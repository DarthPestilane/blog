---
title: Install Shadowsocks server on ubuntu
date: 2017-10-12 16:07:42
tags:
- docker
- shadowsocks
- ubuntu
categories:
- 笔记
---
这里有两种方式:

# Docker 方式

推荐一个docker镜像 [`mritd/shadowsocks`](https://hub.docker.com/r/mritd/shadowsocks/)

下面是`docker-compose.yml`

```yml
version: '3'

services:
  ssclient:
    image: mritd/shadowsocks:latest
    container_name: ssclient
    ports:
      - 1080:1080
    #
    # 用作client
    #
    # command: -m "ss-local" -s "-s 12.34.56.78 -p 8388 -m rc4-md5 -k password -b 0.0.0.0 -l 1080 --fast-open"
    #
    # 用作server
    #
    command: -m "ss-server" -s "-s 0.0.0.0 -p 8388 -m aes-256-cfb -k password --fast-open"
```

<!-- more -->

# 传统安装方式

## Installation

```sh
$ sudo apt-get update
$ sudo apt-get upgrade -y
$ sudo apt-get install python-gevent python-pip python-m2crypto python-wheel python-setuptools
$ sudo pip install shadowsocks
```

## Config and Start the service

config file `ss.json`:

```javascript
{
    "server": "0.0.0.0",
    "server_port": 8388,
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "password": "my_password",
    "timeout": 300,
    "method": "rc4-md5",
    "fast_open": true
}
```

start:

```sh
$ sudo ssserver -c ss.json -d start # run as daemon
```
