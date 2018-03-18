---
title: ReactNative入门（2）—— 接入原生应用
date: 2016-04-24 10:18:09
categories:
- 技术
tags:
- React Native
- iOS
---


## 安装 React Native 依赖

在工程所在目录新建一个文件夹，作为 JS 文件目录，在这个文件夹下，安装 React 和 React Native 依赖：

```
cd x/xx/xxx #你的工程路径
npm install react
npm install react-native
```
	
这时这个文件夹下会出现一个 node_modules 文件夹，react 依赖库就在这个文件夹下。

<!--more-->

## CocoaPods安装

在 Podfile 文件中增加以下的内容：

```
# path 后面的内容修改为正确的路径，根据你的 node_modules 文件夹路径。
pod 'React', :path => './node_modules/react-native', :subspecs => [
  'Core',
  'RCTImage',
  'RCTNetwork',
  'RCTText',
  # 添加其他你想在工程中使用的依赖。
]
```

接着安装 pods：

```
$ pod install
```
	
## 创建 React Native 应用

首先，创建一个文件夹来保存 React 代码，然后创建一个 js 文件：

```
$ mkdir ReactViews
$ touch ReactViews/test.js
```

然后写你的 js 代码：

```
'use strict';

import React, { Component } from 'react';
import {
  AppRegistry,
  Text,
  StyleSheet,
  View,
} from 'react-native';

var styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'red'
  }
});

class SimpleApp extends Component {
  render() {
    return (
      <View style={styles.container}>
        <Text>This is a simple react native application.</Text>
      </View>
    )
  }
}

AppRegistry.registerComponent('SimpleApp', () => SimpleApp);
```

SimpleApp 是你的模块名，这个在后面会要用到。

接着，往应用里添加容器视图，来容纳 React Native 组件，它可以是你应用里任何的 UIView。

新建一个 ReactView 继承 UIView。

// ReactView.h

```
#import <UIKit/UIKit.h>
@interface ReactView : UIView

@end
```

往 ReactView 里添加 RCTRootView，来包含你的 React Native 应用。

// ReactView.m 

```
#import "RCTRootView.h"

@implementation MZLReactView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        
        NSURL *jsCodeLocation = [NSURL URLWithString:@"http://localhost:8081/test.bundle?platform=ios"];
        // NSURL *jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"jsbundle"];
    
        RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation moduleName:@"SimpleComponent" initialProperties:nil launchOptions:nil];
        [self addSubview:rootView];
        
        rootView.frame = self.bounds;
    }
    return self;
}

@end
```

在 UIViewController 中使用这个 ReactView，这样就创建了一个 React Native 应用。

## 运行

在工程的根目录下，开启 React Native 开发服务器：

```
(JS_DIR=`pwd`/ReactViews; cd node_modules/react-native; npm run start -- --root $JS_DIR)
```

这条命令会启动一个 React Native 开发服务器，用于构建我们的 bundle 文件。--root 选项用来标明你的 React Native 应用所在的根目录。在我们这里是 ReactViews 目录，里面有一个test.js 文件。开发服务器启动后会打包出 test.bundle 文件来，并可以通过 `http://localhost:8081/test.bundle` 来访问。

现在编译和运行你的应用，就可以看到你的 React Native 应用在 ReactView 内运行。

## 总结

在底层，当 RCTRootView 初始化完成以后，它会尝试从开发服务器下载、解析并运行打包后的脚本文件。所以你所要做的就是实现你自己的容器视图或者视图控制器，然后把 RCTRootView 作为子视图加入，接下来 RCTRootView 会搞定你的脚本文件然后渲染你的 React 组件。

你可以在这里获得一个样例应用的完整源代码。


参考博文：[React Native 中文网：嵌入到现有原生应用](http://reactnative.cn/docs/0.31/integration-with-existing-apps.html#content)

