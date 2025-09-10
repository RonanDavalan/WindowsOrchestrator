# Windows 编排器

<p align="center">
  <img src="https://img.shields.io/badge/许可证-GPLv3-blue.svg" alt="许可证">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue" alt="PowerShell 版本">
  <img src="https://img.shields.io/badge/支持-11_种语言-orange.svg" alt="多语言支持">
  <img src="https://img.shields.io/badge/操作系统-Windows_10_|_11-informational" alt="支持的操作系统">
</p>

[🇺🇸 English](README.md) | [🇫🇷 Français](README-fr-FR.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | **🇨🇳 中文** | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

---

该项目可自动化 Windows 工作站，使应用程序可以在无人值守的情况下运行。

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 访问官方主页以获取完整介绍！</strong></a>
</p>

在意外重启（由于断电或事故）后，该项目负责打开 Windows 会话并自动重新启动您的应用程序，从而确保其服务的连续性。它还允许安排每日重启以保持系统稳定性。

所有操作均由安装过程中创建的单个配置文件驱动。

### **安装**

1.  **先决条件（用于自动登录）：** 如果您希望 Windows 会话自动打开，请先使用 **[Sysinternals AutoLogon](https://learn.microsoft.com/zh-cn/sysinternals/downloads/autologon)** 工具保存密码。这是唯一需要的外部配置。
2.  **启动：** 运行 **`1_install.bat`**。图形向导将引导您创建配置文件。然后安装将继续并请求管理员权限（UAC）。

### **使用**

安装后，该项目即可自主运行。要修改配置（更改要启动的应用程序、重启时间等），只需编辑项目目录中的 `config.ini` 文件。

### **卸载**

运行 **`2_uninstall.bat`**。该脚本将删除所有自动化设置，并将主要的 Windows 设置恢复为默认值。

*   **重要提示：** 唯一不会恢复的设置是与电源管理相关的设置（`powercfg`）。
*   包含其所有文件的项目目录将保留在您的磁盘上，可以手动删除。

### **技术文档**

有关架构、每个脚本和所有配置选项的详细说明，请参阅参考文档。

➡️ **[查阅详细技术文档](./docs/zh-CN/KAIFAZHE_ZHINAN.md)**

---
**许可证**：本项目根据 GPLv3 许可证分发。请参阅 `LICENSE` 文件。
