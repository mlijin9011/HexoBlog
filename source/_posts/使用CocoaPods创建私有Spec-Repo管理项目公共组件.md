---
title: 使用CocoaPods创建私有Spec Repo管理项目公共组件
date: 2016-08-19 19:14:19
categories:
- 技术
tags:
- iOS
- CocoaPods
---

# 前言

项目做多了，你会发现有很多基础功能模块是可以通用的，完全可以独立出来抽象成一个公用库，方便以后开发新项目的时候可以直接使用这些基础组件，不需要再重新开发，提高开发效率。同时，随着项目和业务的发展，工程量越来越大，业务模块越来越多，我们采用组件化的方式来开发，组件化就需要每个业务模块独立开发，方便迭代和代码管理。不管是通用的基础服务组件，还是独立的业务功能组件，都需要我们来进行组件管理。

CocoaPods 是非常好用的一个iOS依赖管理工具，使用它可以方便的管理和更新项目中所使用到的第三方库，以及管理自己的项目中的私有组件库。

<!--more-->

# CocoaPods 管理私有组件

我们通过 CocoaPods 来使用和管理项目中的第三方库非常方便也非常简单，下面我们来学习下如何创建自己的私有的组件仓库，管理私有组件。

## 1.创建私有 Spec Repo

Spec Repo 是一个存放了所有 Pods 的索引文件 podspec 的仓库，集成的时候就是通过仓库里的 Pod 所对应的索引文件来找到对应的源码或者 framework的，当你使用 CocoaPods 后他会被 clone 到本地的 `~/.cocoapods/repos` 目录下，Github 官方的 Spec Repo 叫 master，我们可以到这个目录下查看 master 下的结构：

```
.
├── Specs
    └── [SPEC_NAME]
        └── [VERSION]
            └── [SPEC_NAME].podspec
            
```

我们要存放私有的组件，当然不能用官方的 Repo 库了，所以我们要创建一个私有的 Spec Repo 库，首先我们先在 Gitlab 或者其他 Git 服务中创建一个仓库，例如我这里创建的一个仓库地址：https://gitlab.com/MZLApp/MZLSpecs.git 。            

仓库创建好之后，执行下面的命令来把这个仓库作为一个 Pod 索引仓库：

```
# pod repo add [Private Repo Name] [GitHub HTTPS clone URL]
$ pod repo add MZLSpecs https://gitlab.com/MZLApp/MZLSpecs.git
```

执行成功后，进入到 `~/.cocoapods/repos` 目录，就可以看到我们刚创建的 MZLSpecs 这个目录了，此时创建私有 Spec Repo 就完成了。

## 2. 创建 Pod 组件库

[CocoaPods](http://guides.cocoapods.org/making/using-pod-lib-create)提供了命令 `pod lib create xxx` 可以给我们很方便的创建一个 Pod，例如，创建一个 ObjC 常用的 Category 分类的公用组件库，执行下面的命令：

```
pod lib create MZLCategory
```

这里会询问几个问题，1.你的仓库是用什么语言（Swift/ObjC）；2.是否要帮你创建一个 Demo 工程；3.你是否需要一个测试框架（Specta/Kiwi/None）；4.你是否需要基于 View 测试；5.你的 Pod 库里类的前缀。按你的具体情况做出选择：

```
Cloning `https://github.com/CocoaPods/pod-template.git` into `MZLCategory`.
Configuring MZLCategory template.

------------------------------

To get you started we need to ask a few questions, this should only take a minute.

If this is your first time we recommend running through with the guide:
 - http://guides.cocoapods.org/making/using-pod-lib-create.html
 ( hold cmd and click links to open in a browser. )


What language do you want to use?? [ Swift / ObjC ]
 > ObjC

Would you like to include a demo application with your library? [ Yes / No ]
 > Yes

Which testing frameworks will you use? [ Specta / Kiwi / None ]
 > None

Would you like to do view based testing? [ Yes / No ]
 > No

What is your class prefix?
 > MZL
```

问题选择完成后，如果你选择了帮你创建 Demo 的话，CocoaPods 会自动帮你执行 `pod install` 来生成 workspace 文件，完成后并自动在 Xcode 中打开：

```
Running pod install on your new library.

Analyzing dependencies
Fetching podspec for `MZLCategory` from `../`
Downloading dependencies
Installing MZLCategory (0.1.0)
Generating Pods project
Integrating client project

[!] Please close any current Xcode sessions and use `MZLCategory.xcworkspace` for this project from now on.
Sending stats
Pod installation complete! There is 1 dependency from the Podfile and 1 total pod installed.

[!] Automatically assigning platform ios with version 8.3 on target MZLCategory_Example because no platform was specified. Please specify a platform for this target in your Podfile. See `https://guides.cocoapods.org/syntax/podfile.html#platform`.

 Ace! you're ready to go!
 We will start you off by opening your project in Xcode
  open 'MZLCategory/Example/MZLCategory.xcworkspace'

To learn more about the template see `https://github.com/CocoaPods/pod-template.git`.
To learn more about creating a new pod, see `http://guides.cocoapods.org/making/making-a-cocoapod`.
```

这样，一个 Pod 就创建好了，我们来看这个 Pod 的结构以及相关介绍如下：

```
MZLCategory
├── Example                     # Demo
│   ├── MZLCategory
│   ├── MZLCategory.xcodeproj
│   ├── MZLCategory.xcworkspace
│   ├── Podfile
│   ├── Podfile.lock
│   ├── Pods
│   └── Tests
├── LICENSE
├── MZLCategory                 # Pod 组件
│   ├── Assets                  # Pod 中的资源文件目录
│   └── Classes                 # Pod 中的类文件目录   
├── MZLCategory.podspec         # Pod 索引文件
├── README.md
└── _Pods.xcodeproj -> Example/Pods/Pods.xcodeproj
```

第一次提交，我们先配置好 podspec 文件，修改 summary、description、homepage、source 等配置，更多 podspec 的介绍在[这里](http://guides.cocoapods.org/making/specs-and-specs-repo.html)：

```
Pod::Spec.new do |s|
  s.name             = 'MZLCategory'
  s.version          = '0.1.0'
  s.summary          = '公用组件库：ObjC 的常用 Category 库'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
公用组件库：ObjC 的常用 Category 库，包括 NSString，UIImage 等常用的类的分类
                       DESC

  s.homepage         = 'https://gitlab.com/MZLApp/MZLCategory'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lijin' => 'mlijin9011@163.com' }
  s.source           = { :git => 'https://gitlab.com/MZLApp/MZLCategory.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MZLCategory/Classes/**/*'        #代码源文件地址，**/*表示Classes目录及其子目录下所有文件，如果有多个目录下则用逗号分开，如果需要在项目中分组显示，这里也要做相应的设置
  
  # s.resource_bundles = {
  #   'MZLCategory' => ['MZLCategory/Assets/*.png']  #资源文件地址
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'     #公开头文件地址
  # s.frameworks = 'UIKit', 'MapKit'                 #所需的framework，多个用逗号隔开
  # s.dependency 'AFNetworking', '~> 2.3'              #依赖关系，该项目所依赖的其他库，如果有多个需要填写多个s.dependency

end
```

这个 Pod 已经是一个本地的 Git 仓库，接着我们需要把本地仓库和远程仓库关联起来，先在 Gitlab 上创建一个相应的组件仓库：https://gitlab.com/MZLApp/MZLCategory.git

```
$ cd MZLCategory
$ git add .
$ git commit -s -m "Initial Commit of Pod Library"
$ git remote add origin git@gitlab.com:MZLApp/MZLCategory.git   #关联远端仓库
$ git push origin master     #提交到远端仓库
```

创建 tag，这个 tag 需要和 podspec 文件中的 version 一致，不然提交 pod 到 spec repo 的时候就会说找不到此版本，

```
git tag -m "Initial Pod" 0.1.0
git push --tags
```

## 3. 提交 Pod 到私有 Spec Repo

提交 Pod 到 Spec Repo 就是提交 Pod 的索引文件 podspec，提交之前先验证一下，验证通过后才能提交，执行下面的命令来验证：

```
pod lib lint --allow-warnings
```

验证成功后会输出：

```
-> MZLCategory (0.1.0)
MZLCategory passed validation.
```

验证成功后，我们就可以提交 podspec 到 Spec Repo 了，执行：

```
pod repo push MZLSpecs MZLCategory.podspec --use-libraries --allow-warnings
```

提交成功后，就可以在 `~/.cocoapods/repos/MZLSpecs` 目录下看到 MZLCategory 这个 Pod 了，同时 MZLSpecs 的远端仓库中 MZLCategory 这个 pod 的 podspec 也被 push 上去了。

```
MZLSpecs
└── MZLCategory
    └── 0.1.0
```

## 4. 私有 Pod 库的使用

使用方法同 Github 官方的第三方库，只需要在你的 Podfile 文件中添加你的 Spec Repo 地址作为查找 Pod 库的源地址：

```
source 'https://github.com/CocoaPods/Specs.git'
source 'https://gitlab.com/MZLApp/MZLSpecs.git'

use_frameworks!
inhibit_all_warnings!

platform :ios, '8.0'

target 'SinaNews' do
    pod 'AFNetworking', '3.1.0'
    ... ...
    pod 'MZLCategory',  '0.1.0'
end
```

# 参考

- [CocoaPods官方文档](http://guides.cocoapods.org/making/private-cocoapods.html)
- [使用Cocoapods创建私有podspec](http://www.cocoachina.com/ios/20150228/11206.html)


