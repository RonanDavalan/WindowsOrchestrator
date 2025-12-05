# WindowsOrchestrator 1.72

<p align="center">
  <img src="https://img.shields.io/badge/Version-v1.72-2ea44f" alt="Version">
  <img src="https://img.shields.io/badge/License-GPLv3-blue.svg" alt="License">
  <img src="https://img.shields.io/badge/Platform-Windows_10_|_11-0078D6" alt="Supported OS">
  <img src="https://img.shields.io/badge/Architecture-x86_|_x64_|_ARM64-blueviolet" alt="CPU Architecture">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue" alt="PowerShell Version">
  <img src="https://img.shields.io/badge/Type-Portable_App-orange" alt="Portable App">
</p>

**🇺🇸 English** | [🇫🇷 Français](docs/fr-FR/README.md) | [🇩🇪 Deutsch](docs/de-DE/README.md) | [🇪🇸 Español](docs/es-ES/README.md)

## Description

**WindowsOrchestrator** is a PowerShell automation solution designed to transform a standard Windows workstation into an autonomous system ("Kiosk" or "Appliance").

It allows configuring, securing, and orchestrating the operating system's lifecycle. Once configured, it ensures the workstation starts up, opens a session, and launches a business application without any human intervention, while managing daily maintenance (backup, reboot).

## Use Cases and Target Audience

By default, Windows is designed for human interaction (login screen, updates, notifications). WindowsOrchestrator removes these frictions for dedicated uses:

* **Dynamic Display**: Advertising screens, information panels, menu boards.
* **Interactive Kiosks**: Ticketing, ordering kiosks, automated counters.
* **Industrial PCs**: Human-Machine Interfaces (HMI), control automates on production lines.
* **Windows Servers**: Automatic launch of applications requiring persistent interactive sessions.

## Design Philosophy: Modular Orchestrator

WindowsOrchestrator is not a rigid "hardening" script. It is a flexible tool that adapts to your need.

* **Total Flexibility**: No parameter is forced. You can choose to disable Fast Startup without touching Windows Update, or vice versa.
* **Responsibility**: The tool applies strictly what you configure. It is designed for controlled environments where stability takes precedence over constant functional updates.
* **Multi-Context Architecture**:
    * **Standard**: Leaves Windows login screen (Logon UI). Launches application once user logs in manually.
    * **Autologon**: Opens user session automatically without password.

## Technical Philosophy: Native Approach

The orchestrator prioritizes stability and use of native Windows mechanisms to guarantee configurations longevity.

* **Hardware Power Management**: Direct modification of AC/DC power plans via `powercfg.exe`. No activity simulation (mouse/keyboard).
* **Updates via GPO**: Use of `HKLM:\SOFTWARE\Policies` registry keys (Enterprise method) for resistance to Windows Update self-repair mechanisms.
* **Stability by "Cold Boot"**: Disabling Fast Startup (`HiberbootEnabled`) possible to force complete driver and kernel reload at each reboot.
* **Credentials Security (LSA)**: In Autologon mode, password is never stored in plain text. Orchestrator delegates encryption to official **Microsoft Sysinternals Autologon** tool, which stores credentials in Windows LSA (Local Security Authority) secrets.

## Functional Capabilities

### Session Management (Autologon)
* Automated Winlogon registry configuration.
* Integration of official Microsoft Sysinternals Autologon tool.
* Native support for x86, AMD64 and ARM64 architectures.
* Automated tool download and launch for credentials configuration.

### Automatic Launch
* Use of **Task Scheduler** (AtLogon trigger) to guarantee launch with appropriate rights.
* **Console Launch Modes**:
    * *Standard*: Uses default terminal (e.g.: Windows Terminal).
    * *Legacy*: Forces `conhost.exe` use for old script compatibility.
* Option to launch application **minimized** in taskbar.

### Data Backup
* Intelligent backup module executed before reboot.
* **Differential Logic**: Copies only files modified in last 24 hours.
* **Paired Files Support**: Ideal for databases (e.g.: simultaneous copy of `.db`, `.db-wal`, `.db-shm`).
* **Retention Policy**: Automatic old archive purge (default: 30 days).

### System Environment Management
* **Windows Update**: Service blocking and automatic reboot prevention post-update.
* **Fast Startup**: Disabling for guaranteed clean reboots.
* **Power**: Automatic sleep disabling (S3/S4) and screen sleep.
* **OneDrive**: Three management policies (`Block` by GPO, `Close` process, or `Ignore`).

### Task Scheduling
* **Application Closure**: Sends proper closure commands ({ESC}{ESC}x{ENTER} via API) at precise time.
* **System Reboot**: Scheduled complete reboot daily.
* **Backup**: Independent task, executed in parallel with closure.

### Silent Mode
* Installation and uninstallation possible without visible console windows (`-WindowStyle Hidden`).
* **Splash Screen**: Graphical waiting interface with indeterminate progress bar to reassure user.
* **Feedback**: Final notification by MessageBox (`MessageBox`) indicating success or failure.

### Internationalization & Notifications
* **i18n**: Automatic system language detection (Native support: `fr-FR`, `en-US`).
* **Gotify**: Optional module to send execution reports (success/errors) to Gotify server.

## Deployment Procedure

### Prerequisites
* **OS**: Windows 10 or 11 (All editions).
* **Rights**: Administrator access required (for HKLM registry modification and task creation).
* **PowerShell**: Version 5.1 or higher.

### Installation

1. Download and extract project archive.
2. Execute **`Install.bat`** script (accept UAC elevation prompt).
3. **Configuration Assistant** (`firstconfig.ps1`) opens:
    * Enter application launch path.
    * Define daily cycle times (Closure / Backup / Reboot).
    * Enable Autologon if necessary.
    * In "Advanced" tab, configure backup and silent mode.
4. Click **"Save and Close"**.
5. Automatic installation (`install.ps1`) takes over:
    * Scheduled task creation.
    * *If Autologon enabled*: Automatic official tool download and opening of credentials entry window.
6. Click "Yes" to accept Sysinternals license terms.
7. Enter username, domain and password in Autologon window.
8. Click "Enable".

> **Note**: If Autologon mode selected with `UseAutologonAssistant=true`, installer will attempt tool download. If machine has no internet, dialog will prompt to manually select `Autologon.zip` file.

### Uninstallation

1. Execute **`Uninstall.bat`** script.
2. Cleanup script (`uninstall.ps1`) executes:
    * Deletion of all `WindowsOrchestrator-*` scheduled tasks.
    * Windows parameters reset to default (Windows Update, Fast Startup, OneDrive).
    * *If Autologon detected*: Official tool relaunch to allow proper LSA secrets cleanup.
    * Operation report display.

> **Note**: For security, configuration files (`config.ini`) and logs (`Logs/`) are not automatically deleted to allow history trace keeping. Manually delete project folder once operation completed.

## Configuration and Observability

### Configuration File (`config.ini`)
Generated in project root by assistant, pilots entire system.
* `[SystemConfig]`: Global parameters (Session, FastStartup, WindowsUpdate, OneDrive).
* `[Process]`: Application paths, arguments, times, process monitoring.
* `[DatabaseBackup]`: Backup activation, source/destination paths, retention.
* `[Installation]`: Installer behavior (Silent mode, Autologon URL, completion reboot).
* `[Logging]`: Log rotation parameters.
* `[Gotify]`: Push notification configuration.

### Logging
Orchestrator generates detailed logs for each operation.
* **Location**: `Logs/` folder in project root.
* **Files**:
    * `config_systeme_ps_log.txt`: SYSTEM context actions (Startup, background tasks).
    * `config_utilisateur_log.txt`: USER context actions (App launch).
    * `Invoke-DatabaseBackup_log.txt`: Specific backup reports.
* **Rotation**: Automatic old log archiving and deletion. Keeps 7 last files (configurable) to avoid disk saturation.
* **Fallback**: If `Logs/` folder inaccessible, critical errors written to `C:\ProgramData\StartupScriptLogs`.

### Created Scheduled Tasks
Installation registers following tasks in Windows Task Scheduler:
| Task Name | Context | Trigger | Action |
| :-------- | :------ | :------ | :----- |
| `WindowsOrchestrator-SystemStartup` | SYSTEM | System startup | Applies system config (Power, Update...) |
| `WindowsOrchestrator-UserLogon` | User | Session opening | Launches business application |
| `WindowsOrchestrator-SystemBackup` | SYSTEM | Scheduled time | Executes data backup |
| `WindowsOrchestrator-SystemScheduledReboot` | SYSTEM | Scheduled time | Reboots computer |
| `WindowsOrchestrator-User-CloseApp` | User | Scheduled time | Properly closes application |

## Documentation

For more information, consult detailed guides:

📘 **[User Guide](docs/en-US/USER_GUIDE.md)**
*Intended for system administrators and deployment technicians.*
Contains step-by-step procedures, assistant screenshots and troubleshooting guides.

🛠️ **[Developer Guide](docs/en-US/DEVELOPER_GUIDE.md)**
*Intended for integrators and security auditors.*
Details internal architecture, code analysis, LSA security mechanisms and module structure.

## Compliance and Security

* **License**: This project is distributed under **GPLv3** license. See `LICENSE` file for details.
* **Dependencies**:
    * Project is autonomous ("Portable App").
    * Autologon activation downloads official **Microsoft Sysinternals Autologon** tool (subject to its own EULA, which user must accept during installation).
* **Data Security**:
    * WindowsOrchestrator **never stores** any password in plain text in its configuration files.
    * Privileges are compartmentalized: user script cannot modify system parameters.

## Contribution and Support

This project is developed on free time.
* **Bugs**: If you find technical bug, please report via GitHub **Issues**.
* **Contributions**: Pull Requests welcome to improve tool.
