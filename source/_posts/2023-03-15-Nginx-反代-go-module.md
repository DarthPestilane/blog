---
title: Nginx 反代 go module
date: 2023-03-15 18:38:44
categories:
- 笔记
tags:
- nginx
- golang
---

在特定情况下，用 nginx 反代 git 仓库，且避免出现 `go get meta tag did not match import path` 的报错。

配置如下:

```sh
location / {
    if ($query_string ~ "go-get=1") {
        set $condition goget;
    }
    if ($uri ~ ^/([a-zA-Z0-9_\-\.]+)/([a-zA-Z0-9_\-\.]+).*$) {
        set $condition "${condition}path";
    }
    if ($condition = gogetpath) {
        return 200 '
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="go-import" content="$host/$1/$2 git http://$host/$1/$2.git">
            <meta name="go-source" content="$host/$1/$2 _ http://$host/$1/$2/src/mster{/dir} http://$host/$1/$2/src/master{/dir}/file#L{line}">
        </head>
        <body>
        $uri
        </body>
        </html>
        ';
    }

    proxy_pass http://原本的git仓库;
}
```

后续 go get 时，可能出现 `terminal prompts disabled` 的报错，使用 `GIT_TERMINAL_PROMPT=1 go get` 方可化解。
