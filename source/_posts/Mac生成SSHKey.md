---
title: Mac生成SSHKey
date: 2015-7-18 12:16:23
categories:
- 技术
tags:
- Mac
---

## 关于 SSH key

使用 SSH 协议，可以连接和验证远程服务器和服务。大家都知道 GitHub 克隆代码可以通过两种方式，SSH key 或者 HTTPS。使用 SSH key 时，您可以直接通过 SSH key 连接到 GitHub，而无需在每次访问时提供用户名或密码。

<!--more-->

## 步骤

    1. 检查 SSH key 是否存在
    2. 生成新的 SSH key
    3. 将 SSH key 添加到 GitHub 中
    

### 检查

在生成 SSH key 之前，您可以检查是否有任何现有的 SSH key。输入下面的命令，如果有文件 id_rsa.pub 或 id_dsa.pub，则直接进入步骤3将 SSH key 添加到 GitHub 中，否则进入第二步生成 SSH key

```
$ ls -al ~/.ssh
```

### 生成

如果检查后还没有 SSH key，则要生成一个新的 SSH key 并将其添加到 SSH 代理中

1.生成新的 SSH key

```
$ ssh-keygen -t rsa -C "your_email@example.com"
```

执行上面的命令后会先让你选择路径，可以直接回车即使用默认路径，然后会提示输入密码，也可以直接回车不设置密码。

2.添加到 SSH 代理中

```
$ ssh-add ~/.ssh/id_rsa
```

### 获取

要配置 GitHub 帐户以使用新的（或现有的）SSH key，需要将其添加到你的 GitHub 帐户中。

1.复制 SSH key 到剪贴板

```
$ pbcopy < ~/.ssh/id_rsa.pub
```

2.添加到 GitHub

进入 GitHub 个人设置中，把复制的 SSH key 添加的个人 SSH key 管理设置中。


