---
title: 'Go Blog 翻译: Context and Structs'
date: 2021-04-21 17:10:54
categories:
- 翻译
- 笔记
tags:
- golang
---

## Context and Structs

原文地址: https://blog.golang.org/context-and-structs

作者: Jean de Klerk, Matt T. Proud

时间: 24 February 2021

### Introduction

在许多尤其是现代的 Go API 中, function 或 method 的第一个参数常常是 [context.Context](https://golang.org/pkg/context/). Context 为传输提供了 deadline, 为调用方提供了 cancellation, 也为其他进程间跨 API 请求提供了传值手段. 它常常被间接或直接使用了远程服务的库所使用, 例如数据库, API 等.

[Context 文档](https://golang.org/pkg/context/) 所述:

> Context 不应存储在 struct 内部, 而应传给需要它的 function.

这篇文章就是针对上述建议的详述, 通过举例说明的方式来阐述为什么要传递 Context 而不是存储在另一个 type 里. 本文也强调了一种边缘情况: 将 Context 存储在 struct 中也是合理的. 以及如何安全实现.

### Prefer contexts passed as arguments

要理解这个建议: **不要把 Context 存储在 struct 中**. 我们先看看建议的方式下写的代码:

```go
type Worker struct { /* … */ }

type Work struct { /* … */ }

func New() *Worker {
  return &Worker{}
}

func (w *Worker) Fetch(ctx context.Context) (*Work, error) {
  _ = ctx // A per-call ctx is used for cancellation, deadlines, and metadata.
}

func (w *Worker) Process(ctx context.Context, work *Work) error {
  _ = ctx // A per-call ctx is used for cancellation, deadlines, and metadata.
}
```

`(*Worker).Fetch` 和 `(*Worker).Process` 两个方法都直接接受 context 参数. 在 `pass-as-argument` 的设计下, 用户可以对每次调用设置 `deadlines`, `cancellation`, 和 `metadata`. 而且, `context.Context` 传到每个方法的方式是很清晰的, 不用去担心 `context.Context` 会不会在其他方法中用到. 这是因为 `context` 被划定为了操作所需的最小粒度, 这极大地增强了包中 context 的实用性和清晰度.

### Storing context in structs leads to confusion

我们再来用 *不推荐* 的 `context-in-struct` 方式来审视下代码. 这问题在于, 当你把 context 存储在 struct 里, 调用方就无法看清楚 context 的生命周期, 情况得不可预测:

```go
type Worker struct {
  ctx context.Context
}

func New(ctx context.Context) *Worker {
  return &Worker{ctx: ctx}
}

func (w *Worker) Fetch() (*Work, error) {
  _ = w.ctx // A shared w.ctx is used for cancellation, deadlines, and metadata.
}

func (w *Worker) Process(work *Work) error {
  _ = w.ctx // A shared w.ctx is used for cancellation, deadlines, and metadata.
}
```

`(*Worker).Fetch` 和 `(*Worker).Process` 方法都使用了存储在 Worker 里的 context. 这阻碍了 Fetch 和 Process 调用方 (可能他们拥有各自不同的 context) 在每次调用时的基本操作: 指定 deadline, 请求 cancellation 以及附加 metadata. 例如: 用户无法仅为 `(*Worker).Fetch` 提供 deadline, 也无法仅为 `(*Worker).Process` 提供 cancel. 因为context是共享的, 所以调用方的生命周期是虚实夹杂的, 并且当 Worker 被创建时, context 就会被作用于整个生命周期.

相比 `pass-as-argument` 方式, 用户会对这个 API 感到很疑惑, 心想:

- New 方法会被传入 context.Context, 那这个构造方法在执行时会需要 cancelation 或 deadlines 吗?
- 在 New 方法中传入的 context.Context 会被 `(*Worker).Fetch` 和 `(*Worker).Process` 方法使用吗? 两个方法都不会用到? 还是说有方法会用到?

这个 API 也需要有大量的文档来明确地告诉用户, context.Context 具体是用来干什么的. 用户也不得不读源码而不能依赖 API 所传达的结构.

而且, 这可能是很危险的, 将这样的设计方式运用在生产级别的服务器上. 因为如果不是每个请求都有一个 context, 就不能充分地"尊重" cancellation. 不能对每次调用设置 deadline, 你的进程可能会堆积和耗尽其资源 (比如 内存)!

### Exception to the rule: preserving backwards compatibility

当 Go 1.7 [带着 context.Context](https://golang.org/doc/go1.7) 发布后, 大量的 API 需要以向后兼容的方式添加 context 支持. 例如: [net/http 中 Client 方法](https://golang.org/pkg/net/http/), 像 Get 和 Do, 就是 context 极佳的候选者. 通过这些方法所发出的外部请求都会受益于由 `context.Context` 带来的 deadline, cancellation, 和 metadata 的支持.

有两种方式来添加向后兼容的 `context.Context` 支持: 一种是将 context 定义在 struct 里 (context-in-struct), 另一种, 正如我们所见, 是复制函数来接收 context.Context 参数, 并将 Context 作为新函数的名后缀. 复制函数的方式相比 context-in-struct 更好, 更深入的讨论详见 [Keeping your modules compatible](https://blog.golang.org/module-compatibility). 然而, 在某些情况下这是不现实的: 比如你的 API 暴露了大量的方法, 将他们全都复制一遍也许是不可行的.

`net/http` 包选择 `context-in-struct` 的方式, 它为我们提供了一个有用的案例来学习. 我们来看看 `net/http` 的 Do 方法. 在引入 context.Context 之前, Do 方法是这样定义的:

```go
func (c *Client) Do(req *Request) (*Response, error)
```

在 Go 1.7 之后, 如果不是为了保证向后兼容, Do 方法可能会是这样:

```go
func (c *Client) Do(ctx context.Context, req *Request) (*Response, error)
```

但是! 确保向后兼容及秉持 [Go 1 promise of compatibility](https://golang.org/doc/go1compat), 对于标准库来说, 是至关重要的. 因此, 维护人员选择了将 context.Context 添加到 `http.Request` struct 中, 来实现 context.Context 的支持, 而不破坏兼容性:

```go
type Request struct {
  ctx context.Context

  // ...
}

func NewRequestWithContext(ctx context.Context, method, url string, body io.Reader) (*Request, error) {
  // Simplified for brevity of this article.
  return &Request{
    ctx: ctx,
    // ...
  }
}

func (c *Client) Do(req *Request) (*Response, error)
```

由此看来, 在改造 API 支持 context 时, 将 context.Context 添加到 struct 里也可以是合理的. 然而, 要记住首选仍然是复制方法, 它既可以保证 context.Context 的兼容性, 也不会牺牲通用性和可读性. 例如:

```go
func (c *Client) Call() error {
  return c.CallContext(context.Background())
}

func (c *Client) CallContext(ctx context.Context) error {
  // ...
}
```

### Conclusion

Context 让跨库 / 垮 API 传播重要信息到调用栈变得容易.但也须要做到贯彻到底和条理清晰, 来保证可读性, 方便debug, 和有效性.

当 Context 用作第一个参数, 而不是存储在 struct 时, 用户可以利用其扩展性构建强大的 cancelation, deadline, 和 metadata 调用栈. 同时, 最棒的是, 当 Context 用作第一个参数传递时, 其作用域是能被充分理解的, 这让整个调用栈都具有可读性和易调试性的.

当在设计一个包含 context 的 API 时, 记住这个建议:

> pass context.Context in as an argument; don't store it in structs.
