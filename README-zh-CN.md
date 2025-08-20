# Windows Orchestrator

[🇫🇷 法语](README-fr-FR.md) | [🇩🇪 德语](README-de-DE.md) | [🇪🇸 西班牙语](README-es-ES.md) | [🇮🇳 印地语](README-hi-IN.md) | [🇯🇵 日语](README-ja-JP.md) | [🇷🇺 俄语](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 阿拉伯语](README-ar-SA.md) | [🇧🇩 孟加拉语](README-bn-BD.md) | [🇮🇩 印度尼西亚语](README-id-ID.md)

**您的专用 Windows 工作站自动驾驶仪。一次配置，让系统可靠地自我管理。**

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 访问官方主页，了解完整介绍！</strong></a>
</p>

![许可证](https://img.shields.io/badge/Licence-GPLv3-blue.svg)![PowerShell 版本](https://img.shields.io/badge/PowerShell-5.1%2B-blue)![状态](https://img.shields.io/badge/Status-运行中-brightgreen.svg)![操作系统](https://img.shields.io/badge/OS-Windows_10_|_11-informational)![支持](https://img.shields.io/badge/Support-11_种语言-orange.svg)![贡献](https://img.shields.io/badge/Contributions-欢迎-brightgreen.svg)

---

## 我们的使命

想象一个完全可靠和自主的 Windows 工作站。一台您只需配置一次即可完成任务，然后就可以忘记的机器。一个确保您的应用程序**永久运行**，不中断的系统。

这就是 **Windows Orchestrator** 帮助您实现的目标。挑战在于，标准 Windows PC 并非天生为此耐力而设计。它专为人类交互而设计：它会进入睡眠状态，在它认为合适时安装更新，并且在重启后不会自动重新启动应用程序。

**Windows Orchestrator** 是解决方案：一套脚本，充当智能且永久的监督者。它将任何 PC 转换为可靠的自动化设备，确保您的关键应用程序始终运行，无需手动干预。



我们面临的不是一种，而是两种系统性故障：

#### 1. 突然故障：意外中断

场景很简单：一台配置为远程访问的机器和夜间停电。即使 BIOS 设置为自动重启，任务也会失败。Windows 重启但停留在登录屏幕；关键应用程序未重新启动，会话未打开。系统无法访问。

#### 2. 缓慢退化：长期不稳定

更阴险的是 Windows 随时间推移的行为。它被设计为交互式操作系统，并未针对不间断运行的进程进行优化。内存泄漏和性能下降逐渐出现，导致系统不稳定并需要手动重启。

### 答案：原生可靠性层

面对这些挑战，第三方实用程序被证明不足。因此，我们决定**构建我们自己的系统弹性层。**

`Windows Orchestrator` 充当自动驾驶仪，控制操作系统以：

- **确保自动恢复：** 故障后，它保证会话打开和主应用程序的重新启动。
- **保证预防性维护：** 它允许您安排受控的每日重启，并在此之前执行自定义脚本。
- **保护应用程序** 免受 Windows 不合时宜的干扰（更新、睡眠模式...）。

`Windows Orchestrator` 是任何需要 Windows 工作站保持**可靠、稳定且无需持续监控即可运行**的人的必备工具。

---

## 典型用例

*   **数字标牌：** 确保标牌软件在公共屏幕上 24/7 运行。
*   **家庭服务器和物联网：** 从 Windows PC 控制 Plex 服务器、Home Assistant 网关或连接对象。
*   **监控站：** 始终保持监控应用程序（摄像头、网络日志）处于活动状态。
*   **交互式信息亭：** 确保信息亭应用程序在每次重启后自动重新启动。
*   **轻量级自动化：** 持续运行脚本或进程以进行数据挖掘或测试任务。

---

## 主要特点

*   **图形配置向导：** 无需编辑文件即可进行基本设置。
*   **全面多语言支持：** 界面和日志提供 11 种语言，并自动检测系统语言。
*   **电源管理：** 禁用机器睡眠、显示器睡眠和 Windows 快速启动，以实现最大稳定性。
*   **自动登录：** 管理自动登录，包括与 **Sysinternals AutoLogon** 工具协同工作，以实现安全密码管理。
*   **Windows 更新控制：** 防止强制更新和重启中断您的应用程序。
*   **进程管理器：** 自动启动、监控和重新启动您的主应用程序，每次会话。
*   **计划每日重启：** 计划每日重启以保持系统新鲜。
*   **重启前操作：** 在计划重启前执行自定义脚本（备份、清理...）。
*   **详细日志记录：** 所有操作都记录在日志文件中，便于诊断。
*   **通知（可选）：** 通过 Gotify 发送状态报告。

---

## 目标受众和最佳实践

该项目旨在将 PC 转换为可靠的自动化设备，非常适合机器专用于单个应用程序的用例（物联网设备的服务器、数字标牌、监控站等）。不建议将其用于通用办公或日常计算机。

*   **主要 Windows 更新：** 对于重大更新（例如，从 Windows 10 升级到 11），最安全的程序是在更新前**卸载** Windows Orchestrator，然后在更新后**重新安装**它。
*   **企业环境：** 如果您的计算机位于由组策略对象 (GPO) 管理的企业域中，请咨询您的 IT 部门，以确保此脚本所做的修改不会与您组织的策略冲突。

---

## 安装和入门

**语言说明：** 启动脚本（`1_install.bat` 和 `2_uninstall.bat`）以**英语**显示其说明。这是正常的。这些文件充当简单的启动器。一旦图形向导或 PowerShell 脚本接管，界面将自动适应您的操作系统语言。

设置 **Windows Orchestrator** 是一个简单且有指导的过程。

1.  **下载** 或克隆项目到要配置的计算机上。
2.  运行 `1_install.bat`。脚本将引导您完成两个步骤：
    *   **步骤 1：通过图形向导进行配置。**
        根据您的需要调整选项。最重要的通常是自动登录的用户名和要启动的应用程序。单击 `保存` 进行保存。
        
        ![配置向导](assets/screenshot-wizard.png)
        
    *   **步骤 2：系统任务安装。**
        脚本将要求确认继续。将打开一个 Windows 安全 (UAC) 窗口。**您必须接受它**，以允许脚本创建必要的计划任务。
3.  就是这样！下次重启时，您的配置将生效。

---

## 配置
您可以随时通过两种方式调整设置：

### 1. 图形向导（简单方法）
重新运行 `1_install.bat` 以重新打开配置界面。修改您的设置并保存。

### 2. `config.ini` 文件（高级方法）
使用文本编辑器打开 `config.ini` 以进行精细控制。

#### 关于自动登录和密码的重要说明
出于安全原因，**Windows Orchestrator 绝不管理或以纯文本形式存储密码。** 以下是有效且安全地配置自动登录的方法：

*   **场景 1：用户帐户没有密码。**
    只需在图形向导中或在 `config.ini` 文件中的 `AutoLoginUsername` 中输入用户名。

*   **场景 2：用户帐户有密码（推荐方法）。**
    1.  从 Microsoft 下载官方 **[Sysinternals AutoLogon](https://download.sysinternals.com/files/AutoLogon.zip)** 工具（直接下载链接）。
    2.  启动 AutoLogon 并输入用户名、域和密码。此工具将安全地将密码存储在注册表中。
    3.  在 **Windows Orchestrator** 配置中，您现在可以将 `AutoLoginUsername` 字段留空（脚本将通过读取相应的注册表项来检测 AutoLogon 配置的用户）或填写它以确保。我们的脚本将确保正确启用 `AutoAdminLogon` 注册表项以完成配置。

#### 高级配置：`PreRebootActionCommand`
此强大功能允许您在每日重启前执行脚本。路径可以是：
- **绝对路径：** `C:\Scripts\my_backup.bat`
- **相对于项目：** `PreReboot.bat`（脚本将在项目根目录中查找此文件）。
- **使用 `%USERPROFILE%`：** `%USERPROFILE%\Desktop\cleanup.ps1`（脚本将智能地将 `%USERPROFILE%` 替换为自动登录用户配置文件的路径）。

---

## 项目结构
```
WindowsOrchestrator/
├── 1_install.bat                # 安装和配置的入口点
├── 2_uninstall.bat              # 卸载的入口点
├── config.ini                   # 中央配置文件
├── config_systeme.ps1           # 机器设置的主脚本（在启动时运行）
├── config_utilisateur.ps1       # 用户进程管理的主脚本（在登录时运行）
├── LaunchApp.bat                # (示例) 您的主应用程序的便携式启动器
├── PreReboot.bat                # 重启前操作的示例脚本
├── Logs/                        # (自动创建) 包含日志文件
├── i18n/                        # 包含所有翻译文件
│   ├── en-US/strings.psd1
│   └── ... (其他语言)
└── management/
    ├── defaults/default_config.ini # 初始配置模板
    ├── tools/                   # 诊断工具
    │   └── Find-WindowInfo.ps1
    ├── firstconfig.ps1          # 图形配置向导代码
    ├── install.ps1              # 任务安装的技术脚本
    └── uninstall.ps1            # 任务删除的技术脚本
```

---

## 详细操作
**Windows Orchestrator** 的核心依赖于 Windows 任务计划程序：

1.  **Windows 启动时**
    *   `WindowsOrchestrator_SystemStartup` 任务以 `SYSTEM` 权限运行。
    *   `config_systeme.ps1` 脚本读取 `config.ini` 并应用所有机器配置。它还管理重启任务的创建/更新。

2.  **用户登录时**
    *   `WindowsOrchestrator_UserLogon` 任务运行。
    *   `config_utilisateur.ps1` 脚本读取 `config.ini` 的 `[Process]` 部分，并确保您的主应用程序已正确启动。如果它已经在运行，则首先停止然后干净地重新启动。

3.  **每日（如果配置）**
    *   `WindowsOrchestrator_PreRebootAction` 任务执行您的备份/清理脚本。
    *   几分钟后，`WindowsOrchestrator_ScheduledReboot` 任务重启计算机。

---

### 诊断和开发工具

该项目包含有用的脚本，可帮助您配置和维护项目。

*   **`management/tools/Find-WindowInfo.ps1`**：如果您不知道应用程序窗口的确切标题（例如，要在 `Close-AppByTitle.ps1` 中配置它），请运行此脚本。它将列出所有可见窗口及其进程名称，帮助您找到精确的信息。
*   **`Fix-Encoding.ps1`**：如果您修改脚本，此工具可确保它们以正确的编码（带 BOM 的 UTF-8）保存，以与 PowerShell 5.1 和国际字符完美兼容。

---

## 日志记录
为了便于故障排除，所有内容都已记录。
*   **位置：** 在 `Logs/` 子文件夹中。
*   **文件：** `config_systeme_ps_log.txt` 和 `config_utilisateur_log.txt`。
*   **轮换：** 旧日志会自动存档，以防止它们变得太大。

---

## 卸载
要删除系统：
1.  运行 `2_uninstall.bat`。
2.  **接受权限请求 (UAC)**。
3.  脚本将干净地删除所有计划任务并恢复主系统设置。

**关于可逆性：** 卸载不仅仅是删除计划任务。它还会将主要系统设置恢复到默认状态，为您提供一个干净的系统：
*   Windows 更新重新启用。
*   快速启动重新启用。
*   阻止 OneDrive 的策略被删除。
*   脚本将提供禁用自动登录的选项。

您的系统因此恢复为标准工作站，没有残留修改。

---

## 许可证和贡献
本项目根据 **GPLv3** 许可证分发。完整文本可在 `LICENSE` 文件中找到。

欢迎以错误报告、改进建议或拉取请求的形式进行贡献。