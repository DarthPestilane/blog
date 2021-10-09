---
title: 利用 Github Action 部署博客
date: 2021-10-09 14:05:20
categories:
- 笔记
tags:
- CI
- Github Actions
---


之前的博客是需要在我本地电脑上手动执行命令来部署的:

```sh
> make deploy
```

如今已经成功将这个部署的过程迁移到了 Github Actions。
整个 workflow 包括 npm 依赖的安装和缓存，将 Markdown 生成静态 html 文件，和部署到服务器。

配置如下:

```yml
name: deploy

on:
  push:
    branches:
      - 'master' # 只会在 master 分支发生 push 事件时，才触发

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: # 环境变量在 github 项目的设置页面里进行配置
      name: deploy # 这里需要手动进行授权，才会进行job
    steps:
      - name: Checkout Code
        uses: actions/checkout@v2

      # 指定 nodejs 版本
      - name: Setup Nodejs
        uses: actions/setup-node@v2
        with:
          node-version: '12'

      # 依赖缓存设置
      - name: Cache node dependency
        uses: actions/cache@v2
        with:
          path: ~/.npm # 缓存目录
          key: cache-node-${{ hashFiles('**/package-lock.json') }} # 缓存的key
          restore-keys: | # 恢复缓存时要去匹配的key
            cache-node-
            cache-

      # 安装 npm 依赖包
      - name: Install dependency
        run: npm install

      # 生成静态文件
      - name: Build to static
        run: make build

      # 部署到服务器，使用 rsync 来传递文件
      - name: Deploy to server
        uses: burnett01/rsync-deployments@5.1
        with:
          switches: -azvhP --delete
          path: ./public/
          remote_path: ${{ secrets.SSH_REMOTE_PATH }} # secrets 在 github 项目的设置页面里进行配置
          remote_user: ${{ secrets.SSH_USER }}
          remote_host: ${{ secrets.SSH_HOST }}
          remote_port: ${{ secrets.SSH_PORT }}
          remote_key: ${{ secrets.SSH_SECRET }}
```
