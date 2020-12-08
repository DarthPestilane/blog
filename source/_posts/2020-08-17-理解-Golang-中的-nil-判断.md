---
title: 理解 Golang 中的 nil 判断
date: 2020-08-17 12:12:13
categories:
- 笔记
tags:
- golang
---

## nil 的含义

从单词的角度来看， `nil` 有多个意思，但通常都表示 `零`，在 Golang 中，有些类型的零值是 nil 而有的不是。

```go
// 不同类型的零值
var n int               // 0
var s string            // ""
var b bool              // false
var p *Pointer          // nil
var slice []byte        // nil
var m map[string]string // nil
var fn func() error     // nil
var ch chan int         // nil
var i interface{}       // nil
```

<!-- more -->

## Pointer 的零值

一个 `pointer` (指针) 变量，表示该变量指向了某一个内存地址，当我们只是声明了一个指针变量，而不指明其指向的内存地址，
这个变量就会是 `nil`:

```go
type Person struct {}
var ptr *Person // 声明了一个指针变量，但是没有说明指针地址
assertTrue(ptr == nil)
```

## Slice 的零值

`slice` 是数组的切片，其内部有三个元素构成:

```go
// 伪代码
type slice struct {
    Ptr *pointer // 指向底层数组的指针
    Len int      // 长度
    Cap int      // 容量
}
```

当我们只是声明了一个 slice 后，并没有告诉 slice 要指向那个底层数组，所以此时 Ptr 为 `nil`:

```go
var s []byte         // s 中的 Ptr 为 nil
assertTrue(s == nil) // 此时，变量 s == nil 为 true

var ss = []int{1, 2, 3} // ss 是知道自己的底层数组的
assertTrue(ss != nil)   // 所以不为 nil
```

## Map, Channel, Function 的零值

这三种类型的零值为 `nil` ，是因为当我们声明了变量后，并没有说明该变量对应的 implemention (实现) 是什么。

## Interface 的零值

首先思考一个例子，**实际开发中不要这样做**:

```go
type MyError struct{} // MyError 实现 error 接口
func (*MyError) Error() string {
    return "here is my error"
}

func NewError() error {
    var myErr *MyError
    return myErr // 返回时把 myErr 转为 error 接口
}

func main() {
    err := NewError()
    if err == nil {
        // cool!
    } else {
        // whoops..
    }
}
```

我们调用 `NewError()` 后得到的 err 是 `nil` 吗？运行后发现 `err != nil`。要解释这个现象需要从 interface 的结构说起。

`interface` 内部有两个元素 ———— `type` (类型) 和 `value` (值):

```go
// 伪代码
type interface struct {
    Type xx  // 类型
    Value xx // 值
}
```

在上述 `NewError()` 方法的定义里，我们声明了一个空指针变量 `myErr` ，这个变量为 `nil` ，
然后返回的时候将 `myErr` 转成了 `error` 接口。

调用后得到的 `err` 变量已经是一个 `interface` 了，
而此时这个 interface 的值为 nil ，但类型是 `*MyError` ，所以 `err == nil` 会是 false。

再回过头来看看:

```go
var i interface{}    // value 和 type 都为空
assertTrue(i == nil) // 所以整个 interface == nil

var p *Pointer        // p == nil
var t interface{} = p // 但是t 的值为nil，但类型为 *Pointer
assertTrue(t != nil)  // 所以 t != nil
```
