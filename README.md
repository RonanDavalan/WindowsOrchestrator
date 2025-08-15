# WindowsAutoConfig ⚙️

[🇫🇷 Français](README-fr-FR.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md)

**Your autopilot for dedicated Windows workstations. Configure once, and let the system reliably manage itself.**

![License](https://img.shields.io/badge/Licence-GPLv3-blue.svg)![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1%2B-blue)![Status](https://img.shields.io/badge/Statut-Opérationnel-brightgreen.svg)![OS](https://img.shields.io/badge/OS-Windows_10_|_11-informational)![Support](https://img.shields.io/badge/Support-11_Langues-orange.svg)![Contributions](https://img.shields.io/badge/Contributions-Bienvenues-brightgreen.svg)

---

## 🎯 Our Mission

Imagine a perfectly reliable and autonomous Windows workstation. A machine that you configure once for its mission—whether it's controlling a connected device, powering a digital display, or serving as a monitoring station—and can then forget about. A system that ensures your application remains **permanently operational**, without interruption.

This is the goal that **WindowsAutoConfig** helps you achieve. The challenge is that a standard Windows PC is not natively designed for this kind of endurance. It's built for human interaction: it goes to sleep to save power, installs updates when it sees fit, and doesn't automatically restart an application after a reboot.

**WindowsAutoConfig** is the solution: a set of scripts that acts as an intelligent and permanent supervisor. It transforms any PC into a reliable automaton, ensuring that your critical application is always operational, without manual intervention.

### Beyond the Interface: Direct System Control

WindowsAutoConfig acts as an advanced control panel, making powerful configurations accessible that are either unavailable or difficult to manage through the standard Windows UI.

*   **Full Control Over Windows Update:** Instead of just "pausing" updates, the script modifies system policies to halt the automatic mechanism, giving you back control over when updates are installed.
*   **Reliable Power Settings:** The script doesn't just set sleep to "Never"; it ensures this setting is reapplied at every boot, making your configuration resilient to unwanted changes.
*   **Access to Administrator-Level Settings:** Features like disabling OneDrive via system policy are actions usually buried in the Group Policy Editor (unavailable on Windows Home). This script makes them accessible to everyone.

## ✨ Key Features
*   **Graphical Configuration Wizard:** No need to edit files for basic settings.
*   **Full Multilingual Support:** Interface and logs available in 11 languages, with automatic detection of the system's language.
*   **Power Management:** Disable machine sleep, display sleep, and Windows Fast Startup for maximum stability.
*   **Automatic Login (Auto-Login):** Manages auto-login, including in synergy with the **Sysinternals AutoLogon** tool for secure password management.
*   **Windows Update Control:** Prevent forced updates and reboots from disrupting your application.
*   **Process Manager:** Automatically launches, monitors, and relaunches your main application with each session.
*   **Scheduled Daily Reboot:** Schedule a daily reboot to maintain system freshness.
*   **Pre-Reboot Action:** Execute a custom script (backup, cleanup...) before the scheduled reboot.
*   **Detailed Logging:** All actions are recorded in log files for easy diagnosis.
*   **Notifications (Optional):** Send status reports via Gotify.

---

## 🎯 Target Audience and Best Practices

This project is designed to turn a PC into a reliable automaton, ideal for use cases where the machine is dedicated to a single application (server for an IoT device, digital signage, monitoring station, etc.). It is not recommended for a general-purpose office or everyday computer.

*   **Major Windows Updates:** For significant updates (e.g., upgrading from Windows 10 to 11), the safest procedure is to **uninstall** WindowsAutoConfig before the update, then **reinstall** it afterward.
*   **Corporate Environments:** If your computer is in a corporate domain managed by Group Policy Objects (GPOs), check with your IT department to ensure the modifications made by this script do not conflict with your organization's policies.

---

## 🚀 Installation and Getting Started

**Language Note:** The launch scripts (`1_install.bat` and `2_uninstall.bat`) display their instructions in **English**. This is normal. These files act as simple launchers. As soon as the graphical wizard or the PowerShell scripts take over, the interface will automatically adapt to your operating system's language.

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
    3.  In the **WindowsAutoConfig** configuration, you can now leave the `AutoLoginUsername` field empty (the script will detect the user configured by AutoLogon by reading the corresponding Registry key) or fill it in to be sure. Our script will ensure that the `AutoAdminLogon` Registry key is properly enabled to finalize the configuration.

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
├── LaunchApp.bat                # (Example) Portable launcher for your main application
├── PreReboot.bat                # Example script for the pre-reboot action
├── Logs/                        # (Automatically created) Contains log files
├── i18n/                        # Contains all translation files
│   ├── en-US/strings.psd1
│   └── ... (other languages)
└── management/
    ├── defaults/default_config.ini # Initial configuration template
    ├── tools/                   # Diagnostic tools
    │   └── Find-WindowInfo.ps1
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

### 🛠️ Diagnostic and Development Tools

The project includes useful scripts to help you configure and maintain the project.

*   **`management/tools/Find-WindowInfo.ps1`**: If you don't know the exact title of an application's window (for example, to configure it in `Close-AppByTitle.ps1`), run this script. It will list all visible windows and their process names, helping you find the precise information.
*   **`Fix-Encoding.ps1`**: If you modify the scripts, this tool ensures they are saved with the correct encoding (UTF-8 with BOM) for perfect compatibility with PowerShell 5.1 and international characters.

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
3.  The script will cleanly remove all scheduled tasks and restore the main system settings.

**Note on Reversibility:** Uninstallation doesn't just remove the scheduled tasks. It also restores the main system settings to their default state to give you a clean system:
*   Windows updates are re-enabled.
*   Fast Startup is re-enabled.
*   The policy blocking OneDrive is removed.
*   The script will offer to disable automatic login.

Your system thus returns to being a standard workstation, with no residual modifications.

---

## ❤️ License and Contributions
This project is distributed under the **GPLv3** license. The full text is available in the `LICENSE` file.

Contributions, whether in the form of bug reports, improvement suggestions, or pull requests, are welcome.