---
title: Golang reflect 实践
date: 2017-12-27 09:51:00
tags:
- golang
categories:
- 笔记
---
由于最近在用 `golang` 造一个 `query builder + orm` 轮子，过程中很多地方涉及到 `reflect` 包的使用，故写此文章以记录开发中的点滴。

建议先去看下 `golang` 的官方 blog [laws-of-reflection](https://blog.golang.org/laws-of-reflection) 以及 [package文档](https://golang.org/pkg/reflect)

# 场景示例

## 将 `interface{}` 转为 `[]interface{}`

有时候会遇到这样的情况，我们定义了一个函数，函数会接收一个 `interface{}` 类型的参数，并且需要在函数体内将这个参数转为一个 `slice` 即 `[]interface{}`：

```go
package main

func interfaceSliced(val interface{}) {
    // TODO: convert `val` into `[]interface{}`
}

func main() {
    interfaceSliced([]int{1, 2, 3}) // 调用
}
```

<!-- more -->

这时我们会需要用到 `reflect` 这个包：

```go
package main

import (
    "reflect"
    "fmt"
)

func interfaceSliced(val interface{}) []interface{} {
    refObj := reflect.ValueOf(val) // 这里会得到一个reflect.Value对象
    l := refObj.Len()
    v := make([]interface{}, l)
    for i := 0; i < l; i++ {
        v[i] = refObj.Index(i).Interface()
    }
    return v
}

func main() {
    s := interfaceSliced([]int{1, 2, 3})
    fmt.Printf(`%T %v`, s, s)
}
```

当然，最好再加一些类型判断:

```go
package main

import (
    "reflect"
    "errors"
    "fmt"
)

func interfaceSliced(val interface{}) ([]interface{}, error) {
    refObj := reflect.ValueOf(val) // 这里会得到一个reflect.Value对象
    if refObj.Kind() != reflect.Slice {
        return nil, errors.New("val should be a slice")
    }
    l := refObj.Len()
    v := make([]interface{}, l)
    for i := 0; i < l; i++ {
        v[i] = refObj.Index(i).Interface()
    }
    return v, nil
}

func main() {
    s, err := interfaceSliced([]int{1, 2, 3})
    fmt.Printf(`%T %v | %v`, s, s, err)
}
```

## 判断 `struct` 中是否拥有某方法，如果有，则调用并获取其返回值

这个需求的出现是由于想要实现Model的一些特性，比如我们定义了一个名叫 `User` 的 `struct` 来作为 `Model` ，正常来说该 `Model` 对应的表名称为 `users` 。
但是如果实际情况中，我们的表名称并不一定是完全按照 `CamelCaseSingular to snake_case_plural` 来映射了。
这时，一般的做法是在 `Model` 中定义一个方法或者属性来显示申明对应的表名称：

```go
package main

type User struct {
    ID   int
    Name string
}

func (User) TableName() string {
    return "employees"
}
```

上述代码中，我们定义了一个 `Model` 并且约定用 `TableName()` 方法来显示地申明了该 `Model` 对应的表名称。
我们在解析 Model 的时候就需要去判断是否存在 `TableName()` 方法，如果存在，则调用，从而获取表名称；如果不存在，则按照 `CamelCaseSingular to snake_case_plural` 的原则来得到表名称。
想要实现这个功能，则需要用到 `reflect` 包和其中的 [`MethodByName()方法`](https://golang.org/pkg/reflect/#Type)

文档：
```go
type Type interface {
    // MethodByName returns the method with that name in the type's
    // method set and a boolean indicating if the method was found.
    //
    // For a non-interface type T or *T, the returned Method's Type and Func
    // fields describe a function whose first argument is the receiver.
    //
    // For an interface type, the returned Method's Type field gives the
    // method signature, without a receiver, and the Func field is nil.
    MethodByName(string) (Method, bool)

    // ...
```

代码实现：

```go
package main

import (
    "reflect"
)

func findOutTableName(struc interface{}) string {
    v := reflect.ValueOf(struc)
    typ := v.Type()
    var tbName string
    if _, ok := typ.MethodByName("TableName"); ok {
        // 如果存在，则调用
        tbName = v.MethodByName("TableName").Call(nil)[0].String()
    }
    if tbName == "" {
        // TODO: CamelCaseSingular to snake_case_plural
    }
    return tbName
}
```

两块代码合在一起：

```go
package main

import (
    "fmt"
    "reflect"
)

// User stands for User Model
type User struct {
    ID   int
    Name string
}

// TableName specifies the table name of User Model
func (User) TableName() string {
    return "employees"
}

func findOutTableName(struc interface{}) string {
    v := reflect.ValueOf(struc)
    typ := v.Type()
    var tbName string
    if _, ok := typ.MethodByName("TableName"); ok {
        tbName = v.MethodByName("TableName").Call(nil)[0].String()
    }
    if tbName == "" {
        // TODO: CamelCaseSinglar to snake_case_plural 这里就不做演示了
    }
    return tbName
}

func main() {
    user := User{}
    fmt.Println(findOutTableName(user)) // employees
}
```

---

To be continued...
