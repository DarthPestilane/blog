---
title: 'Go Blog 翻译: Fuzzing is Beta Ready'
date: 2021-09-15 14:07:06
categories:
- [翻译]
- [笔记]
tags:
- golang
---

# Fuzzing is Beta Ready

> 原文地址 : https://blog.golang.org/fuzz-beta
>
> 作者     : Katie Hockman and Jay Conrod
>
> 时间     : 3 June 2021

我们兴奋地宣布: 原生 `fuzzing` 已经可供beta测试了，就在 [dev.fuzz](https://github.com/golang/go/tree/dev.fuzz) 中的 development 分支里！

`Fuzzing` 是自动化测试的一种，通过持续操控程序的输入来找出问题，比如说 panic 或 bug。
这些半随机的变换数据能够覆盖到已有单元测试所遗漏的地方，并且揭露出一些不易察觉的边界 bug。
正因为 `fuzzing` 可以抵达这些边界情况，fuzz 测试对于查找安全漏洞和弱点是尤为重要的。

详见 [golang.org/s/draft-fuzzing-design](https://golang.org/s/draft-fuzzing-design) 。

## Getting started

你可通过运行下面命令来上手

```sh
$ go get golang.org/dl/gotip
$ gotip download dev.fuzz
```

该操作从 dev.fuzz 的 development 分支构建 Go toolchain，将来一旦代码合并到了 master 分支就不用这样了。
运行之后，`gotip` 可以看做 go 命令的绿色替代 (drop-in replacement)。
你现在可以这样运行命令

```sh
$ gotip test -fuzz=FuzzFoo
```

因为在 dev.fuzz 分支中会不断地开发和bug修复，所以你应当有规律地执行 `gotip download dev.fuzz`  来应用最新的代码。

为兼容已发行的 Go 版本，在提交含有 `fuzz target` 的源文件到仓库时，要使用 `gofuzzbeta` build tag。
dev.fuzz 分支中，这个 tag 在 build-time 是默认开启的。
如果你对 tags 使用有疑问，参考 [the go command documentation about build tags](https://golang.org/cmd/go/#hdr-Build_constraints)。

```go
// +build gofuzzbeta
```

## Writing a fuzz target

`fuzz target` 必须是 `*_test.go` 文件中以 `FuzzXxx` 形式命名的 function。
该 function 必须传递一个 `*testing.F` 参数，很类似于传递一个 `*testing.T` 参数到 `TestXxx` function。

下面是个 fuzz target 的例子，用来测试 [net/url 包](https://pkg.go.dev/net/url#ParseQuery) 的行为。

```go
// +build gofuzzbeta

package fuzz

import (
    "net/url"
    "reflect"
    "testing"
)

func FuzzParseQuery(f *testing.F) {
    f.Add("x=1&y=2")
    f.Fuzz(func(t *testing.T, queryStr string) {
        query, err := url.ParseQuery(queryStr)
        if err != nil {
            t.Skip()
        }
        queryStr2 := query.Encode()
        query2, err := url.ParseQuery(queryStr2)
        if err != nil {
            t.Fatalf("ParseQuery failed to decode a valid encoded query %s: %v", queryStr2, err)
        }
        if !reflect.DeepEqual(query, query2) {
            t.Errorf("ParseQuery gave different query after being encoded\nbefore: %v\nafter: %v", query, query2)
        }
    })
}
```

你可以用 go doc 阅读更多 fuzzing 的 API

```sh
gotip doc testing
gotip doc testing.F
gotip doc testing.F.Add
gotip doc testing.F.Fuzz
```

## Expectations

由于这是 development 分支的 beta 发布，所以很可能遭遇 bug 和不完善的 feature。查看 ["fuzz" 相关的 issue tracker](https://github.com/golang/go/issues?q=is%3Aopen+is%3Aissue+label%3Afuzz) 来跟进已有的 bug 和 遗漏的 feature。

请注意，fuzzing 很可能会消耗大量内存，在运行过程中也许会影响你机器的性能。`go test -fuzz` 默认是根据 `$GOMAXPROCS` 来并行运行。
你可以设置 `go test` 的 `-parallel` flag 来降低并行数量。如果想获得更多信息，可执行 `gotip help testflag` go 命令来阅读 go test 命令文档。

也要注意，在运行中，fuzzing 引擎会写入那些扩大测试覆盖的值到 fuzz 缓存目录，位于 `$GOCACHE/fuzz`。
由于目前还没有文件数量或写入数据大小的限制，所以这可能会占据大量的存储空间 (好几个GB)。你可以通过运行 `gotip clean -fuzzcache` 来清理 fuzz 缓存。

## What’s next?

这个 feature 是不会出现在即将到来的 Go 版本中 (go1.17)，但计划会出现在未来的 Go 版本中。
我们希望这个还在开发中的原型 feature 会让 Go 开发者开始编写 `fuzz` target 并提供关于设计上有帮助的反馈，为合并到 master 做准备。

如遇任何问题或对 feature 有想法，请 [提 issue](https://github.com/golang/go/issues/new/?&labels=fuzz&title=%5Bdev%2Efuzz%5D&milestone=backlog)。

你可参与 Gophers Slack 的 [#fuzzing channel](https://gophers.slack.com/archives/CH5KV1AKE)，来对 feature 进行讨论或反馈。

Happy fuzzing!
