# 微信多开助手

一款原生、开源、中文的 macOS 微信多开与文件管理工具。它把“再开一个微信”、聊天文件定位、空间占用检查、缓存安全清理、兼容增强和自动更新放在同一个可视化界面里。

> 本项目与腾讯、微信没有关联。WeChat 和微信是腾讯的商标。使用兼容增强前，请自行评估微信服务条款及账号风险。

## 主要功能

- **可视化多开**：无需终端命令，创建拥有独立账号容器的微信分身，并查看所有运行实例。
- **分身管理**：一键创建、启动、更新和移入废纸篓；微信升级后可保留分身登录数据并替换应用代码。
- **文件一键定位**：按“微信号一、微信号二”整理不同账号的文件，可自定义名称，不直接暴露 `wxid`。
- **克制的路径显示**：打开位置和复制路径直接可用，完整数据路径默认收起，需要时再查看。
- **空间占用检查**：按目录计算实际磁盘占用，不读取或展示聊天内容。
- **可恢复缓存清理**：只处理明确勾选的缓存目录，并移动到废纸篓，不会静默永久删除。
- **版本兼容增强**：参考 [sunnyyoung/WeChatTweak](https://github.com/sunnyyoung/WeChatTweak)，支持原生多开增强和保留撤回消息；仅在微信构建号精确匹配时开放。
- **完整备份与恢复**：修改微信前保存完整官方应用，恢复时重新验证腾讯签名。
- **自动更新**：使用 Sparkle 2，通过 HTTPS appcast、EdDSA 更新签名、Developer ID 签名和 Apple 公证完成自动下载、安装与重启。

## 下载与安装

1. 从 [Releases](https://github.com/makerjackie/WeChatManager/releases/latest) 下载最新的 `WeChatManager.dmg`。
2. 打开 DMG，把“微信多开助手”拖到“应用程序”。
3. 首次打开后，应用会自动找到已安装的微信。

发布版本支持 macOS 14 及以上，提供 Apple Silicon 与 Intel 通用二进制，并经过 Developer ID 签名和 Apple 公证。

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

首次使用文件管理时，macOS 会询问是否允许访问其他应用数据。该权限只用于识别和打开本机微信文件目录，应用不会读取或展示聊天内容。

## 使用与风险边界

- 本应用只处理用户本人 Mac 上的微信应用副本和本地文件，不连接、扫描或控制腾讯服务器，也不获取访问受限的服务端数据。
- 分身安装在系统“应用程序”文件夹，并使用独立 Bundle ID 和本地容器；项目不会分发任何修改后的微信安装包。
- 微信软件许可协议可能限制非官方第三方工具、客户端修改或多开行为，因此仍存在账号规则和合同层面的风险。
- 本项目与腾讯、微信没有关联，说明内容不构成正式法律意见。

## 兼容增强的安全规则

兼容增强会修改 `/Applications/WeChat.app`，因此需要管理员授权。应用始终执行以下检查：

1. 微信构建号必须和上游配置精确匹配。
2. 首次修改前，微信必须保留腾讯官方签名。
3. 在用户目录保存完整 `.app` 备份，不接触聊天数据。
4. 只应用用户明确选择的补丁目标。
5. 写入后重新验证 Mach-O 与代码签名；失败时尝试自动恢复。

分身多开和文件管理不需要安装兼容增强。分身方案通过独立 Bundle ID 工作，不依赖补丁地址；微信升级后可在“分身管理”中更新应用代码。旧版原生多开增强和撤回增强仍需要等待上游配置支持新构建号。

## 隐私

- 不上传微信文件、文件名、聊天记录、账号标识或目录内容。
- 不接入统计 SDK、广告 SDK 或远程日志平台。
- 网络访问仅用于获取开源兼容配置和软件更新。
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
