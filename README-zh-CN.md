# WindowsAutoConfig ⚙️

[🇺🇸 English](README.md) | [🇫🇷 Français](README-fr-FR.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

**您的专用 Windows 工作站自动驾驶仪。一次配置，系统即可可靠地自行管理。**

![许可证](https://img.shields.io/badge/Licence-GPLv3-blue.svg)![PowerShell 版本](https://img.shields.io/badge/PowerShell-5.1%2B-blue)![状态](https://img.shields.io/badge/Statut-Opérationnel-brightgreen.svg)![操作系统](https://img.shields.io/badge/OS-Windows_10_|_11-informational)![支持](https://img.shields.io/badge/Support-11_Langues-orange.svg)![贡献](https://img.shields.io/badge/Contributions-Bienvenues-brightgreen.svg)

---

## 🎯 我们的使命

想象一下一个完全可靠和自主的 Windows 工作站。一台您只需为其任务配置一次的机器——无论是控制连接的设备、驱动数字显示器，还是作为监控站——然后您就可以忘记它了。一个确保您的应用程序**永久运行**而不会中断的系统。

这就是 **WindowsAutoConfig** 帮助您实现的目标。挑战在于，标准的 Windows 电脑并非天生就为这种耐用性而设计。它是为人机交互而构建的：它会为了省电而休眠，会在它认为合适的时候安装更新，并且在重新启动后不会自动重新启动应用程序。

**WindowsAutoConfig** 就是解决方案：一套作为智能和永久监督者的脚本。它将任何电脑转变为可靠的自动机，确保您的关键应用程序始终在运行，无需人工干预。

### 超越界面：直接系统控制

WindowsAutoConfig 充当一个高级控制面板，使那些在标准 Windows 用户界面中不可用或难以管理的强大配置变得易于访问。

*   **完全控制 Windows 更新：** 脚本不是简单地“暂停”更新，而是修改系统策略以停止自动机制，让您重新控制何时安装更新。
*   **可靠的电源设置：** 脚本不仅将睡眠设置为“从不”，它还确保此设置在每次启动时都重新应用，使您的配置能够抵抗不必要的更改。
*   **访问管理员级别的设置：** 诸如通过系统策略禁用OneDrive之类的功能，通常深藏在组策略编辑器中（在Windows家庭版中不可用）。此脚本使每个人都可以使用它们。

## ✨ 主要功能
*   **图形配置向导：** 无需编辑文件即可进行基本设置。
*   **全面的多语言支持：** 界面和日志支持11种语言，并能自动检测系统语言。
*   **电源管理：** 禁用机器睡眠、显示器睡眠和 Windows 快速启动，以实现最大稳定性。
*   **自动登录 (Auto-Login)：** 管理自动登录，包括与 **Sysinternals AutoLogon** 工具协同工作，以实现安全的密码管理。
*   **Windows 更新控制：** 阻止强制更新和重启干扰您的应用程序。
*   **进程管理器：** 在每个会话中自动启动、监控和重新启动您的主应用程序。
*   **每日计划重启：** 安排每日重启以保持系统新鲜。
*   **重启前操作：** 在计划重启前执行自定义脚本（备份、清理等）。
*   **详细日志记录：** 所有操作都记录在日志文件中，便于诊断。
*   **通知（可选）：** 通过 Gotify 发送状态报告。

---

## 🎯 目标受众与最佳实践

该项目旨在将一台 PC 转变为可靠的自动化设备，非常适用于机器专用于单个应用程序的用例（物联网设备的服务器、数字标牌、监控站等）。不建议用于通用办公或日常使用的计算机。

*   **主要的 Windows 更新：** 对于重要的更新（例如从 Windows 10 升级到 11），最安全的过程是在更新前**卸载** WindowsAutoConfig，然后在更新后**重新安装**。
*   **企业环境：** 如果您的计算机位于由组策略对象 (GPO) 管理的企业域中，请与您的 IT 部门核实，以确保此脚本所做的修改与您组织的策略不冲突。

---

## 🚀 安装与入门

**语言注意：** 启动脚本（`1_install.bat` 和 `2_uninstall.bat`）以**英语**显示其说明。这是正常的。这些文件充当简单的启动器。一旦图形向导或 PowerShell 脚本接管，界面将自动适应您的操作系统的语言。

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
    3.  在 **WindowsAutoConfig** 的配置中，您现在可以将 `AutoLoginUsername` 字段留空（脚本将通过读取相应的注册表项来检测由 AutoLogon 配置的用户）或填写它以确保。我们的脚本将确保 `AutoAdminLogon` 注册表项已正确启用以完成配置。

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
├── LaunchApp.bat                # (示例) 您的主应用程序的便携式启动器
├── PreReboot.bat                # 重启前操作的示例脚本
├── Logs/                        # （自动创建）包含日志文件
├── i18n/                        # 包含所有翻译文件
│   ├── zh-CN/strings.psd1
│   └── ... (其他语言)
└── management/
    ├── defaults/default_config.ini # 初始配置模板
    ├── tools/                   # 诊断工具
    │   └── Find-WindowInfo.ps1
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

### 🛠️ 诊断和开发工具

该项目包含有用的脚本，可帮助您配置和维护项目。

*   **`management/tools/Find-WindowInfo.ps1`**：如果您不知道应用程序窗口的确切标题（例如，在 `Close-AppByTitle.ps1` 中配置它），请运行此脚本。它将列出所有可见窗口及其进程名称，从而帮助您找到准确的信息。
*   **`Fix-Encoding.ps1`**：如果您修改脚本，此工具可确保它们以正确的编码（带BOM的UTF-8）保存，以与PowerShell 5.1和国际字符完美兼容。

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
3.  脚本将干净地删除所有计划任务并恢复主要的系统设置。

**关于可逆性的说明：** 卸载不仅仅是删除计划任务。它还会将主要的系统设置恢复到其默认状态，以便为您提供一个干净的系统：
*   Windows 更新被重新启用。
*   快速启动被重新启用。
*   阻止 OneDrive 的策略被删除。
*   脚本将提议禁用自动登录。

因此，您的系统将恢复为标准工作站，没有任何残留的修改。

---

## ❤️ 许可证和贡献
本项目根据 **GPLv3** 许可证分发。完整文本可在 `LICENSE` 文件中找到。

欢迎各种形式的贡献，无论是错误报告、改进建议还是“拉取请求”。