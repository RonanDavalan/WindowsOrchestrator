# WindowsAutoConfig ⚙️

[🇫🇷 Français](README-fr-FR.md) | [🇺🇸 English](README.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md)

**您的专用 Windows 工作站自动驾驶仪。一次配置，系统即可可靠地自行管理。**

![许可证](https://img.shields.io/badge/Licence-GPLv3-blue.svg)
![PowerShell 版本](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![状态](https://img.shields.io/badge/Statut-Opérationnel-brightgreen.svg)
![操作系统](https://img.shields.io/badge/OS-Windows_10_|_11-informational)
![贡献](https://img.shields.io/badge/Contributions-Bienvenues-brightgreen.svg)

---

## 🎯 WindowsAutoConfig 宣言

### 问题所在
部署和维护一台用于单一任务的 Windows 电脑（如互动信息亭、数字标牌、控制台）是一个持续的挑战。不合时宜的更新、意外的睡眠模式、重启后需要手动重新启动应用程序……每个细节都可能成为故障源，并需要耗费时间的重复人工干预。配置每台工作站是一个重复、耗时且容易出错的过程。

### 解决方案：WindowsAutoConfig
**WindowsAutoConfig** 将任何 Windows 电脑转变为一个可靠且可预测的自动化系统。它是一组本地安装的脚本，负责控制系统配置，确保您的机器全天候 24/7 准确执行您的预期任务。

它像一个永久的监督者，在每次启动和每次登录时应用您的规则，让您无需再手动操作。

## ✨ 主要功能
*   **图形配置向导：** 无需编辑文件即可进行基本设置。
*   **电源管理：** 禁用机器睡眠、显示器睡眠和 Windows 快速启动，以实现最大稳定性。
*   **自动登录 (Auto-Login)：** 管理自动登录，包括与 **Sysinternals AutoLogon** 工具协同工作，以实现安全的密码管理。
*   **Windows 更新控制：** 阻止强制更新和重启干扰您的应用程序。
*   **进程管理器：** 在每个会话中自动启动、监控和重新启动您的主应用程序。
*   **每日计划重启：** 安排每日重启以保持系统新鲜。
*   **重启前操作：** 在计划重启前执行自定义脚本（备份、清理等）。
*   **详细日志记录：** 所有操作都记录在日志文件中，便于诊断。
*   **通知（可选）：** 通过 Gotify 发送状态报告。

---

## 🚀 安装与入门
设置 **WindowsAutoConfig** 是一个简单且有引导的过程。

1.  **下载**或克隆项目到要配置的计算机上。
2.  运行 `1_install.bat`。脚本将引导您完成两个步骤：
    *   **步骤 1：通过图形向导配置。**
        根据您的需要调整选项。最重要的通常是自动登录的用户名和要启动的应用程序。点击 `保存` 以保存。
    *   **步骤 2：安装系统任务。**
        脚本将要求您确认继续。将打开一个 Windows 安全（UAC）窗口。**您必须接受**，以允许脚本创建必要的计划任务。
3.  完成！下次重启时，您的配置将生效。

---

## 🔧 配置
您可以随时通过两种方式调整设置：

### 1. 图形向导（简单方法）
重新运行 `1_install.bat` 以再次打开配置界面。修改您的设置并保存。

### 2. `config.ini` 文件（高级方法）
用文本编辑器打开 `config.ini` 以进行更精细的控制。

#### 关于自动登录和密码的重要说明
出于安全原因，**WindowsAutoConfig 绝不以明文形式管理或存储密码。** 以下是如何有效且安全地配置自动登录：

*   **场景 1：用户帐户没有密码。**
    只需在图形向导或 `config.ini` 文件中的 `AutoLoginUsername` 中输入用户名。

*   **场景 2：用户帐户有密码（推荐方法）。**
    1.  从 Microsoft 下载官方的 **[Sysinternals AutoLogon](https://download.sysinternals.com/files/AutoLogon.zip)** 工具（直接下载链接）。
    2.  运行 AutoLogon 并输入用户名、域和密码。该工具将安全地将密码存储在注册表中。
    3.  在 **WindowsAutoConfig** 的配置中，您现在可以将 `AutoLoginUsername` 字段留空（脚本将检测由 AutoLogon 配置的用户）或填写它以确保。我们的脚本将确保 `AutoAdminLogon` 注册表项已正确启用以完成配置。

#### 高级配置：`PreRebootActionCommand`
这个强大的功能允许您在每日重启前执行脚本。路径可以是：
- **绝对路径：** `C:\Scripts\my_backup.bat`
- **项目相对路径：** `PreReboot.bat`（脚本将在项目根目录中查找此文件）。
- **使用 `%USERPROFILE%`：** `%USERPROFILE%\Desktop\cleanup.ps1`（脚本将智能地将 `%USERPROFILE%` 替换为自动登录用户的配置文件路径）。

---

## 📂 项目结构
```
WindowsAutoConfig/
├── 1_install.bat                # 安装和配置的入口点
├── 2_uninstall.bat              # 卸载的入口点
├── config.ini                   # 中心配置文件
├── config_systeme.ps1           # 机器设置主脚本（在启动时执行）
├── config_utilisateur.ps1       # 用户进程管理主脚本（在登录时执行）
├── PreReboot.bat                # 重启前操作的示例脚本
├── Logs/                        # （自动创建）包含日志文件
└── management/
    ├── firstconfig.ps1          # 图形配置向导的代码
    ├── install.ps1              # 任务安装的技术脚本
    └── uninstall.ps1            # 任务删除的技术脚本
```

---

## ⚙️ 详细运行机制
**WindowsAutoConfig** 的核心在于 Windows 任务计划程序：

1.  **在 Windows 启动时**
    *   `WindowsAutoConfig_SystemStartup` 任务以 `SYSTEM` 权限运行。
    *   `config_systeme.ps1` 脚本读取 `config.ini` 并应用所有机器配置。它还管理重启任务的创建/更新。

2.  **在用户登录时**
    *   `WindowsAutoConfig_UserLogon` 任务运行。
    *   `config_utilisateur.ps1` 脚本读取 `config.ini` 的 `[Process]` 部分，并确保您的主应用程序已正确启动。如果它已经在运行，则首先停止，然后干净地重新启动。

3.  **每日（如果已配置）**
    *   `WindowsAutoConfig_PreRebootAction` 任务执行您的备份/清理脚本。
    *   几分钟后，`WindowsAutoConfig_ScheduledReboot` 任务重新启动计算机。

---

### 🛠️ 诊断工具

该项目包含有用的脚本，可帮助您配置复杂的应用程序。

*   **`management/tools/Find-WindowInfo.ps1`**：如果您需要为新应用程序配置重启前操作，但不知道其窗口的准确标题，此工具非常适合您。启动您的应用程序，然后在 PowerShell 控制台中运行此脚本。它将列出所有可见窗口及其进程名称，从而帮助您找到在 `Close-AppByTitle.ps1` 脚本中使用的准确标题。

---

## 📄 日志记录
为了便于故障排除，所有内容都会被记录。
*   **位置：** 在 `Logs/` 子文件夹中。
*   **文件：** `config_systeme_ps_log.txt` 和 `config_utilisateur_log.txt`。
*   **轮换：** 旧日志会自动存档，以防止它们变得过大。

---

## 🗑️ 卸载
要移除系统：
1.  运行 `2_uninstall.bat`。
2.  **接受权限请求 (UAC)**。
3.  脚本将干净地删除项目创建的所有计划任务。

**注意：** 卸载不会撤销系统更改（例如：睡眠将保持禁用状态），也不会删除项目文件夹。

---

## ❤️ 许可证和贡献
本项目根据 **GPLv3** 许可证分发。完整文本可在 `LICENSE` 文件中找到。

欢迎各种形式的贡献，无论是错误报告、改进建议还是“拉取请求”。
