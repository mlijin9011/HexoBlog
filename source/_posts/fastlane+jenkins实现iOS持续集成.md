---
title: fastlane+jenkins实现iOS持续集成
date: 2017-04-08 12:29:31
categories:
- 技术
tags:
- iOS
- fastlane
- jenkins
---

# 概述

iOS 应用的证书配置、打包和上线，大家都知道，步骤很繁琐，如果纯人工处理的话是非常浪费时间的，因此，我抽空研究了下 fastlane ，fastlane 是用 Ruby 写的一套自动化工具集，用它可以很轻松的完成证书配置，打包发布等工作，配合 jenkins 使用效果更佳。

<!--more-->

# fastlane

![logo](fastlane+jenkins实现iOS持续集成/fastlane-logo.png)

## 1. fastlane 的简介

fastlane是自动化打包和发布 iOS 和 Android 应用的一套工具集，下图是 fastlane 的一些主要的工具[fastlane tools](https://fastlane.tools)，如自动化测试，生成截图，生成证书和签名文件，打包，发布程序等。

![image](fastlane+jenkins实现iOS持续集成/fastlane-intro-tree.png)


下面详细讲一下 fastlane 里面的几个主要的工具：


| 工具 | 介绍 |
| --- | --- |
| [scan](https://github.com/fastlane/fastlane/tree/master/scan) | 自动运行自动化测试工具，并且生成 HTML 报告 |
| [cert](https://github.com/fastlane/fastlane/tree/master/cert) | 自动创建管理证书 |
| [sigh](https://github.com/fastlane/fastlane/tree/master/sigh) | 自动创建，更新，下载 Provisioning Profile 文件 |
| [match](https://github.com/fastlane/fastlane/tree/master/match) | 管理证书和 Provisioning Profile |
| [pem](https://github.com/fastlane/fastlane/tree/master/pem) | 自动生成，更新 Notification 证书 |
| [snapshot](https://github.com/fastlane/fastlane/tree/master/snapshot)  | 自动截图 |
| [deliver](https://github.com/fastlane/fastlane/tree/master/deliver) | 自动上传应用截图，元数据，ipa 文件到 iTunes Connect |
| [produce](https://github.com/fastlane/fastlane/tree/master/produce) | 如果你的产品还没在 iTunes Connect 或者 Apple Developer Center 创建，produce可以自动帮你完成这些工作  |
| [gym](https://github.com/fastlane/fastlane/tree/master/gym) | 自动化编译打包工具 |

## 2. fastlane 的安装

1. 确保 Xcode command line 工具是最新版

  `xcode-select --install`

2. 安装fastlane

   官方提供了三种安装方法，gem、brew、直接下载安装
   
   简单点，可以直接用 gem 安装：
   
   `sudo gem install fastlane -NV`
   
   如果安装过程中报错：
   
   `ERROR:  While executing gem ... (Errno::EPERM) 
   Operation not permitted - /usr/bin/xxxx`
   
   可以执行命令：
    
    `sudo gem install -n /usr/local/bin fastlane`
   
   安装完成后可以使用 `fastlane -v` 检查是否安装成功，如果输出下面的结果，表示已安装成功，并且显示版本号。
   
   `fastlane installation at path:
/usr/local/lib/ruby/gems/2.4.0/gems/fastlane-2.25.0/bin/fastlane 
----------------------------- fastlane 2.25.0`

## 3. fastlane 的使用

### 3.1 初始化
    
在 工程的 .xcodeproj 文件的同级目录下，执行

`fastlane init`
    
这里会要求你输入 Apple ID，如果是第一次使用的话，还需要输入密码，fastlane 会自动检测当前项目的 App Name 和 App Identifier，也可以手动输入这些信息，如果你没有在 iTC 或者 ADC 中创建的话，他会询问你是否要帮你自动创建，非常智能。
    
执行完毕后，会根据你输入的信息，在当前目录下生成一个文件夹 fastlane，在 fastlane 文件夹下会自动生成两个配置文件 Appfile，Fastfile，我们可以修改这两个文件来完成我们所需要的功能。

如果在 init 的时候选择了在 iTC 中创建 App 的话，fastlane 会自动调用 produce 进行初始化，在 iTC 中成功创建后，fastlane 文件夹里面还会生成一个 Deliverfile 的文件，或者也可以后续手动创建。

### 3.2 fastlane 管理证书 & Provisioning Profile

#### cert

自动生成证书，并下载安装到 keychain 中

#### sigh

provisioning profile 的生成，管理，下载，签名等

##### 1. 生成

`fastlane sigh --development`

##### 2. 下载

`fastlane sigh download_all`

##### 3. 管理

`fastlane sigh manage`  管理，删除过期的profiles
`fastlane sigh repair`  修复过期或者无效的profiles

##### 4. 重新签名

`fastlane sigh resign ./path/app.ipa --signing_identity "iPhone Distribution: Felix Krause" -p "my.mobileprovision"`

#### gem

#### match & Matchfile

##### 1. 初始化 match

新建一个私有的 Git 仓库来存放和管理证书和 Provisioning Profiles。

执行 `fastlane match init`，按提示输入你的 Git 仓库地址，执行完毕后会生成一个 Matchfile 文件，像这样：

```Ruby
git_url "https://github.com/fastlane/fastlane/tree/master/certificates"

app_identifier "tools.fastlane.app"
username "user@fastlane.tools"
```

##### 2. 生成和安装

这个证书的仓库可以通过分支来管理不同项目的证书和配置文件，而不需要每个项目都创建一个仓库。

执行 `fastlane match` 可以从 Git 仓库中下载安装证书和 Provisioning Profile 到电脑中，如果 Git 仓库中没有的话，会创建证书和 profiles 文件，并上传到 Git 仓库中，其他人可以安装使用。

Git 仓库中的证书是加密过的，执行 match 时，会要求输入密码，创建证书的时候会用这个密码进行加密，安装证书的时候会用这个密码进行解密后安装。

也可以手动从你的 keychain 中导出证书，然后在你的仓库中，创建 `certs/distribution` 和 `certs/development
` 目录，分别存放开发和生产证书。

证书加密方法:

`openssl pkcs12 -nocerts -nodes -out key.pem -in certificate.p12`
`openssl aes-256-cbc -k your_password -in key.pem -out cert_id.p12 -a`
`openssl aes-256-cbc -k your_password -in certificate.cer -out cert_id.cer -a`

这里的 cert_id 可以通过下面的方法来查找当前账户下所有的证书 ID，然后找出你的证书 ID 就是这里的 cert_id。

```
require 'spaceship'

Spaceship.login('your@apple.id')
Spaceship.select_team

Spaceship.certificate.all.each do |cert| 
  cert_type = Spaceship::Portal::Certificate::CERTIFICATE_TYPE_IDS[cert.type_display_id].to_s.split("::")[-1]
  puts "Cert id: #{cert.id}, name: #{cert.name}, expires: #{cert.expires.strftime("%Y-%m-%d")}, type: #{cert_type}"
end
```

证书加密后存放到相应的目录中，接下来再上传 provisioning profile 文件，可以从 ADC 中下载，然后创建 `profiles/development`，`profiles/adhoc`，`profiles/appstore` 三个目录，分别存放开发，
AdHoc，生产环境的配置文件。用上面同样的方法执行 openssl 加密

`openssl aes-256-cbc -k your_password -in Development_XXX.mobileprovision -out Development_your.bundle.id.mobileprovision -a`

加密完成后生成三个文件如下：

`profiles/development/Development_your.bundle.id.mobileprovision`
`profiles/adhoc/AdHoc_your.bundle.id.mobileprovision
profiles/appstore`
`AppStore_your.bundle.id.mobileprovision`

把证书和 profile 上传到你的 Git 仓库中，其他人就可以执行 `fastlane match development` 来安装。

如果你不希望修改证书，可以在执行时在后面加 `--readonly`。

##### 3. 管理

你也可以像这样，在 Fastfile 里写 lane 来执行，如

```Ruby
desc "match"
  lane :sn_match do 
    match(git_branch: "your_branch", type: "development", readonly: true)
  end
```

这里可以显示的指定 app_identifier，如

```Ruby
match(git_branch: "your_branch", type: "development", app_identifier: "your.bundle.id", readonly: true)
```

如果你有多个 Target，如 Watch，Extension。

```Ruby
match(git_branch: "your_branch", app_identifier: ["com.krausefx.app1", "com.krausefx.app2", "com.krausefx.app3"], readonly: true)
```

也可以在 Matchfile 中声明：

```Ruby
git_url "https://github.com/fastlane/fastlane/tree/master/certificates"

app_identifier ["com.krausefx.app1", "com.krausefx.app2", "com.krausefx.app3"]
```

你也可以通过 match 来注册新的设备，通过 `force_for_new_devices` 来更新 profiles 到Git 仓库中。

```Ruby
desc "match"
  lane :sn_match do 
    register_devices(devices_file: "./devices.txt")
    match(git_branch: "your_branch", force_for_new_devices: true)
  end
```

`force_for_new_devices` 可以自动进行设备检测，是否距离上次 match 有新的设备加入，并更新你的仓库中的 profile 文件。

### 3.3 fastlane 自动化测试

#### scan & Scanfile

Test 和 UITest

### fastlane 打包

#### Appfile 
    
[Appfile](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Appfile.md)，存放了一些 app 本身的信息，如，apple_id, app_identifier, team_id 等等。

默认情况下，Appfile 如下所示：

```Ruby
app_identifier "com.mzl.testapp" # The bundle identifier of your app
apple_id "mlijin9011@163.com"  # Your Apple email address

# You can uncomment the lines below and add your own 
# team selection in case you're in multiple teams
# team_name "Team Name"
# team_id "Q2CBPJ58CA"

# To select a team for iTunes Connect use
# itc_team_name "Company Name"
# itc_team_id "18742801"
```

如果你的 iTunes Connect 和 Apple Developer Portal 有不同的证书，请使用以下代码：

```Ruby
app_identifier "com.mzl.testapp"       # The bundle identifier of your app

apple_dev_portal_id "portal@company.com"  # Apple Developer Account
itunes_connect_id "tunes@company.com"     # iTunes Connect Account

team_id "Q2CBPJ58CA" # Developer Portal Team ID
itc_team_id "18742801" # iTunes Connect Team ID

```

如果你的项目在每个环境（测试版，Store版，企业版）中的 bundle id 不同的话，则可以使用 for_platform 或 for_lane 模块声明定义。


```Ruby
app_identifier "com.mzl.testapp"
apple_id "mlijin9011@163.com"
team_id "Q2CBPJ58CC"

for_platform :ios do
  team_id '123' # for all iOS related things
  for_lane :build_inhouse do
    app_identifier 'com.mzl.testapp.inhouse'
  end
end

```

如果你想从你的 Fastfile 中访问这些值的话，可以在 Fastfile 中这样写


```Ruby
identifier = CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
team_id = CredentialsManager::AppfileConfig.try_fetch_value(:team_id)
```

#### Fastfile

[Fastfile](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md) 是最重要的一个文件，主要是些 lane 的集合，在这里可以编写和定制我们的自动化脚本，所有的流程控制功能都写在这个文件里面，利用 lane 来完成我们的自动化需求。

Fastfile 中可以同时支持不同的平台，iOS，macOS，Android，针对不同的平台，可以自定义自己的脚本，像这样：

```Ruby
fastlane_version "2.14.2"
default_platform :ios

before_all do
  puts "This block is executed before every action of all platforms"
end

platform :ios do
  before_all do
    cocoapods
  end

  desc "build beta"
  lane :beta do
    gym
    hockey
  end

  after_all do
    puts "Finished iOS related work"
  end
end

platform :mac do
  lane :beta do
    xcodebuild
    hockey
  end
end

lane :test do
  puts "this lane is not platform specific"
  xctool
end

after_all do
  puts "Executed after every lane of both Mac and iPhone"
  slack
end

error do |lane, exception|
  puts "Executed when every lane of both Mac and iPhone has error"
  slack
end

```

fastlane_version：指定fastlane使用的最小版本 
default_platform：指定当前默认的平台，可以选择 ios/android/mac
before_all：是在执行每一个 lane 之前都会调用这部分，所以如果有一些前提性的操作，可以写在这里，比如 cocoapods，match 等。最外面的 before_all 表示所有平台的都会执行，写在 platform ios 里面的 before_all 是只有执行 ios 平台的lane 才会执行到的。
after_all：同理，是在每个 lane 执行完成之后都会执行这部分的内容
error：每个 lane 执行出错就会执行这部分的内容
desc：对 lane 的描述，fastlane 会自动将 desc 的内容生成说明文档
lane：任务，执行的时候使用 fastlane [ios] lane名称，如上可以这样用：`fastlane ios beta`

fastlane 提供了很多 [action](https://docs.fastlane.tools/actions) 或者 plugin 可以在 Fastfile 的 lane 里面调用，如上面提到的 match，sigh，gym，deliver 等，还有插件 cocoapods 等。

贴一段我项目中使用的 Fastfile 的一部分看下：

```Ruby
fastlane_version "2.23.0"

default_platform :ios

PROJECT_FILE_PATH = 'MyProject.xcodeproj'
OUTPUT_PATH = 'build/'
APP_NAME = 'MyProject'
SCHEME_NAME = 'MyProject'
PLIST_FILE_PATH = 'MyProject/Info.plist'

INHOUSE_IDENTIFIER = 'com.bundle.id.inhouse'
APPSTORE_IDENTIFIER = 'com.bundle.id'

# 上传 ipa 包的平台，可以用 蒲公英，Bugly 等替代
OTA_SERVER_URL = 'http://ota.client.xxx.xxx.cn/ios/upload'

# 更新bundle id信息，修改app identifier
def update_bundle_id(app_id)
  say 'update bundle id'
  update_app_identifier(xcodeproj: PROJECT_FILE_PATH,
                        plist_path: PLIST_FILE_PATH,
                        app_identifier: app_id)
end

# 修改build号
def update_build_version(options)
  say 'update build version'

  buildVersion = options[:build]
  set_info_plist_value(path: PLIST_FILE_PATH,
                       key: "ProjectBuildVersion",
                       value: buildVersion)
end

# 修改bundle号
def update_bundle_version(typePrefix,options)
  say 'update bundle version'

  bundleVersion = options[:build] + "#{typePrefix}"
  set_info_plist_value(path: PLIST_FILE_PATH,
                       key: "CFBundleVersion",
                       value: bundleVersion)
end

# 打包
def generate_ipa(configuration,exportMethod,options)
  say 'generate ipa'

  fullVersion = get_version_number + "_" + options[:build]
  outputName = "#{APP_NAME}_V#{fullVersion}_#{configuration}"
  outputPath = "#{OUTPUT_PATH}#{outputName}/"

  gym(
    scheme: "#{SCHEME_NAME}",
    clean: true,
    output_directory: "#{outputPath}",
    output_name: "#{outputName}.ipa",
    configuration: "#{configuration}",
    include_symbols: "true",
    # archive_path: "#{outputPath}",
    # 指定打包所使用的输出方式，目前支持app-store, package, ad-hoc, enterprise, development, 和developer-id
    export_method: "#{exportMethod}"
  )

  upload_ota("../#{outputPath}", outputName, configuration)
end

# 上传 OTA
def upload_ota(output_path, app_name, configuration)
  say 'upload ipa to ota'

  # 99-AppStore包, 0-正式包, 1-开发临时测试包, 2-第三方渠道包, 3-每日构建包
  # 默认为1
  force_bundle_id = APPSTORE_IDENTIFIER
  type = 1
  if configuration == "Inhouse"
    force_bundle_id = INHOUSE_IDENTIFIER
    type = 2
  elsif configuration == "AdHoc"
    type = 0
  elsif configuration == "Release"
    type = 99
  end
  sh "curl -# -S -F 'pkg_file=@#{output_path}#{app_name}.ipa' -F 'dsym_file=@#{output_path}#{app_name}.app.dSYM.zip' -F 'version=#{app_name}' -F 'description=#{app_name}' -F 'app_bundle_id=#{APPSTORE_IDENTIFIER}' -F 'pkg_type=#{type}' -F 'force_bundle_id=#{force_bundle_id}' #{OTA_SERVER_URL}"
end

platform :ios do
  before_all do
    # ENV["SLACK_URL"] = "https://hooks.slack.com/services/..."
    # cocoapods
    puts File.absolute_path(".")
  end

  desc "更新build号"
  lane :buildVersion do |options|
    update_build_version(options)
  end 

  desc "更新Debug版bundle号"
  lane :debugBundleVersion do |options|
    update_bundle_version(".Debug",options)
  end 

  desc "更新AppStore版bundle号"
  lane :storeBundleVersion do |options|
    update_bundle_version("",options)
  end   

  desc "打Debug包"
  lane :build_debug do |options|
    buildVersion options
    generate_ipa("Debug","development",options)
  end

  desc "打Inhouse包"
  lane :build_inhouse do |options|
    buildVersion options
    update_bundle_id("#{INHOUSE_IDENTIFIER}")
    generate_ipa("Inhouse","enterprise",options)
    # 还原
    update_bundle_id("#{APPSTORE_IDENTIFIER}")
  end

  desc "打Adhoc包"
  lane :build_adhoc do |options|
    buildVersion options
    generate_ipa("AdHoc","ad-hoc",options)
  end

  desc "打Alpha包"
  lane :build_alpha do |options|
    development options
    inhouse options
    adhoc options
  end

  desc "打AppStore包"
  lane :build_release do |options|
    buildVersion options
    storeBundleVersion options
    update_bundle_id("#{APPSTORE_IDENTIFIER}")
    generate_ipa("Release","app-store",options)
  end

  desc "match"
  lane :sn_match do 
    # 这两行可以注册新设备，并且自动更新仓库下的profiles文件
    # register_devices(devices_file: "./devices.txt")
    # match(git_branch: "branch", type: "development", force_for_new_devices: true)
    match(git_branch: "branch", readonly: true)
  end

  after_all do |lane|

    # slack(
    #   message: "Successfully deployed new App Update."
    # )
  end

  error do |lane, exception|
    # slack(
    #   message: exception.message,
    #   success: false
    # )
  end
end


# More information about multiple platforms in fastlane: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
# All available actions: https://docs.fastlane.tools/actions

# fastlane reports which actions are used
# No personal data is recorded. Learn more at https://github.com/fastlane/enhancer

```

### 3.4 fastlane 发布 

#### deliver & Deliverfile

[Deliverfile](https://github.com/fastlane/fastlane/blob/master/deliver/Deliverfile.md) 主要是用于发布上传时的配置文件。

前面介绍了，如果在 `fastlane init` 的时候选择了在 iTunes Connect 创建 App，那么 fastlane 会调用 produce 进行初始化，同时会执行 `deliver init`，执行完毕后会创建一个 Deliverfile 文件，如果没有在初始化的时候选择执行 produce 流程当然 deliver 也不会执行，可以手动执行 `fastlane deliver init` 创建。

执行时，会自动登录你在 Appfile 中设置的 itunes_connect_id，根据 Appfile 中的 app_identifier，会为你下载当前 iTC 中的截图，元数据等等。执行完成后会生成
一个 Deliverfile 文件，/metadata 和 /screenshots 文件夹。

本地修改 Deliverfile，元数据，或者截图文件，执行 `fastlane deliver` 后，可以上传到 iTunes Connect 上。

如果你想把你本地的 ipa 文件上传到 iTunes Connect 上，可以执行：

`fastlane deliver --ipa "App.ipa" --submit_for_review`

如果你之前上传过 ipa 包，想选择一个用来提交审核，可以执行：

`fastlane deliver submit_build --build_number xxxx`

这里 xxxx 是你想选择的 build number。或者，可以直接选择最新的：

`fastlane deliver submit_build --latest`

在 Fastfile 里可以这样写：


```
deliver(app_version: ENV["app_versionName"],
        ipa: "#{ipa_path}",
        submit_for_review: false
       )
```


# 参考文章

> [官方文档](https://github.com/fastlane/fastlane)
> [Simplify your life with fastlane match](http://macoscope.com/blog/simplify-your-life-with-fastlane-match/#migration)






