---
title: Homebrew 安装 disabled formula
date: 2021-12-07 16:25:50
categories:
- 笔记
tags:
- mac
---

## 安装还在仓库里的 formula

如果需要用 Homebrew 安装已经被 disable 掉的 formula，例如需要安装 v1.12 版本的 golang, 使用 `brew install go@1.12` 是无法安装的，需要修改对应的 formula 脚本:

```sh
> brew edit go@1.12
```

该操作会在默认的编辑器中打开位于 `/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula` 目录下的
<code>go&#64;1.12.rb</code> 脚本文件。

编辑脚本文件，找到 `disable` 方法的调用，并注释掉，例如:

```ruby
class GoAT112 < Formula
  desc "Go programming environment (1.12)"
  homepage "https://golang.org"
  url "https://dl.google.com/go/go1.12.17.src.tar.gz"
  mirror "https://fossies.org/linux/misc/go1.12.17.src.tar.gz"
  sha256 "de878218c43aa3c3bad54c1c52d95e3b0e5d336e1285c647383e775541a28b25"
  license "BSD-3-Clause"

  # ......

  keg_only :versioned_formula

  disable! date: "2021-02-16", because: :unsupported # **就是这一行** TODO: 注释掉

  depends_on arch: :x86_64

  # ......
```

之后，再次使用 `brew install go@1.12` ，虽然会有 warning 但最终还是可以顺利安装 v1.12 版本的 golang 。

## 安装已给移除仓库的 formula

通过 github 仓库搜索 <code>go&#64;1.12.rb</code>, 在 commits 中找到对应的提交。将 rb 文件保存到本地, 例如: <code>go&#64;1.12.rb</code> 。
然后执行:

```sh
> HOMEBREW_NO_INSTALL_FROM_API=1 brew install ./go@1.12.rb
```
