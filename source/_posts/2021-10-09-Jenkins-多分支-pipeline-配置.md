---
title: Jenkins 多分支 pipeline 配置
date: 2021-10-09 14:12:08
categories:
- 笔记
tags:
- CI
- Jenkins
---

最近恰巧有机会在一台 Centos 物理机上搭建 Jenkins，
也借此机会实践了从 git 提交自动触发 Jenkins build 的工作流，故在此记录，以作备忘。

## Jenkins 安装

docker 镜像在 https://hub.docker.com/r/jenkins/jenkins 。

docker-compose.yml 配置如下:

```yml
version: "3"

services:
  jenkins:
    image: jenkins/jenkins:lts-alpine-jdk11
    ports:
      - '8180:8080'
      - '50000:50000'
    volumes:
      - ./jenkins/:/var/jenkins_home # 持久化
    environment:
      TZ: "Asia/Shanghai"
```

需要注意宿主机的 `./jenkins/` 目录需要将用户和组更改为 `1000:1000`:

```sh
> sudo chown -R 1000:1000 ./jenkins
```

启动之后，进入 web 界面，需要输入 admin 的密码，这个密码可以在容器的日志中获得:

```sh
> docker-compose logs jenkins # 查看容器日志
```

```log
jenkins_1  | *************************************************************
jenkins_1  | *************************************************************
jenkins_1  | *************************************************************
jenkins_1  |
jenkins_1  | Jenkins initial setup is required. An admin user has been created and a password generated.
jenkins_1  | Please use the following password to proceed to installation:
jenkins_1  |
jenkins_1  | e05d003a9ec24c62bf607b75a9e47582
jenkins_1  |
jenkins_1  | This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
jenkins_1  |
jenkins_1  | *************************************************************
jenkins_1  | *************************************************************
jenkins_1  | *************************************************************
```

接下来建议直接选择安装社区推荐的插件，然后进行简单配置后，就可以正常登陆到 Jenkins 控制台了，
然后进行slave节点配置，顺便配置下域名反代。

<!-- more -->

## Gitea 安装

使用 `Gitea` 作为私有 git 代码仓库，docker 镜像在: https://hub.docker.com/r/gitea/gitea 。

docker-compose.yml 配置如下:

```yml
version: "3"

services:
  server:
    image: gitea/gitea:1.15.3
    environment:
      - USER_UID=1000
      - USER_GID=1000
    volumes:
      - ./gitea:/data # 持久化
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    ports:
      - "3000:3000" # http 端口
```

启动后，进入 web 界面进行安装，要注意 URL 里要填写容器内对应的地址。
如果配置了域名并进行反代，需要更改容器内的 `app.ini` 配置文件:

```ini
# 由于已经将文件挂载到了宿主机，所以直接修改宿主机文件即可。
# ./gitea/gitea/conf/app.ini
[server]
DOMAIN           = gitea.wrzsj.top # 修改成域名
SSH_DOMAIN       = gitea.wrzsj.top # 修改成域名
ROOT_URL         = https://gitea.wrzsj.top/ # 修改成域名，可以理解为外部 URL
LOCAL_ROOT_URL   = http://127.0.0.1:3000/ # 添加 LOCAL_ROOT_URL
```

修改之后，重启容器 `docker-compose restart server` 。

## CI/CD

Jenkins 和 Gitea 都准备好后，接下来就要开始配置 CI/CD 了。

### 工作流:

![git workflow](https://qiniu.wrzsj.top/git-flow)

git 分支操作:

- 从 `master` 分支切出 `dev` 分支作为长期迭代分支
- 从 `dev` 分支切出 `feat` 分支作为功能分支
- 在 `feat` 分支上提交代码，并及时 rebase `dev` 来保证提交不落后，完成开发后通过 `pull request` 的方式合并回 `dev` 分支
- 将 `dev` 分支合并回 `master` 分支
- 在 `master` 分支上打 tag，用于发布

对于线上的 bug 修复，应从 `master` 分支切出 `hotfix` 分支，
开发完成后合并到 `dev` 进行测试，测试通过后合并到 `master` ，然后打 tag 发布。

CI/CD 触发:

- 当 `master` 和 `dev` 分支发生 push 时，触发
- 当 `pull request` 创建或有后续 push 时，触发
- 每次触发都会执行 build, lint 和 test 任务
- 如果由 `dev` 分支 push 触发，则部署到 QA 环境
- 如果由 `master` 分支 push 触发，会进入打标签阶段，需要人工确认
- 打上标签后，会进入部署到生产环境阶段，也需要人工确认

### 配置

#### Jenkins 配置

安装 [gitea 插件](https://plugins.jenkins.io/gitea/)。

新建 `多分支流水线` 任务。

配置分支源:

- 需要设置 `Credentials` ，使用类型为 `Gitea Personal Access Token` 的凭证
- 添加 `Discover branches`，策略为 `Only branches that are not also filed as PRs`
- 添加 `Discover pull requests from origin`，策略为 `Merging the pull request with the current target branch revision`
- 添加 `Discover tags`
- 添加 `根据名称过滤（支持通配符)`, 包含 `master dev release-* PR-*`
  - `release-*` 用来过滤 tag。在打 tag 的时候，需要有 `release-` 前缀
  - `PR-*` 用来过滤 pull request
- 添加高级克隆行为，勾选 `Fetch tags` 和 `浅克隆`，并设置 `浅克隆深度` 为 1

保存配置。

#### Gitea 配置

在代码仓库里配置 `webhook`:

- 添加 `Gitea` 钩子
- 目标 URL 输入: `https://jenkins.wrzsj.top/gitea-webhook/post/`，注意要加上最后的斜杠 `/` ！！
- 触发条件勾选 `所有事件`

保存配置。

#### Jenkinsfile 配置

语法参考: https://www.jenkins.io/zh/doc/book/pipeline/syntax/ 。

由于是 pipeline 类型的任务，需要通过 Jenkinsfile 来触发。在代码中提交 Jenkinsfile 文件:

```groovy
pipeline {
    agent any
    options {
        disableConcurrentBuilds() // 禁用并发构建
        // checkoutToSubdirectory('service') // 将 git 检出到 ${WORKSPACE}/service 目录
        timestamps() // Console log 中打印时间戳
    }
    stages {
        stage('Build') {
            when { not { tag '*' } }
            steps {
                echo 'build'
                sh 'sleep 1'
            }
        }
        stage('Lint') {
            when { not { tag '*' } }
            steps {
                echo 'lint'
                sh 'sleep 1'
            }
        }
        stage('Test') {
            when { not { tag '*' } }
            steps {
                echo 'test'
                sh 'sleep 1'
            }
        }
        stage('Deploy QA') {
            when { branch 'dev' }
            steps {
                echo 'deploy QA'
            }
        }
        stage('Tag on master') {
            when {
                branch 'master'
                beforeInput true
            }
            input {
                // 人工确认
                message "Release a tag?"
                ok "Yes, do it."
                parameters {
                    string(name: 'milestone', defaultValue: 'regular', description: 'milestone as tag prefix')
                }
            }
            steps {
                sh '''
                export TAG=release-${milestone}-$(date +"%Y%m%d").${BUILD_ID}
                git tag ${TAG}
                git push origin ${TAG}
                '''
            }
        }
        stage('Deploy Prod') {
            when {
                tag '*'
                beforeInput true
            }
            input {
                // 人工确认
                message "Should we continue?"
                ok "Yes, do it."
            }
            steps {
                echo 'deploy production'
            }
        }
    }
}
```

现在，按照 Git 工作流来提交合并代码，就能够触发 Jenkins 流水线了。

## 总结

这次实践中，在 Jenkins 的使用上采取 master-slave 方式来运行流水线，相比只有 master 节点的工作方式，更加合理，且方便扩展。
配合 Jenkinsfile 的使用，实现了持续集成，搭建了敏捷开发的基础。

不过对比 `GitHub Actions` 和 `Gitlab CI` 还是略显笨重和*复古*，配置文件的语法相比 `yaml` 也更加晦涩难懂，文档也略显粗糙。
尽管如此，大多数公司的 CI/CD 还是使用的是 Jenkins，所以是有必要学会的。
