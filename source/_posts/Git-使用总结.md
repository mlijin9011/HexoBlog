---
title: Git 使用总结 (持续更新)
date: 2015-07-26 19:22:52
categories:
- 技术
tags:
- Git
---

作为一个开发人员，Git 在我们工作中不可或缺，但是很多人都并没有真正了解 Git 强大的功能，本文是做一个 Git 常用功能的积累。

<!--more-->

## 开始 Git

### Git 的简单介绍

#### 4个区

> 工作区 (Working Area)
> 暂存区 (Stage)
> 本地仓库 (Local Repository)
> 远程仓库 (Remote Repository)

工作区是从远端某个版本中提取出来的文件，放在磁盘上供你使用或修改；

暂存区保存了下次将提交的文件列表信息，有时候也被称作‘索引’；

Git 仓库是 Git 用来保存项目的元数据和对象数据库的地方。

#### 5种状态

以上4个区，进入每一个区成功之后会产生一个状态，再加上最初始的一个状态，一共是5种状态。以下我们把这5种状态分别命名为：

> 未修改(Origin)
> 已修改(Modified)
> 已暂存(Staged)
> 已提交(Committed)
> 已推送(Pushed)

未修改表示与远程仓库相同；

已修改表示修改了文件，但还没保存到数据库中； 

已暂存表示对一个已修改文件的当前版本做了标记，使之包含在下次提交中；

已提交表示数据已经安全的保存在本地数据库中；

已推送表示已经推送到远程仓库。

#### 基本 Git 工作流程

在工作目录中修改文件。

暂存文件，将文件的快照放入暂存区域。

提交更新，找到暂存区域的文件，将快照永久性存储到 Git 仓库目录。

### Git 常用命令

一些简单常用的大家都知道的命令就不记录了：clone, add, commit, pull, push 等

#### **修改commit**

大家可能都有过有时候不小心，commit 提交错的情况，可以这么解决：

1.如果还没 push 到远端 

```shell
$ git commit --amend
```

例：

```shell
# 编辑了 README.md 和 README_ZH.md
git add README.md
git commit

# 意识到你忘记添加 README_ZH.md 的更改
git add README_ZH.md
git commit --amend --no-edit
```

编辑器会弹出上一次提交的信息，加入 `--no-edit` 标记会修复提交但不修改提交信息。需要的话你也可以修改，不然的话就像往常一样保存并关闭文件。完整的提交会替换之前不完整的提交，看上去就像我们在同一个快照中提交了 README.md 和 README_ZH.md。

如果你的缓存区没有文件时，运行这个命令可以用来编辑上次提交的提交信息，而不会更改快照。

2.如果已经push到了远端

```shell
$ git rebase -i <base>
```

将当前分支 rebase 到 base，它会打开一个编辑器，你可为每个将要 rebase 的提交输入命令。这些命令决定了每个提交将会怎样被转移到新的基上去。你还可以对这些提交进行排序。

例：

```shell
# 新的功能分支
$ git checkout -b feature master
# 编辑文件
$ git commit -a -m "Start developing a featureA"
# 编辑更多文件
$ git commit -a -m "Fix something from the previous commit"

# 直接在 master 上添加文件
$ git checkout master
# 编辑文件
$ git commit -a -m "FeatureB"

# 开始交互式 rebase
$ git checkout feature
$ git rebase -i master
```

最后的那个命令会打开一个编辑器，包含 feature 的两个提交，和一些指示：

```shell
pick 32618c4 Start developing a featureA
pick 62eed47 Fix something from the previous commit
```

如果第二个提交修复了第一个提交中的小问题，你可以用 fixup 命令把它们合到一个提交中：

```shell
pick 32618c4 Start developing a featureA
fixup 62eed47 Fix something from the previous commit
```

保存后关闭文件，Git 会根据你的指令来执行 rebase。

#### **代码回滚**

还有一种常见的情况就是，代码已经提交后，发现此代码有问题，想回滚此提交。

1.如果还没 push 到远端

git reset (将一个分支的末端指向另一个提交)

```shell
$ git reset HEAD
$ git reset --soft HEAD (缓存区和工作目录都不会被改变)
$ git reset --mixed HEAD (默认选项。缓存区和你指定的提交同步，但工作目录不受影响)
$ git reset --hard HEAD (缓存区和工作目录都同步到你指定的提交)
```

HEAD 也可以传一个提交的id。

2.如果已经push到了远端

git revert (撤销一个提交的同时会创建一个新的提交)

```shell
$ git revert HEAD~2 (撤销倒数第二个提交)
```

#### **分支间合并提交**

将一个分支的更改并入另一个分支，主要有三种方式，如果是想把 feature 分支全部的 commit 内容都并入主分支，可以用前两种方法，如果只需要并入置顶的 commit 可以用第三种方法。

1.git merge

最常用的是 git merge，例如，如果 master 中新的提交和你的工作是相关的。为了将新的提交并入你的分支，你可以直接执行下面这些命令：

```shell
$ git checkout feature
$ git merge master
```

或直接压缩成一行：

```shell
$ git merge master feature
```

优点：merge 是一个安全的操作，现有的分支不会被更改，避免了 rebase 潜在的缺点。

缺点：每次合并上游更改时 feature 分支都会引入一个外来的合并提交。如果 master 非常活跃的话，这或多或少会污染你的分支历史。

2.git rebase

你可以像下面这样将 master 分支并入 feature 分支：

```shell
$ git checkout feature
$ git rebase master
```

把整个 feature 分支移动到 master 分支的后面，有效地把所有 master 分支上新的提交并入过来。

优点：项目历史会非常整洁。首先，它不像 git merge 那样引入不必要的合并提交。其次，rebase 导致最后的项目历史呈现出完美的线性，更容易使用 git log、git bisect 和 gitk 来查看项目历史。

缺点：如果你违反了 rebase 黄金法则（绝不在公共的分支上使用它），重写项目历史可能会给你的协作工作流带来灾难性的影响。此外，rebase 不会有合并提交中附带的信息，看不到 feature 分支中并入了上游的哪些更改。

3.git cherry-pick

可以选择某一个分支中的一个或几个 commit 来进行操作。

例如，你在 develop 分支拉出了一个 release 分支打算发版，但是 release 存在一个 bug，你在 release 分支修复完发版后，
想把修复这个 bug 的 commit 再合并回 develop 分支，就可以使用 cherry-pick。

> 注意：当执行完 cherry-pick 以后，将会生成一个新的提交；这个新的提交的哈希值和原来的不同，但标识名一样；

命令集合:

```shell
# 单独合并一个提交
$ git cherry-pick <commit id> 

# 单独合并一个提交，保留原提交者信息
$ git cherry-pick -x <commit id> 

# 把 <start-commit-id> 到 <end-commit-id> 之间 (左开右闭，不包含 start-commit-id)的提交 cherry-pick 到当前分支
$ git cherry-pick <start-commit-id>..<end-commit-id> 

# 把 <start-commit-id> 到 <end-commit-id> 之间 (闭区间，包含 start-commit-id)的提交 cherry-pick 到当前分支
$ git cherry-pick <start-commit-id>^..<end-commit-id> 
```

参考：

1. [git-recipes](https://github.com/geeeeeeeeek/git-recipes/wiki)
2. [图解 Git](http://marklodato.github.io/visual-git-guide/index-zh-cn.html)

