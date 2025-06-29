# WindowsAutoConfig ⚙️

**Your autopilot for dedicated Windows workstations. Set it up once, and let your system manage itself reliably.**

![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![Status](https://img.shields.io/badge/Status-Operational-brightgreen.svg)
![OS](https://img.shields.io/badge/OS-Windows_10_|_11-informational)
![Contributions](https://img.shields.io/badge/Contributions-Welcome-brightgreen.svg)

---

## 🎯 The WindowsAutoConfig Manifesto

### The Problem
Deploying and maintaining a Windows computer for a single purpose (like an interactive kiosk, digital signage, or a control station) is a constant challenge. Intrusive updates, unexpected sleep modes, the need to manually restart an application after a reboot... every detail can become a point of failure, requiring expensive and time-consuming manual intervention. Configuring each machine is a repetitive, lengthy, and error-prone process.

### The Solution: WindowsAutoConfig
**WindowsAutoConfig** transforms any standard Windows PC into a reliable and predictable automaton. It's a set of locally-installed scripts that takes control of the system's configuration to ensure your machine does exactly what you expect it to, 24/7.

It acts as a permanent supervisor, applying your rules at every startup and user logon, so you don't have to.

## ✨ Key Features
*   **GUI Setup Assistant:** No need to edit files for basic settings.
*   **Power Management:** Disable machine sleep, screen sleep, and Windows Fast Startup for maximum stability.
*   **Auto-Login:** Manages auto-login, including synergy with the **Sysinternals AutoLogon** tool for secure password handling.
*   **Windows Update Control:** Prevent updates and forced reboots from disrupting your application.
*   **Process Watchdog:** Automatically launches, monitors, and restarts your main application every session.
*   **Scheduled Daily Reboot:** Program a daily reboot to maintain system freshness.
*   **Pre-Reboot Actions:** Run a custom script (for backups, cleanup, etc.) before the scheduled reboot.
*   **Detailed Logging:** All actions are recorded in log files for easy troubleshooting.
*   **Optional Notifications:** Send status reports via Gotify.

---

## 🚀 Installation & Getting Started
Setting up **WindowsAutoConfig** is a simple, guided process.

1.  **Download** or clone this project onto the target computer.
2.  Run `1_install.bat`. The script will guide you through two steps:
    *   **Step 1: Configuration via the GUI Assistant.**
        Adjust the settings to fit your needs. The most important ones are usually the username for Auto-Login and the application to launch. Click `Save` to store your configuration.
    *   **Step 2: System Task Installation.**
        The script will ask for confirmation to proceed. A Windows security prompt (UAC) will appear. **You must accept it** to allow the script to create the necessary scheduled tasks.
3.  That's it! Your configurations will be applied on the next reboot.

---

## 🔧 Configuration
You can adjust the settings at any time in two ways:

### 1. GUI Assistant (Simple Method)
Simply run `1_install.bat` again to open the configuration interface. Change your settings and save.

### 2. `config.ini` File (Advanced Method)
Open `config.ini` with a text editor for granular control.

#### Important Note on Auto-Login and Passwords
For security reasons, **WindowsAutoConfig does not handle or store plain-text passwords.** Here is how to set up auto-login effectively and securely:

*   **Scenario 1: The user account has no password.**
    Simply provide the username in the GUI assistant or in the `AutoLoginUsername` field of the `config.ini` file.

*   **Scenario 2: The user account has a password (Recommended Method).**
    1.  Download the official **[Sysinternals AutoLogon](https://download.sysinternals.com/files/AutoLogon.zip)** tool from Microsoft (direct download link).
    2.  Run AutoLogon and enter the username, domain, and password. This utility will store the password securely in the Windows Registry.
    3.  In your **WindowsAutoConfig** setup, you can now either leave the `AutoLoginUsername` field blank (the script will detect the username configured by AutoLogon) or fill it in to be certain. Our script will ensure the `AutoAdminLogon` registry key is enabled to complete the setup.

#### Advanced Configuration: `PreRebootActionCommand`
This powerful feature lets you run a script before the daily reboot. The path can be:
- **Absolute:** `C:\Scripts\my_backup.bat`
- **Project-Relative:** `PreReboot.bat` (the script will look for this file in the project's root directory).
- **Using `%USERPROFILE%`:** `%USERPROFILE%\Desktop\cleanup.ps1` (the script will intelligently resolve `%USERPROFILE%` to the Auto-Login user's profile path).

---

## 📂 Project Structure
```
WindowsAutoConfig/
├── 1_install.bat                # Entry point for installation and configuration
├── 2_uninstall.bat              # Entry point for uninstallation
├── config.ini                   # Central configuration file
├── config_systeme.ps1           # Main script for machine settings (runs on system startup)
├── config_utilisateur.ps1       # Main script for user process management (runs on user logon)
├── PreReboot.bat                # Example script for the pre-reboot action
├── Logs/                        # (Created automatically) Contains the log files
└── management/
    ├── firstconfig.ps1          # The code for the GUI setup assistant
    ├── install.ps1              # The technical script for task installation
    └── uninstall.ps1            # The technical script for task removal
```

---

## ⚙️ How It Works
The core of **WindowsAutoConfig** relies on the Windows Task Scheduler:

1.  **On Windows Startup**
    *   The `WindowsAutoConfig_SystemStartup` task runs with `SYSTEM` privileges.
    *   The `config_systeme.ps1` script reads `config.ini` and applies all machine-level configurations. It also manages the creation/update of the reboot-related tasks.

2.  **On User Logon**
    *   The `WindowsAutoConfig_UserLogon` task runs.
    *   The `config_utilisateur.ps1` script reads the `[Process]` section of `config.ini` and ensures your main application is running. If it was already running, it is stopped first and then cleanly restarted.

3.  **Daily (If Configured)**
    *   The `WindowsAutoConfig_PreRebootAction` task executes your custom backup/cleanup script.
    *   A few minutes later, the `WindowsAutoConfig_ScheduledReboot` task reboots the computer.

---

## 📄 Logging
For easy troubleshooting, everything is logged.
*   **Location:** In the `Logs/` subdirectory.
*   **Files:** `config_systeme_ps_log.txt` and `config_utilisateur_log.txt`.
*   **Rotation:** Old logs are automatically archived to prevent them from growing too large.

---

## 🗑️ Uninstallation
To remove the system:
1.  Run `2_uninstall.bat`.
2.  **Accept the UAC elevation prompt**.
3.  The script will cleanly remove all scheduled tasks created by the project.

**Note:** The uninstallation process does not revert system changes (e.g., sleep will remain disabled) and does not delete the project folder.

---

## ❤️ License and Contributions
This project is distributed under the **GPLv3** License. The full text is available in the `LICENSE` file.

Contributions, whether in the form of bug reports, feature requests, or pull requests, are welcome.