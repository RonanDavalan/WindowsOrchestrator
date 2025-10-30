# Windows Orchestrator

[🇫🇷 Français](README-fr-FR.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

**Your autopilot for dedicated Windows workstations. Configure once, and let the system reliably manage itself.**

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 Visit the Official Homepage for a full tour!</strong></a>
</p>

![Licence](https://img.shields.io/badge/Licence-GPLv3-blue.svg)![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1%2B-blue)![Status](https://img.shields.io/badge/Status-Operational-brightgreen.svg)![OS](https://img.shields.io/badge/OS-Windows_10_|_11-informational)![Support](https://img.shields.io/badge/Support-11_Languages-orange.svg)![Contributions](https://img.shields.io/badge/Contributions-Welcome-brightgreen.svg)

---

## Our Mission

Imagine a perfectly reliable and autonomous Windows workstation. A machine you configure once for its mission and can then forget about. A system that ensures your application remains **permanently operational**, without interruption.

This is the goal that **WindowsOrchestrator** helps you achieve. The challenge is that a standard Windows PC is not natively designed for this endurance. It is designed for human interaction: it goes to sleep, installs updates when it deems it appropriate, and does not automatically restart an application after a reboot.

**WindowsOrchestrator** is the solution: a set of scripts that acts as an intelligent and permanent supervisor. It transforms any PC into a reliable automaton, ensuring that your critical application is always operational, without manual intervention.



We were faced not with one, but with two types of systemic failures:

#### 1. The Abrupt Failure: The Unexpected Outage

The scenario is simple: a machine configured for remote access and a nighttime power outage. Even with a BIOS set for automatic restart, the mission fails. Windows restarts but remains on the login screen; the critical application is not relaunched, the session is not opened. The system is inaccessible.

#### 2. The Slow Degradation: Long-Term Instability

Even more insidious is the behavior of Windows over time. Designed as an interactive OS, it is not optimized for processes running without interruption. Gradually, memory leaks and performance degradation appear, making the system unstable and requiring a manual restart.

### The Answer: A Native Reliability Layer

Faced with these challenges, third-party utilities proved insufficient. We therefore made the decision to **architect our own system resilience layer.**

`WindowsOrchestrator` acts as an autopilot that takes control of the OS to:

- **Ensure Automatic Recovery:** After a failure, it guarantees session opening and the restart of your main application.
- **Guarantee Preventive Maintenance:** It allows you to schedule a controlled daily restart with the execution of custom scripts beforehand.
- **Protect the Application** from untimely interruptions from Windows (updates, sleep mode...).

`WindowsOrchestrator` is the essential tool for anyone who needs a Windows workstation to remain **reliable, stable, and operational without continuous monitoring.**

---

## Typical Use Cases

*   **Digital Signage:** Ensure that signage software runs 24/7 on a public screen.
*   **Home Servers and IoT:** Control a Plex server, a Home Assistant gateway, or a connected object from a Windows PC.
*   **Supervision Stations:** Keep a monitoring application (cameras, network logs) always active.
*   **Interactive Kiosks:** Ensure that the kiosk application restarts automatically after each reboot.
*   **Lightweight Automation:** Run scripts or processes continuously for data-mining or testing tasks.

---

## Key Features

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

## Target Audience and Best Practices

This project is designed to turn a PC into a reliable automaton, ideal for use cases where the machine is dedicated to a single application (server for an IoT device, digital signage, monitoring station, etc.). It is not recommended for a general-purpose office or everyday computer.

*   **Major Windows Updates:** For significant updates (e.g., upgrading from Windows 10 to 11), the safest procedure is to **uninstall** WindowsOrchestrator before the update, then **reinstall** it afterward.
*   **Corporate Environments:** If your computer is in a corporate domain managed by Group Policy Objects (GPOs), check with your IT department to ensure the modifications made by this script do not conflict with your organization's policies.

---

## Installation and Getting Started

**Language Note:** The launch scripts (`1_install.bat` and `2_uninstall.bat`) display their instructions in **English**. This is normal. These files act as simple launchers. As soon as the graphical wizard or the PowerShell scripts take over, the interface will automatically adapt to your operating system's language.

Setting up **WindowsOrchestrator** is a simple and guided process.

1.  **Download** or clone the project onto the computer to be configured.
2.  Run `1_install.bat`. The script will guide you through two steps:
    *   **Step 1: Configuration via the Graphical Wizard.**
        Adjust the options according to your needs. The most important ones are usually the username for automatic login and the application to launch. Click `Save` to save.
        
        ![Configuration Wizard](assets/screenshot-wizard.png)
        
    *   **Step 2: System Tasks Installation.**
        The script will ask for confirmation to continue. A Windows security (UAC) window will open. **You must accept it** to allow the script to create the necessary scheduled tasks.
3.  That's it! Upon the next reboot, your configurations will be applied.

---

## Configuration
You can adjust settings at any time in two ways:

### 1. Graphical Wizard (Simple method)
Rerun `1_install.bat` to reopen the configuration interface. Modify your settings and save.

### 2. `config.ini` File (Advanced method)
Open `config.ini` with a text editor for granular control.

#### Important Note on Auto-Login and Passwords
For security reasons, **WindowsOrchestrator never manages or stores passwords in plain text.** Here's how to configure auto-login effectively and securely:

*   **Scenario 1: The user account has no password.**
    Simply enter the username in the graphical wizard or in `AutoLoginUsername` in the `config.ini` file.

*   **Scenario 2: The user account has a password (Recommended method).**
    1.  Download the official **[Sysinternals AutoLogon](https://download.sysinternals.com/files/AutoLogon.zip)** tool from Microsoft (direct download link).
    2.  Launch AutoLogon and enter the username, domain, and password. This tool will securely store the password in the Registry.
    3.  In the **WindowsOrchestrator** configuration, you can now leave the `AutoLoginUsername` field empty (the script will detect the user configured by AutoLogon by reading the corresponding Registry key) or fill it in to be sure. Our script will ensure that the `AutoAdminLogon` Registry key is properly enabled to finalize the configuration.

#### Advanced Configuration: `PreRebootActionCommand`
This powerful feature allows you to execute a script before the daily reboot. The path can be:
- **Absolute:** `C:\Scripts\my_backup.bat`
- **Relative to the project:** `PreReboot.bat` (the script will look for this file at the root of the project).
- **Using `%USERPROFILE%`:** `%USERPROFILE%\Desktop\cleanup.ps1` (the script will intelligently replace `%USERPROFILE%` with the path to the auto-login user's profile).

---

## Project Structure
```
WindowsOrchestrator/
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

## Detailed Operation
The core of **WindowsOrchestrator** relies on the Windows Task Scheduler:

1.  **At Windows Startup**
    *   The `WindowsOrchestrator_SystemStartup` task runs with `SYSTEM` privileges.
    *   The `config_systeme.ps1` script reads `config.ini` and applies all machine configurations. It also manages the creation/update of reboot tasks.

2.  **At User Login**
    *   The `WindowsOrchestrator_UserLogon` task runs.
    *   The `config_utilisateur.ps1` script reads the `[Process]` section of `config.ini` and ensures that your main application is properly launched. If it was already running, it is first stopped then cleanly relaunched.

3.  **Daily (If configured)**
    *   The `WindowsOrchestrator_PreRebootAction` task executes your backup/cleanup script.
    *   A few minutes later, the `WindowsOrchestrator_ScheduledReboot` task reboots the computer.

---

### Diagnostic and Development Tools

The project includes useful scripts to help you configure and maintain the project.

*   **`management/tools/Find-WindowInfo.ps1`**: If you don't know the exact title of an application's window (for example, to configure it in `Close-AppByTitle.ps1`), run this script. It will list all visible windows and their process names, helping you find the precise information.
*   **`Fix-Encoding.ps1`**: If you modify the scripts, this tool ensures they are saved with the correct encoding (UTF-8 with BOM) for perfect compatibility with PowerShell 5.1 and international characters.

---

## Logging
For easy troubleshooting, everything is logged.
*   **Location:** In the `Logs/` subfolder.
*   **Files:** `config_systeme_ps_log.txt` and `config_utilisateur_log.txt`.
*   **Rotation:** Old logs are automatically archived to prevent them from becoming too large.

---

## Uninstallation
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

## License and Contributions
This project is distributed under the **GPLv3** license. The full text is available in the `LICENSE` file.

Contributions, whether in the form of bug reports, improvement suggestions, or pull requests, are welcome.
