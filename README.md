# 微信多开助手

开源的 macOS 微信多开与文件管理工具。

![微信多开助手：多开、文件管理、一键更新与 iCloud 同步](docs/assets/wechat-manager-hero.webp)

> 本项目与腾讯、微信没有关联。WeChat 和微信是腾讯的商标。使用兼容增强前，请自行评估微信服务条款及账号风险。

## 主要功能

- **微信多开**：创建和管理多个独立微信分身，保留登录与聊天数据。
- **方案与同步**：保存常用分身组合，一键更新，并通过 iCloud 同步方案。
- **文件管理**：按账号整理微信文件，快速打开位置、查看占用和清理缓存。
- **兼容增强**：支持原生多开增强和保留撤回消息；不兼容时会给出可用版本与下载入口。

## 下载与安装

从 [Releases](https://github.com/makerjackie/WeChatManager/releases/latest) 下载 DMG，打开后拖入“应用程序”即可。支持 macOS 14 及以上，以及 Apple 芯片和 Intel Mac。

## 首次启动与权限

首次启动按引导允许访问微信应用、微信文件和应用管理即可。兼容增强需要管理员授权；其他权限由微信分身在使用时自行申请。

## 微信文件在哪里

微信 4.x 的常见入口是：

```text
~/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files
```

每个账号通常包含：

```text
msg/file       收到的文件
msg/video      聊天视频
cache          临时缓存
db_storage     聊天数据库与索引
```

这些路径会随微信版本变化，因此应用使用结构检测，而不是只依赖一个写死的账号目录。

首次使用文件管理时，macOS 会询问是否允许访问其他应用数据。该权限只用于识别和打开本机微信文件目录，应用不会读取、展示或上传聊天内容。

## 使用与风险边界

- 本应用只处理用户本人 Mac 上的微信应用副本和本地文件，不连接、扫描或控制腾讯服务器，也不获取访问受限的服务端数据。
- 分身安装在系统“应用程序”文件夹，并使用独立 Bundle ID 和本地容器；项目不会分发任何修改后的微信安装包。
- 如果当前微信已被其他本机工具修改，分身会按当前状态创建；第三方修改本身的兼容性由对应工具决定。
- 微信软件许可协议可能限制非官方第三方工具、客户端修改或多开行为，因此仍存在账号规则和合同层面的风险。
- 本项目与腾讯、微信没有关联，说明内容不构成正式法律意见。

## 兼容增强的安全规则

兼容增强会修改 `/Applications/WeChat.app`，因此需要管理员授权。应用始终执行以下检查：

1. 微信构建号必须和上游配置精确匹配。
2. 首次修改前，微信必须保留腾讯官方签名。
3. 在用户目录保存完整 `.app` 备份，不接触聊天数据。
4. 只应用用户明确选择的补丁目标。
5. 写入后重新验证 Mach-O 与代码签名；失败时尝试自动恢复。

分身多开和文件管理不需要安装兼容增强，也不要求腾讯原始签名。兼容增强仍需要精确版本配置与可信备份；微信升级后可能需要等待上游适配。

当前推荐的增强版本是微信 `4.1.5.28`（构建 `32288`）：优先使用[腾讯官方下载](https://dldir1.qq.com/weixin/Universal/Mac/xWeChatMac_universal_4.1.5.28_32288.dmg)，官方地址失效时再使用[历史版本备份](https://github.com/canc3s/wechat-versions/releases/tag/v4.1.5.28-mac)。应用会以实时上游配置为准，不会把仅“版本号接近”的微信误判为可用。

## 隐私

- 不上传微信文件、文件名、聊天记录、账号标识或目录内容。
- 不接入统计 SDK、广告 SDK 或远程日志平台。
- 网络访问仅用于获取开源兼容配置、软件更新，以及同步用户主动保存的 iCloud 方案。
- iCloud 只用于同步用户主动保存的分身方案元数据；本机不可用时仍保留本地副本。
- 清理功能只移动白名单缓存到废纸篓。

## 本地开发

要求 Xcode 26、Swift 6 和 XcodeGen：

```bash
brew install xcodegen
xcodegen generate
xcodebuild test \
  -project WeChatManager.xcodeproj \
  -scheme WeChatManager \
  -destination 'platform=macOS'
```

项目使用 SwiftUI、Observation、Swift Concurrency、Security.framework 与 Sparkle 2。没有服务端组件。

## 发布

发布脚本会生成 Universal 2 Archive、Developer ID 导出包、公证 `.app`、可拖放安装的 DMG、DMG 公证票据和 Sparkle appcast：

```bash
scripts/release.sh 1.0.0 1
```

本机需要 Developer ID Application 证书、已登录的 `asc`，以及 Sparkle `generate_keys` 保存在钥匙串里的 EdDSA 私钥。

## 开源与致谢

本项目采用 [GNU AGPL-3.0](LICENSE) 开源。

- Mach-O 补丁思路与兼容数据来源：[sunnyyoung/WeChatTweak](https://github.com/sunnyyoung/WeChatTweak)，AGPL-3.0。
- 独立 Bundle ID 分身方案参考：[fzlzjerry/wechat-antirecall](https://github.com/fzlzjerry/wechat-antirecall)。本项目重新实现了适用于 GUI 管理的版本。
- 自动更新框架：[Sparkle](https://sparkle-project.org/)，MIT License。

完整第三方说明见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
