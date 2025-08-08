# WindowsAutoConfig ⚙️

[🇫🇷 Français](README-fr-FR.md) | [🇺🇸 English](README.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md)

**Your autopilot for dedicated Windows workstations. Configure once, and let the system reliably manage itself.**

![License](https://img.shields.io/badge/Licence-GPLv3-blue.svg)
![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![Status](https://img.shields.io/badge/Statut-Opérationnel-brightgreen.svg)
![OS](https://img.shields.io/badge/OS-Windows_10_|_11-informational)
![Contributions](https://img.shields.io/badge/Contributions-Bienvenues-brightgreen.svg)

---

## 🎯 The WindowsAutoConfig Manifesto

### The Problem
Deploying and maintaining a Windows computer for a single task (interactive kiosk, digital signage, command post) is a constant challenge. Untimely updates, unexpected sleep modes, the need to manually restart an application after a reboot... Every detail can become a source of failure and require costly manual intervention. Configuring each workstation is a repetitive, lengthy, and error-prone process.

### The Solution: WindowsAutoConfig
**WindowsAutoConfig** transforms any Windows PC into a reliable and predictable automaton. It's a set of scripts that you install locally and which takes control of the system configuration to ensure your machine does exactly what you expect it to do, 24/7.

It acts as a permanent supervisor, applying your rules at every startup and every login, so you no longer have to.

## ✨ Key Features
*   **Graphical Configuration Wizard:** No need to edit files for basic settings.
*   **Power Management:** Disable machine sleep, display sleep, and Windows Fast Startup for maximum stability.
*   **Automatic Login (Auto-Login):** Manages auto-login, including in synergy with the **Sysinternals AutoLogon** tool for secure password management.
*   **Windows Update Control:** Prevent forced updates and reboots from disrupting your application.
*   **Process Manager:** Automatically launches, monitors, and relaunches your main application with each session.
*   **Scheduled Daily Reboot:** Schedule a daily reboot to maintain system freshness.
*   **Pre-Reboot Action:** Execute a custom script (backup, cleanup...) before the scheduled reboot.
*   **Detailed Logging:** All actions are recorded in log files for easy diagnosis.
*   **Notifications (Optional):** Send status reports via Gotify.

---

## 🚀 Installation and Getting Started
Setting up **WindowsAutoConfig** is a simple and guided process.

1.  **Download** or clone the project onto the computer to be configured.
2.  Run `1_install.bat`. The script will guide you through two steps:
    *   **Step 1: Configuration via the Graphical Wizard.**
        Adjust the options according to your needs. The most important ones are usually the username for automatic login and the application to launch. Click `Save` to save.
    *   **Step 2: System Tasks Installation.**
        The script will ask for confirmation to continue. A Windows security (UAC) window will open. **You must accept it** to allow the script to create the necessary scheduled tasks.
3.  That's it! Upon the next reboot, your configurations will be applied.

---

## 🔧 Configuration
You can adjust settings at any time in two ways:

### 1. Graphical Wizard (Simple method)
Rerun `1_install.bat` to reopen the configuration interface. Modify your settings and save.

### 2. `config.ini` File (Advanced method)
Open `config.ini` with a text editor for granular control.

#### Important Note on Auto-Login and Passwords
For security reasons, **WindowsAutoConfig never manages or stores passwords in plain text.** Here's how to configure auto-login effectively and securely:

*   **Scenario 1: The user account has no password.**
    Simply enter the username in the graphical wizard or in `AutoLoginUsername` in the `config.ini` file.

*   **Scenario 2: The user account has a password (Recommended method).**
    1.  Download the official **[Sysinternals AutoLogon](https://download.sysinternals.com/files/AutoLogon.zip)** tool from Microsoft (direct download link).
    2.  Launch AutoLogon and enter the username, domain, and password. This tool will securely store the password in the Registry.
    3.  In the **WindowsAutoConfig** configuration, you can now leave the `AutoLoginUsername` field empty (the script will detect the user configured by AutoLogon) or fill it in to be sure. Our script will ensure that the `AutoAdminLogon` Registry key is properly enabled to finalize the configuration.

#### Advanced Configuration: `PreRebootActionCommand`
This powerful feature allows you to execute a script before the daily reboot. The path can be:
- **Absolute:** `C:\Scripts\my_backup.bat`
- **Relative to the project:** `PreReboot.bat` (the script will look for this file at the root of the project).
- **Using `%USERPROFILE%`:** `%USERPROFILE%\Desktop\cleanup.ps1` (the script will intelligently replace `%USERPROFILE%` with the path to the auto-login user's profile).

---

## 📂 Project Structure
```
WindowsAutoConfig/
├── 1_install.bat                # Entry point for installation and configuration
├── 2_uninstall.bat              # Entry point for uninstallation
├── config.ini                   # Central configuration file
├── config_systeme.ps1           # Main script for machine settings (runs at startup)
├── config_utilisateur.ps1       # Main script for user process management (runs at login)
├── PreReboot.bat                # Example script for the pre-reboot action
├── Logs/                        # (Automatically created) Contains log files
└── management/
    ├── firstconfig.ps1          # The graphical configuration wizard code
    ├── install.ps1              # The technical script for task installation
    └── uninstall.ps1            # The technical script for task deletion
```

---

## ⚙️ Detailed Operation
The core of **WindowsAutoConfig** relies on the Windows Task Scheduler:

1.  **At Windows Startup**
    *   The `WindowsAutoConfig_SystemStartup` task runs with `SYSTEM` privileges.
    *   The `config_systeme.ps1` script reads `config.ini` and applies all machine configurations. It also manages the creation/update of reboot tasks.

2.  **At User Login**
    *   The `WindowsAutoConfig_UserLogon` task runs.
    *   The `config_utilisateur.ps1` script reads the `[Process]` section of `config.ini` and ensures that your main application is properly launched. If it was already running, it is first stopped then cleanly relaunched.

3.  **Daily (If configured)**
    *   The `WindowsAutoConfig_PreRebootAction` task executes your backup/cleanup script.
    *   A few minutes later, the `WindowsAutoConfig_ScheduledReboot` task reboots the computer.

---

### 🛠️ Diagnostic Tools

The project includes useful scripts to help you configure complex applications.

*   **`management/tools/Find-WindowInfo.ps1`**: If you need to configure the pre-reboot action for a new application and you don't know the exact title of its window, this tool is for you. Launch your application, then run this script in a PowerShell console. It will list all visible windows and their process names, allowing you to find the exact title to use in the `Close-AppByTitle.ps1` script.

---

## 📄 Logging
For easy troubleshooting, everything is logged.
*   **Location:** In the `Logs/` subfolder.
*   **Files:** `config_systeme_ps_log.txt` and `config_utilisateur_log.txt`.
*   **Rotation:** Old logs are automatically archived to prevent them from becoming too large.

---

## 🗑️ Uninstallation
To remove the system:
1.  Run `2_uninstall.bat`.
2.  **Accept the privilege request (UAC)**.
3.  The script will cleanly remove all scheduled tasks created by the project.

**Note:** Uninstallation does not undo system changes (e.g., sleep will remain disabled) and does not delete the project folder.

---

## ❤️ License and Contributions
This project is distributed under the **GPLv3** license. The full text is available in the `LICENSE` file.

Contributions, whether in the form of bug reports, improvement suggestions, or pull requests, are welcome.
