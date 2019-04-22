---
title: Golang中slice的一些helper
date: 2018-02-28 14:20:13
tags:
- golang
categories:
- 笔记
---
最近在用golang写业务代码，没有用框架，所以自己写的一些 `helper` 来辅助开发。这里分享下 `slice` 相关的 `helper` 。

## SliceDiff

### 目的

用于比较两个相同类型的slice，并找到不同的部分

### 设计

最初设计是只接收2个参数，然后返回一个[]interface{}，但是这样的返回意味着面临断言的可能，所有决定用反射优化下。
函数将接收3个参数，都为slice。第一个是原本的slice，第二个参数是用于和第一个slice做比较，比价之后的结果将会存入第三个参数中，所以第三个参数必须是个指针slice。
同时也兼容了空slice的情况，如果第一个参数是个空的slice，则直接return，跳过后续计算。
如果参数存在问题，比如类型不统一、第三个参数不是指针，会直接panic 😱 。
没有返回值。

<!-- more -->

### 代码实现

```go
func SliceDiff(main, compared, result interface{}) {
    mainValue := reflect.Indirect(reflect.ValueOf(main))
    comparedValue := reflect.Indirect(reflect.ValueOf(compared))
    if mainValue.Type() != comparedValue.Type() {
        panic(errors.New("main's and compared's types should be the same"))
    }
    resultValue := reflect.ValueOf(result)
    if resultValue.Kind() != reflect.Ptr {
        panic(errors.New("result should be a slice ptr"))
    }
    resultSlice := resultValue.Elem()
    if resultSlice.Kind() != reflect.Slice {
        panic(errors.New("result should be a slice ptr"))
    }
    mainLen := mainValue.Len()
    if mainLen == 0 {
        return
    }
    comparedLen := comparedValue.Len()
    nSlice := reflect.New(resultSlice.Type()).Elem()
    for i := 0; i < mainLen; i++ {
        var found bool
        for j := 0; j < comparedLen; j++ {
            if reflect.DeepEqual(mainValue.Index(i).Interface(), comparedValue.Index(j).Interface()) {
                found = true
                break
            }
        }
        if !found {
            nSlice = reflect.Append(nSlice, mainValue.Index(i))
        }
    }
    resultSlice.Set(nSlice)
}
```

### 示例

```go
var diff []int
SliceDiff([]int{1, 2, 3, 4}, []int{1, 2}, &diff)
fmt.Println(diff) // []int{3, 4}
```

---

## SliceUnique

### 目的

对slice中的元素去重

### 设计

函数只需接收一个参数，即要进行去重的slice指针。
然后由函数实现去重并覆盖原slice。
如果参数的类型不正确，会直接panic 😱。

### 代码实现

```go
func SliceUnset(slicePtr interface{}, index int) {
    value := reflect.ValueOf(slicePtr)
    if value.Kind() != reflect.Ptr {
        panic(errors.New("should be a slice ptr"))
    }
    slice := value.Elem()
    nSlice := reflect.New(slice.Type()).Elem()
    if slice.Kind() != reflect.Slice {
        panic(errors.New("should be a slice ptr"))
    }
    l := slice.Len()
    if l == 0 {
        return
    }
    for i := 0; i < l; i++ {
        if i != index {
            nSlice = reflect.Append(nSlice, slice.Index(i))
        }
    }
    slice.Set(nSlice)
}
```

### 示例

```go
var s := []int{1, 2, 3, 1, 3, 2}
SliceUnique(&s)
fmt.Println(s) // []int{1, 2, 3}
```

---

to be continued...
