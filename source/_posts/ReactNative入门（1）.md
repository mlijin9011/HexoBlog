---
title: React Native入门（1）—— 组件及生命周期
date: 2016-07-10 11:54:34
categories:
- 技术
tags: 
- React Native
---

## 前言

作为一个 iOS 原生应用的开发者，刚开始接触 React Native，先来学习下 React Native 中的组件结构和生命周期，理解一个 React Native 组件如何进行展示，如何进行开发。

<!--more-->

## 组件的构成
在 React Native 中，所有展示的界面，都可以看做是一个组件（Component），每一个组件根据功能和逻辑的复杂程度，又都是由许多小的组件拼成，每个小的组件也都有自己对应的逻辑，不过他们都遵循同样的代码结构。

先来看一个完整的 js 文件中的代码，然后我们以它为例来分析其中的代码结构：

```
'use strict';

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View
} from 'react-native';

class AwesomeProject extends Component {
  render() {
    return (
      <View style={{alignItems: 'center'}}>
        <Text style={styles.welcome}>
          Welcome to React Native!
        </Text>
        <Text style={styles.instructions}>
          To get started, edit index.ios.js
        </Text>
        <Text style={styles.instructions}>
          Press Cmd+R to reload,{'\n'}
          Cmd+D or shake for dev menu
        </Text>
      </View>
    );
  }
}
const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('AwesomeProject', () => AwesomeProject);
```

这段代码中组件的代码结构：

### 包和组件引用

```
'use strict';

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View
} from 'react-native';
```

`'use strict'` 表示开启了 Strict Mode，Strict Mode 使 JavaScript 的错误处理可以有所提高，一些语言缺陷也可以避免。

`import {} from ''` 表示将 react、react-native 包加载进来，{ } 中的内容是引用来自 React Native 官方的组件、API 以及第三方或开发者项目中构建的组件，形式为该组件或 API 的 React 类名。import 是 ES6 的语法，这个概念等同于 iOS 或者 Swift 中的 “链接库” 或者 “导入库”。

### 组件类的声明

```
class AwesomeProject extends Component {
  render() {
    return (
      ...
    );
  }
}
```

这部分用于构造组件的状态和具体的展示结构，class 是在 ES6 中被引入的，利用 `class xxx extends Component {...}` 来实例化一个 React Native 组件对象，{ } 中的内容会包含组件的几个重要的生命周期（见下文），这部分是一个组件必不可少的地方，没有这些内容，就无法构成一个组件。

### 组件样式的声明

```
const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
```

使用 `StyleSheet.create({...})` 来实例化 React Native 样式对象，{ } 中的内容为 JSON 形式的 React Native 样式，来源于 CSS3，这些声明的样式可以在上面构建组件时（JSX 代码中）使用。

### 其他

```
AppRegistry.registerComponent('AwesomeProject', () => AwesomeProject);
```

AppRegistry 定义了 App 的入口，并提供了根组件。这部分只有在作为入口的 js 文件中才会有。

```
module.exports = HelloWorld;
```

这里导出了 HelloWorld 类，可以在外部 js 文件中引入 HelloWorld 组件。这部分只有在非入口js 文件中才会有。

## 组件的生命周期

一个 React Native 组件的生命周期分为实例化、存在期和销毁期三个阶段，如下图。

第一阶段：实例化期，是组件第一次绘制阶段，如图中的上面的虚线框内，在这个阶段完成了组件的加载和初始化；

第二阶段：存在期，是组件正在运行和交互阶段，如图中的左下的虚线框内，在这个阶段组件可以处理用户交互，或者接收事件更新界面；

第三阶段：销毁期，是组件被卸载消亡的阶段，如图中的右下的虚线框内，在这个阶段做一些组件的清理工作。

![logo](ReactNative入门（1）/component-lifecycle.jpg)

下面具体分析组件生命周期的各个阶段：

### 实例化阶段

实例化期分为5个阶段，每个阶段以一个函数来进行控制：

**getDefaultProps**

在组件创建的时候，会先调用 `getDefaultProps()`。由于这个函数在整个生命周期中只会调用一次，所以通常在这里会初始化组件的一些默认属性，将固定的内容放在这个过程中进行初始化和赋值。

**getInitialState**

在组件被创建后并加载的时候，会先调用 `getInitialState()` 来初始化组件的状态。该函数在整个生命周期中只会调用一次。

**componentWillMount**

在组件初始化后准备加载组件的时候，会先调用 `componentWillMount()`，在第一次绘制 `render()` 之前调用，也是渲染一个组件前最后一次修改 state 的机会。这个函数在整个生命周期中也只被调用一次，可以在这里做一些业务初始化操作，也可以设置组件状态。

**render**

这是一个组件必须有的方法，形式为一个有返回值的函数，会返回一段 JSX 或其他 React 组件来构成 DOM，表示该组件的结构和布局，和 Android 的 XML 布局类似。在 `render()` 函数中，只能通过 this.state 和 this.props 来访问在之前函数中初始化的数据值。

**componentDidMount**

在组件第一次绘制之后，会调用 `componentDidMount()`，表示组件已经加载完成，这个函数在整个生命周期中也只被调用一次。

从这个函数开始，就可以和 JS 其他框架交互了，例如设置计时 setTimeout、setInterval，或者发起网络请求，放在这个函数里进行，来保证不会出现UI上的错误。这个函数之后，就进入了稳定运行状态，等待事件触发。

>注：先调用子组件的 componentDidMount()，然后才调用父组件的。

### 运行阶段

运行期主要是用来处理与用户的交互：

**componentWillReceiveProps**

如果父元素对组件的属性（props）进行了修改，组件收到新的属性时，就会调用 `componentWillReceiveProps(object nextProps)`，参数 nextProps 是即将被设置的属性，可以通过 `this.props` 来获取旧的属性。

在这个回调函数里面，你可以根据属性的变化，通过调用 `this.setState()` 来更新组件状态，这里调用更新状态是安全的，并不会触发额外的 render() 调用。如下：

```
componentWillReceiveProps: function(nextProps) {  
  this.setState({
    likesIncreasing: nextProps.likeCount > this.props.likeCount
  });
}
```

**shouldComponentUpdate**

当组件接收到新的属性或者状态改变时，都会触发调用 `boolean shouldComponentUpdate(object nextProps, object nextState)`，参数 nextProps 是即将被设置的属性，同 `componentWillReceiveProps(...)` 一样，nextState 是即将更新的状态值。这个函数返回一个布尔值，来决定是否需要更新组件进行渲染，返回 true 表示需要更新，继续走后面的更新流程。否则不更新，直接进入等待状态。

**componentWillUpdate**

如果组件状态或者属性改变，并且上面的 `shouldComponentUpdate(...)` 返回为 true 时，会在开始渲染组件之前调用 `componentWillUpdate(object nextProps, object nextState)`，参数同 `shouldComponentUpdate(...)` 。这个函数调用之后，就会把 nextProps 和 nextState 分别设置到 this.props 和 this.state 中。接着就会调用 render() 来更新界面了。

**componentDidUpdate**

调用了 `render()` 更新完成界面之后，会调用 `componentDidUpdate(object prevProps, object prevState)`，此函数的输入参数变成了 prevProps 和 prevState，因为到这里已经完成了属性和状态的更新了。

### 销毁阶段

**componentWillUnmount**

当组件要被从界面上移除的时候，就会调用 `componentWillUnmount()`，在这个函数中，可以做一些组件相关的清理工作，例如取消计时器、网络请求、点击事件Listener等。

## 总结

组件的生命周期分成三个状态：

	Mounting：  已插入真实 DOM
	Updating：  正在被重新渲染
	Unmounting：已移出真实 DOM
	
React 为每个状态都提供了两种处理函数，will 函数在进入状态之前调用，did 函数在进入状态之后调用，三种状态共计五种处理函数：

	componentWillMount()
	componentDidMount()
	componentWillUpdate(object nextProps, object nextState)
	componentDidUpdate(object prevProps, object prevState)
	componentWillUnmount()

此外，React 还提供两种特殊状态的处理函数：

	componentWillReceiveProps(object nextProps)：组件收到新的参数时调用
	shouldComponentUpdate(object nextProps, object nextState)：判断是否重新渲染时调用

两个初始化函数：

	getDefaultProps()：进行初始化和赋值
	getInitialState()：初始化组件的状态

渲染函数：

	render()


参考博文：[React Native 中组件的生命周期](http://www.race604.com/react-native-component-lifecycle/)

