# Windows 编排器

[🇺🇸 English](README.md) | [🇫🇷 Français](README-fr-FR.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

Windows 编排器是一组利用 Windows 计划任务来执行 PowerShell (`.ps1`) 脚本的脚本集合。一个图形化助手 (`firstconfig.ps1`) 允许用户生成一个 `config.ini` 配置文件。主脚本 (`config_systeme.ps1`, `config_utilisateur.ps1`) 读取此文件以执行特定操作：
*   修改 Windows 注册表项。
*   执行系统命令 (`powercfg`, `shutdown`)。
*   管理 Windows 服务（更改启动类型并停止 `wuauserv` 服务）。
*   启动或停止用户定义的应用程序进程。
*   通过 `Invoke-RestMethod` 命令向 Gotify 通知服务发送 HTTP POST 请求。

这些脚本会检测用户的操作系统语言，并从位于 `i18n` 目录下的 `.psd1` 文件中加载字符串（用于日志、图形界面和通知）。

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 访问官方主页以获取完整介绍！</strong></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/许可证-GPLv3-blue.svg" alt="许可证">
  <img src="https://img.shields.io/badge/PowerShell_版本-5.1%2B-blue" alt="PowerShell 版本">
  <img src="https://img.shields.io/badge/状态-运行中-brightgreen.svg" alt="状态">
  <img src="https://img.shields.io/badge/操作系统-Windows_10_|_11-informational" alt="操作系统">
  <img src="https://img.shields.io/badge/支持-11_种语言-orange.svg" alt="支持">
  <img src="https://img.shields.io/badge/贡献-欢迎-brightgreen.svg" alt="贡献">
</p>

---

## 脚本操作

`1_install.bat` 脚本执行 `management\install.ps1`，后者会创建两个主要的计划任务。
*   第一个任务 **`WindowsOrchestrator-SystemStartup`**，在 Windows 启动时执行 `config_systeme.ps1`。
*   第二个任务 **`WindowsOrchestrator-UserLogon`**，在用户登录时执行 `config_utilisateur.ps1`。

根据 `config.ini` 文件中的设置，脚本会执行以下操作：

*   **自动登录管理：**
    *   `脚本操作：` 脚本将值 `1` 写入注册表项 `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\AutoAdminLogon`。
    *   `用户操作：` 为使此功能生效，用户必须事先在注册表中保存密码。脚本不处理此信息。**Sysinternals AutoLogon** 实用程序是一个可以执行此操作的外部工具。

*   **电源设置修改：**
    *   执行 `powercfg /change standby-timeout-ac 0` 和 `powercfg /change hibernate-timeout-ac 0` 命令以禁用睡眠模式。
    *   执行 `powercfg /change monitor-timeout-ac 0` 命令以禁用屏幕关闭。
    *   将值 `0` 写入注册表项 `HiberbootEnabled` 以禁用快速启动。

*   **Windows 更新管理：**
    *   将值 `1` 写入注册表项 `NoAutoUpdate` 和 `NoAutoRebootWithLoggedOnUsers`。
    *   将 Windows 服务 `wuauserv` 的启动类型更改为 `Disabled`（禁用），并对其执行 `Stop-Service` 命令。

*   **计划每日重启：**
    *   创建一个名为 `WindowsOrchestrator-SystemScheduledReboot` 的计划任务，在设定的时间执行 `shutdown.exe /r /f /t 60`。
    *   创建一个名为 `WindowsOrchestrator-SystemPreRebootAction` 的计划任务，在重启前执行用户定义的命令。

*   **操作日志记录：**
    *   将带时间戳的行写入位于 `Logs` 文件夹中的 `.txt` 文件。
    *   一个 `Rotate-LogFile` 函数会重命名并归档现有的日志文件。要保留的文件数量由 `config.ini` 中的 `MaxSystemLogsToKeep` 和 `MaxUserLogsToKeep` 键定义。

*   **发送 Gotify 通知：**
    *   如果 `config.ini` 中的 `EnableGotify` 键设置为 `true`，脚本会向指定的 URL 发送一个 HTTP POST 请求。
    *   该请求包含一个带有标题和消息的 JSON 负载。消息内容是已执行操作和遇到错误的列表。

## 先决条件

- **操作系统**：Windows 10 或 Windows 11。源代码中包含针对 PowerShell 脚本的 `#Requires -Version 5.1` 指令。
- **权限**：用户在执行 `1_install.bat` 和 `2_uninstall.bat` 时必须接受权限提升请求 (UAC)。此操作是必需的，以便允许脚本创建计划任务和修改系统级注册表项。
- **自动登录 (Auto-Login)**：如果用户启用此选项，他必须使用像 **Microsoft Sysinternals AutoLogon** 这样的外部工具在注册表中保存其密码。

## 安装与首次配置

用户执行 **`1_install.bat`** 文件。

1.  **配置 (`firstconfig.ps1`)**
    *   `management\firstconfig.ps1` 脚本运行并显示一个图形界面。
    *   如果 `config.ini` 文件不存在，将根据模板 `management\defaults\default_config.ini` 创建它。
    *   如果文件已存在，脚本会询问用户是否希望用模板替换它。
    *   用户输入参数。点击“保存并关闭”后，脚本会将值写入 `config.ini`。

2.  **任务安装 (`install.ps1`)**
    *   关闭助手后，`1_install.bat` 会请求权限提升并执行 `management\install.ps1`。
    *   `install.ps1` 脚本创建两个计划任务：
        *   **`WindowsOrchestrator-SystemStartup`**：在 Windows 启动时，使用 `NT AUTHORITY\SYSTEM` 账户执行 `config_systeme.ps1`。
        *   **`WindowsOrchestrator-UserLogon`**：在启动安装的用户的会话打开时，执行 `config_utilisateur.ps1`。
    *   为了无需等待重启即可应用配置，`install.ps1` 会在过程结束时依次执行一次 `config_systeme.ps1` 和 `config_utilisateur.ps1`。

## 使用与安装后配置

安装后的任何配置修改都通过 `config.ini` 文件进行。

### 1. 手动修改 `config.ini` 文件

*   **用户操作：** 用户使用文本编辑器打开 `config.ini` 文件并修改所需的值。
*   **脚本操作：**
    *   `[SystemConfig]` 部分的修改将在**下次计算机重启时**由 `config_systeme.ps1` 读取并应用。
    *   `[Process]` 部分的修改将在**下次用户登录时**由 `config_utilisateur.ps1` 读取并应用。

### 2. 使用图形助手

*   **用户操作：** 用户再次执行 `1_install.bat`。图形界面将会打开，并预先填充 `config.ini` 的当前值。用户修改设置并点击“保存并关闭”。
*   **脚本操作：** `firstconfig.ps1` 脚本将新值写入 `config.ini`。
*   **使用场景：** 关闭助手后，命令提示符会提议继续进行任务安装。用户可以关闭此窗口，仅更新配置。

## 卸载

用户执行 **`2_uninstall.bat`** 文件。该文件在请求权限提升 (UAC) 后执行 `management\uninstall.ps1`。

`uninstall.ps1` 脚本执行以下操作：

1.  **自动登录：** 脚本会显示一个提示，询问是否应禁用自动登录。如果用户回答 `o` (是)，脚本会将值 `0` 写入注册表项 `AutoAdminLogon`。
2.  **恢复部分系统设置：**
    *   **更新：** 将注册表值 `NoAutoUpdate` 设置为 `0`，并将 `wuauserv` 服务的启动类型配置为 `Automatic`（自动）。
    *   **快速启动：** 将注册表值 `HiberbootEnabled` 设置为 `1`。
    *   **OneDrive：** 删除注册表值 `DisableFileSyncNGSC`。
3.  **删除计划任务：** 脚本会搜索并删除 `WindowsOrchestrator-SystemStartup`, `WindowsOrchestrator-UserLogon`, `WindowsOrchestrator-SystemScheduledReboot` 和 `WindowsOrchestrator-SystemPreRebootAction` 任务。

### 关于恢复设置的说明

**卸载脚本不会恢复**通过 `powercfg` 命令修改的**电源设置**。
*   **对用户的影响：** 如果计算机或屏幕的睡眠模式已被脚本禁用，卸载后它将保持禁用状态。
*   **用户所需操作：** 要重新启用睡眠模式，用户必须在 Windows 的“电源和睡眠设置”中手动重新配置这些选项。

卸载过程**不会删除任何文件**。项目目录及其内容将保留在磁盘上。

## 项目结构

```
WindowsOrchestrator/
├── 1_install.bat                # 运行图形配置界面，然后安装任务。
├── 2_uninstall.bat              # 运行卸载脚本。
├── Close-App.bat                # 运行 PowerShell 脚本 Close-AppByTitle.ps1。
├── Close-AppByTitle.ps1         # 通过窗口标题查找窗口并向其发送按键序列的脚本。
├── config.ini                   # 由主脚本读取的配置文件。
├── config_systeme.ps1           # 用于机器设置的脚本，在启动时执行。
├── config_utilisateur.ps1       # 用于进程管理的脚本，在登录时执行。
├── Fix-Encoding.ps1             # 将脚本文件转换为 UTF-8 with BOM 编码的工具。
├── LaunchApp.bat                # 用于启动外部应用程序的示例批处理脚本。
├── List-VisibleWindows.ps1      # 列出可见窗口及其进程的实用工具。
├── i18n/
│   ├── en-US/
│   │   └── strings.psd1         # 英语字符串文件。
│   └── ... (其他语言)
└── management/
    ├── firstconfig.ps1          # 显示图形配置助手。
    ├── install.ps1              # 创建计划任务并执行一次脚本。
    ├── uninstall.ps1            # 删除任务并恢复系统设置。
    └── defaults/
        └── default_config.ini   # 用于创建初始 config.ini 文件的模板。
```

## 技术原理

*   **原生命令**：项目仅使用 Windows 和 PowerShell 的原生命令。无需安装任何外部依赖。
*   **系统库**：与系统的高级交互仅依赖于 Windows 内置的库（例如：`user32.dll`）。

## 关键文件说明

### `1_install.bat`
此批处理文件是安装过程的入口点。它执行 `management\firstconfig.ps1` 进行配置，然后以提升的权限执行 `management\install.ps1`。

### `2_uninstall.bat`
此批处理文件是卸载过程的入口点。它以提升的权限执行 `management\uninstall.ps1`。

### `config.ini`
这是中央配置文件。它包含由 `config_systeme.ps1` 和 `config_utilisateur.ps1` 脚本读取的指令（键和值），以确定要执行哪些操作。

### `config_systeme.ps1`
此脚本由计划任务在计算机启动时执行，读取 `config.ini` 文件的 `[SystemConfig]` 部分。它通过修改 Windows 注册表、执行系统命令 (`powercfg`) 和管理服务 (`wuauserv`) 来应用设置。

### `config_utilisateur.ps1`
此脚本由计划任务在用户登录时执行，读取 `config.ini` 文件的 `[Process]` 部分。其作用是停止目标进程的任何现有实例，然后使用提供的参数重新启动它。

### `management\firstconfig.ps1`
此 PowerShell 脚本显示一个图形界面，用于读取和写入 `config.ini` 文件中的参数。

### `management\install.ps1`
此脚本包含创建 `WindowsOrchestrator-SystemStartup` 和 `WindowsOrchestrator-UserLogon` 计划任务的逻辑。

### `management\uninstall.ps1`
此脚本包含删除计划任务并将系统注册表项恢复到其默认值的逻辑。

## 通过计划任务进行管理

自动化依赖于 Windows 任务计划程序 (`taskschd.msc`)。脚本会创建以下任务：

*   **`WindowsOrchestrator-SystemStartup`**：在电脑启动时触发并执行 `config_systeme.ps1`。
*   **`WindowsOrchestrator-UserLogon`**：在用户登录时触发并执行 `config_utilisateur.ps1`。
*   **`WindowsOrchestrator-SystemScheduledReboot`**：如果 `config.ini` 中定义了 `ScheduledRebootTime`，则由 `config_systeme.ps1` 创建。
*   **`WindowsOrchestrator-SystemPreRebootAction`**：如果 `config.ini` 中定义了 `PreRebootActionCommand`，则由 `config_systeme.ps1` 创建。

**重要提示**：通过任务计划程序手动删除这些任务会停止自动化，但不会恢复系统设置。用户必须使用 `2_uninstall.bat` 进行完整且受控的卸载。

## 许可证与贡献

本项目根据 **GPLv3** 许可证分发。完整文本可在 `LICENSE` 文件中找到。

欢迎各种贡献，无论是错误报告、改进建议还是拉取请求。
