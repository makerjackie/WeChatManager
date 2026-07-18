# 第三方开源说明

## WeChatTweak

- 项目：https://github.com/sunnyyoung/WeChatTweak
- 作者：Sunny Young 与贡献者
- 许可证：GNU Affero General Public License v3.0
- 用途：Mach-O 补丁实现思路与微信构建版本兼容配置。

本项目对相关逻辑进行了 GUI、安全备份、精确目标选择、路径校验和错误恢复扩展，并依照 AGPL-3.0 公开完整源代码。

## Sparkle

- 项目：https://github.com/sparkle-project/Sparkle
- 许可证：MIT License
- 用途：macOS 应用自动检查、下载、验证、安装与重启更新。

Sparkle 的许可证与版权信息会随 `Sparkle.framework` 一并分发。

## wechat-antirecall

- 项目：https://github.com/fzlzjerry/wechat-antirecall
- 作者：fzlzjerry 与贡献者
- 用途：独立 Bundle ID 微信分身方案的公开技术参考。

本项目没有复制或打包该项目的 CLI/GUI 源码，而是使用 Foundation、Security.framework 与系统签名工具重新实现了分身规划、元数据隔离、更新和可恢复删除流程。
