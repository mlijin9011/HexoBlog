---
title: ReactNative入门（3）—— ReactNative与原生的交互
date: 2016-12-17 16:03:28
categories:
- 技术
tags:
- React Native
- iOS
---

### 概述

在项目中，通常我们会使用 RN 和原生混合开发的模式，所以这就涉及到一个重要的内容—— RN 和原生之间的数据交互。现在我们来一起看一下该怎样去实现数据交互。交互涉及到两部分内容:1. OC 打开 RN 页面；2. RN 调用 OC 方法；3. OC 调用 RN 方法。

<!--more-->

### iOS 原生页面打开 RN 页面

可以自定义一个 `ReactViewController` 类，在这个控制器中添加一个 `RCTRootView` 作为子 View。这样这个 ViewController 就可以显示一个 RN 页面了，具体实现方法：

```
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
	NSURL *jsCodeLocation = [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle?platform=ios&dev=true"];
	RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"test"
                                               initialProperties:nil
                                                   launchOptions:nil];
	reactView.frame = self.view.bounds;
	[self.view addSubView:rootView];
}
```

### RN 调用 OC 方法

首先创建一个工具类，来专门处理 RN 和 OC 间的交互，例如 `ReactUtil`，这个类需要实现 `RCTBridgeModule` 协议，`RCTBridgeModule` 是定义好的 protocol，实现该协议的类，会自动注册到 OC 对应的 Bridge 中。
OC-Bridge 上层负责与 OC 通信，下层负责和 JS-Bridge 通信，而 JS-Bridge 负责和 JS 通信。
这样通过 OC-Bridge 和 JS-Bridge 就可以实现 JS 和 OC 的相互调用了。

ReactUtil 类的具体实现：

```
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(jsInvokeApp:(NSString *)eventName parameter:(NSDictionary *)parameter resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"接收到RN传过来的事件名：%@，数据为:%@", eventName, parameter);
    
    //  TODO: 具体业务处理，可根据eventName，parameter等区分
    BOOL result;
    if (result) {
        resolve(@"");
    } else {
        NSError *error = [NSError errorWithDomain:@"com.XXX.domain" code:1 userInfo:nil];
        reject(@"code", @"message", error);
    }
}

```

所有实现 `RCTBridgeModule` 协议的类都必须显示的 include 宏命令: `RCT_EXPORT_MODULE()`。
`RCT_EXPORT_MODULE` 的作用是当 OC-Bridge 加载的时候，自动注册一个 Module。这个 Module 可以在 JS-Bridge 中调用。
`RCT_EXPORT_MODULE` 接受字符串作为其 Module 的名称，如果不设置名称的话默认就使用类名作为 Module 的名称。

最后我们需要在 JS 文件中调用 `ReactUtil` 中的方法即可:

```
var { NativeModules } = require('react-native');
var ReactUtil = NativeModules.ReactUtil;
 
//获取Promise对象处理
async _updateEvents() {
    try {
       var events = await ReactUtil.jsInvokeApp('eventName', {'key':'value'});
       this.setState({events});
    } catch(e) {
       this.setState({events:e.message});
    }
}
```

### OC 调用 RN 方法

在 0.27 版本之前，调用方式是这样的：

```
@synthesize bridge = _bridge; 
- (void)appInvokeJs:(NSString *)eventName eventBody:(NSDictionary *)eventBody { 
  [_bridge.eventDispatcher sendDeviceEventWithName:eventName body:eventBody];
}
```

现在 xcode 里面一直提示这种方式可能要被取代：

`'sendDeviceEventWithName:body:' is deprecated: Subclass RCTEventEmitter instead`

现在可以这样写：修改我们刚才写的 `ReactUtil` 继承自 `RCTEventEmitter`

然后要重写下面这个方法:

```
// TODO: 所有 app 通知 JS 的方法
- (NSArray<NSString *> *)supportedEvents {
  return @[@"appInvokeJs"];
} 
 
```

然后实现你导出的所有方法，里面都使用 sendEventWithName 方法即可

```
- (void)appInvokeJs:(NSString *)eventName eventBody:(NSDictionary *)eventBody {
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    [body setObject:eventName forKey:@"eventName"];
    [body setObject:eventBody forKey:@"eventBody"];
    [self sendEventWithName:@"appInvokeJs" body:body];
}
```

最后 JS 端调用

```
import {
  ... 
  NativeModules,
  NativeEventEmitter,  //导入 NativeEventEmitter 模块
} from 'react-native';
  
var ReactUtil = NativeModules.ReactUtil;
const myNativeEvent = new NativeEventEmitter(ReactUtil);  //创建自定义事件接口
  
//在组件中使用
componentWillMount() {
    this.listener = myNativeEvent.addListener('appInvokeJs', this.appInvokeJs.bind(this)); 
}
componentWillUnmount() { 
    this.listener && this.listener.remove();
    this.listener = null; 
} 

appInvokeJs(data) {
    //接受原生传过来的数据 
    data = {eventName:,eventBody:}
    if (data.eventName == 'EventName') {
       //
    } else {
        
    }  
}
```







