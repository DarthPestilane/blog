---
title: Docker 部署 JIRA
date: 2021-09-24 15:27:04
categories:
- 笔记
tags:
- docker
---

近日有机会在 Linux 环境中从零开始使用 docker 部署 [JIRA](https://www.atlassian.com/zh/software/jira), 在此记录下部署过程中遇到的问题及解决.

## 镜像选择

在 docker 的镜像仓库中搜索 'jira', 会看到好几个相关的镜像: atlassian/jira-software, atlassian/jira-core 等.
这里应当选择 [`atlassian/jira-software`](https://hub.docker.com/r/atlassian/jira-software).

## 初次启动

根据 dockerhub 中的描述, 编排出下面的 `docker-compose.yml` 配置:

```yml
version: '3'

services:
  jira:
    image: atlassian/jira-software
    environment:
      TZ: Asia/Shanghai
    ports:
      - "18081:8080"
    volumes:
      - ./jira-data:/var/atlassian/application-data/jira # 应用数据持久化
```

启动之后, 进入web界面, 选择手动配置, 然后开始配置 JIRA.

在配置数据库时, 此时还只能选在内置数据库, 不能选择 MySQL 或者 PostgreSQL,
因为 atlassian/jira-software 镜像中并没有包含连接 MySQL 或 PostgreSQL 的驱动 jar 包.
接下来就需要去下载对应的 jar 包, 并将其放入容器中特定的目录下, 来完成 MySQL 或 PostgreSQL 的配置.

<!-- more -->

## 载入驱动, 配置 PostgreSQL 数据库

更新 docker-compose.yml 来添加 PostgreSQL 容器, 并与 jira-software 关联上:

```yml
version: '3'

services:
  jira:
    image: atlassian/jira-software
    environment:
      TZ: Asia/Shanghai
    depends_on:
      - postgres # 关联上 postgres
    ports:
      - "18081:8080"
    volumes:
      - ./jira-data:/var/atlassian/application-data/jira # 应用数据持久化

  # 添加 postgres 容器
  postgres:
    image: postgres:11-alpine
    ports:
      - "15432:5432"
    environment:
      TZ: Asia/Shanghai
      POSTGRES_DB: jira
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_HOST_AUTH_METHOD: trust
    volumes:
      - ./pgdata:/var/lib/postgresql/data # 数据库持久化

# 如果是 Mac 环境, 最好是使用单独的 volume 来做数据持久化
#
# volumes:
#  jiradata:
#    external: false
#  pgdata:
#    external: false
```

至此, 还需要载入 PostgreSQL 驱动, 才能完成数据库的配置.

访问 [startup-check-jira-database-driver-missing](https://confluence.atlassian.com/jirakb/startup-check-jira-database-driver-missing-873872169.html) 可得知对应数据库驱动的下载地址.
下载得到的 jar 包为 `postgresql-42.2.23.jar`,
现在需要将其放入 jira-software 容器中的 `/opt/atlassian/jira/lib` 目录下, 使用 `docker cp` 命令即可完成.

重启容器后, PostgreSQL 驱动已完成载入, 可以在 web 界面完成数据库配置了.

## 激(po)活(jie) JIRA

当进行到激活步骤时, 需要提供 license-key 才可激活 JIRA, 然而我并没有购买 license-key, 所以需要一些特殊手段来激活.

由于 jira-software 的版本是 8.x, 需要 [atlassian-agent](https://gitee.com/pengzhile/atlassian-agent) 来提供 license-key 用来激活.
下载并解压后得到 `atlassian-agent.jar`, 还是需要将其放入 jira-software 容器中的 `/var/local/agent` 目录下(目录可以自己定), 记住这个目录，后面会用到.
然后进入容器内的 `opt/atlassian/jira/bin` 目录, 修改 `setenv.sh` 文件:

```sh
# 找到 export JAVA_OPTS

export JAVA_OPTS

# 仅添加下面这一行. /var/local/agent 为 atlassian-agent.jar 所在目录
export JAVA_OPTS="-javaagent:/var/local/agent/atlassian-agent.jar ${JAVA_OPTS}"
```

重启容器, 可能需要重新配置刚才已经配置过的条目, 直到来到激活步骤. 进入 jira-software 容器的 `/var/local/agent` 目录, 也就是 `atlassian-agent.jar` 所在目录, 执行:

```sh
$ java -jar atlassian-agent.jar -p jira -m aaa@local.com -n my_name -o https://local.com -s '这里填写 web 页面上的 server id, 或者留空'

# java -jar atlassian-agent.jar -h 可以打印出帮助信息
```

将 license-key 填入, 方可完成激活.

===

接下来完成剩下的一些配置, JIRA 就按照完毕了.

