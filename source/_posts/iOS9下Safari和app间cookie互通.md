---
title: iOS9下Safari和app间cookie互通
date: 2016-08-13 16:10:02
categories:
- 技术
tags:
- iOS
---

## 前言

现在项目有一个需求，比如某新闻业务，当用户还没有下载 app 时，在手机上的 Safari 中浏览了一篇新闻，然后在浏览器中点击“在 app 中查看”，会自动跳转到 AppStore 中下载 app，此时用户可能希望在下载完 app 后能够继续刚才在 Safari 中的浏览内容和一些用户行为。但是用户被引导下载后，并不会希望需要重新回到浏览器，重新再由浏览器发起一个拉起 app 的操作来实现在 app 中的继续浏览，而是更希望在下载后，直接点击 AppStore 中的打开，或者手动打开 app 后，就能够继续刚才的浏览，这就需要在 Safari 和 app 间形成一种数据的互通。

<!--more-->

大概有这么两种方案可以实现这个功能：

一是当用户在 Safari 中浏览新闻内容时，上传用户行为和用户数据到我们服务器中，以一个唯一标识来标识这个设备的数据，这个数据会有一定的时效性，在这个时效性内下载并打开 app，我们会当做用户是希望能够继续延续刚才的浏览。当用户下载 app 打开后，用唯一标识从服务器请求用户行为数据，通过这个数据来打开相应的浏览内容，这样就实现了上面所说的功能。

二是当用户在 Safari 中浏览新闻内容时，保存用户行为数据到 Safari 中的 cookie 里，当用户下载并打开 app 后，我们去读取 Safari 中的 cookie，通过 cookie 内容来打开相应的浏览内容。

第一种方式，能够唯一标识设备的这个值要具备苛刻的条件，想找到其实很不容易，而且可能还会有一定的误伤几率，所以我们选择了第二种方式。

## Cookie 互通

iOS 系统中每个 app 都有自己的沙盒，无法跨越沙盒去访问数据，但是在 iOS9 以后，苹果提供了一个 API：`APISFSafariViewController`，它跟系统的 Safari 同属于一个 app，所以通过它可以读到 Safari 中的 cookie，那么我们可以在我们的 app 中打开这个 `APISFSafariViewController`，这样就可以拿到系统 Safari 中保存的 cookie 数据了。但是这个 cookie 内容只是在 `APISFSafariViewController` 中打开的 wap 页面可以读到，在 app 内是读不到的，可以通过 URL Scheme（OpenUrl）的方式，把这个 cookie 内容传递到 app 中，这样就可以实现我们上面的需求了。

具体的实现思路如下：

用户通过 Safari 浏览 wap1 页面，wap1 页面把用户行为数据写到 cookie 中，当用户通过引导下载 app 后，第一次打开 app 时，在 app 内打开 `APISFSafariViewController`，打开一个 wap2 页面，在这个 wap2 页面先取到刚才 wap1 页面保存的 cookie 数据，然后在 wap2 中通过 openUrl 的方式，把这个 cookie 数据传递到 app 中，然后通过这个 cookie 数据来实现延续阅读的功能。

在这里，wap1 页面是我们正常的一个 html 页面，里面只是加一个写用户行为数据到 Safari 中的cookie 的操作，这个 cookie 的域采用我们约定好的值，即只有在这个域下的 html 才能读取到这个 cookie。wap2 页面是一个专门用来静默的获取 wap1 的 cookie 值的页面，并且可以静默的通过 openUrl 的方式把 cookie 回传给 app。

可能你会觉得在程序启动后，弹出一个 Safari 页面有点不妥，那么我们可以把这个 `APISFSafariViewController` 设置为纯透明，这样用户就感觉不到了，然后这个纯透明的 Safari 再通过 openUrl 的方式呼起我们要延续阅读的页面，如果不需要延续阅读，那么就设定一个时间值，在这个时间值后，把这个纯透明的 Safari 隐藏。

## 总结

前提：safari中打开h5页面，在app中还原

html1 页面写 cookie 到 safari，app启动后打开一个透明的safari页面，这个safari页面请求另外一个与 html1 同域名的 html2,
html2 读取到 html1 存的 cookie 后，通过 scheme 的方式，在app中打开相对应的页面，完成场景还原

## 后期补充

上述使用 `APISFSafariViewController` 这种获取 cookie 的方式，SafariViewController 始终是隐藏的，而 iOS 10 以后这是苹果命令禁止的：

> SafariViewContoller must be used to visibly present information to users; the controller may not be hidden or obscured by other views or layers. Additionally, an app may not use SafariViewController to track users without their knowledge and consent.
> 

所以这种方式，目前仅能支持 iOS 9 ，iOS 10 以上需要再找别的途径。

参考博文：[iOS app与浏览器 跨域互通](http://www.jianshu.com/p/1a46187141fc)


