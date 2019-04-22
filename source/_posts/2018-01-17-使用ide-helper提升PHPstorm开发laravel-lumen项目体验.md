---
title: 使用ide-helper提升PHPstorm开发laravel/lumen项目体验
date: 2018-01-17 15:28:32
tags:
- php
- shell
- laravel/lumen
categories:
- 笔记
---
目前 `phpstorm` 应该是公认的开发 `PHP` 最好的 `IDE` 了，但在开发 `laravel/lumen` 项目时，由于框架实现方式问题，其代码提示功能被迫减弱。
为了更好的开发体验，在GitHub上有个 [barryvdh/laravel-ide-helper](https://github.com/barryvdh/laravel-ide-helper) 项目，目的就是弥补部分被削弱的代码提示功能。

使用方法是用 `composer` 安装完成后，注册 `service`，用 `artisan` 命令生产 `ide-helper` 文件。具体参考GitHub上的文档。

其实我们最终只是需要生成得到的 `ide-helper` 文件，就可以达到增强代码提示功能的效果，于是用 `shell` 写了个简单的脚本来生成 `lumen` 项目的 `ide-helper` 。

其思路是：

- 首先备份 `composer.json` 和 `composer.lock` 文件
- 使用 `composer` 安装 `ide-helper`
- 然后在 `bootstrap/app.php` 文件中追加注册 `service` 的代码（由于 macOS 下 `sed` 命令不太正常，所以用到了 `gsed`，通过 `brew install gnu-sed` 安装）
- 接着执行 `./artisan ide-helper:generate` 和 `./artisan ide-helper:meta` 来生成 `ide-helper` 文件
- 最后还原 `bootstrap/app.php`、 `composer.json` 和 `composer.lock` 文件以及对应的 `composer` 依赖

```shell
# lumen ide helper generator
lumen-helper-gen() {
    # backup
    echo 'backup composer.*'
    cp composer.json composer.json.bak
    cp composer.lock composer.lock.bak

    # generate
    echo 'install ide-helper via composer'
    composer require --quiet --dev barryvdh/laravel-ide-helper
    echo 'edit bootstrap/app.php'
    l=`sed -n '/$app->register/=' bootstrap/app.php | tail -1`
    gsed -i.bak "$l a \$app->register(\\\Barryvdh\\\LaravelIdeHelper\\\IdeHelperServiceProvider::class);" bootstrap/app.php
    unset l
    echo 'generate ide-helper files'
    ./artisan ide-helper:generate
    ./artisan ide-helper:meta

    # restore file
    echo 'restore bootstrap/app.php'
    mv bootstrap/app.php.bak bootstrap/app.php
    echo 'restore composer dep'
    composer remove --dev --no-update --no-progress barryvdh/laravel-ide-helper
    mv composer.json.bak composer.json
    mv composer.lock.bak composer.lock
}
```
