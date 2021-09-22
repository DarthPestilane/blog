---
title: git commit message standard
date: 2021-09-22 15:41:33
categories:
- 笔记
tags:
- git
---

回首这些年工作和业余时间的 git 使用，发现在提交内容时，写的 commit message 其实并没有做到统一和规范化。
于是抽空去 Google 了一番，发现有不少的开源项目在使用一种语义化的提交。
这种语义化的提交能够做到足够简短且开门见山。
看过之后确实也是受益匪浅，故在此记录。

https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716 。
这是一个拥有 2k+ star 的 gist，里面陈述着语义化提交的基本范式。
下面是我个人对这套规范的理解。

## 语义化的提交

来看看这个提交信息的小小改动，能对你的程序带来多少益处吧。

格式: `<type>(<scope>): <subject>`，其中 `<scope>` 是非必要的。

```sh
git commit -m "feat: add hat wobble"
               ^--^  ^------------^
               |     |
               |     +-> 总结内容(subject)，注意是用现在时态
               |
               +-------> 类型(type): chore, docs, feat, fix, refactor, style, test
```

### 不同类型(type)的语义

| Type       | 语义                                                    |
| ---------- | ------------------------------------------------------- |
| `feat`     | 针对用户侧的新特性。是对外的而非对内的                  |
| `fix`      | 针对用户侧的 bug 修复。是对外的而非对内的               |
| `docs`     | 仅文档内容的变更                                        |
| `style`    | 仅格式化相关，比如行尾的分号(;)，空格等。不影响线上使用 |
| `refactor` | 重构功能代码，如重命名变量，抽象方法等                  |
| `test`     | 添加或重构单元测试。不影响线上使用                      |
| `chore`    | 更新 CI/CD 流程、任务或脚本。不影响线上使用             |
