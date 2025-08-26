# Windows Orchestrator

[🇫🇷 Français](README-fr-FR.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

Windows Orchestrator is a set of scripts that uses the Windows Task Scheduler to run PowerShell scripts (`.ps1`). A graphical wizard (`firstconfig.ps1`) allows the user to generate a `config.ini` configuration file. The main scripts (`config_systeme.ps1`, `config_utilisateur.ps1`) read this file to perform specific actions:
*   Modifying Windows Registry keys.
*   Executing system commands (`powercfg`, `shutdown`).
*   Managing Windows services (changing the startup type and stopping the `wuauserv` service).
*   Starting or stopping user-defined application processes.
*   Sending HTTP POST requests to a Gotify notification service via the `Invoke-RestMethod` command.

The scripts detect the user's operating system language and load strings (for logs, the GUI, and notifications) from the `.psd1` files located in the `i18n` directory.

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 Visit the official homepage for a full presentation!</strong></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/License-GPLv3-blue.svg" alt="License">
  <img src="https://img.shields.io/badge/PowerShell_Version-5.1%2B-blue" alt="PowerShell Version">
  <img src="https://img.shields.io/badge/Status-Operational-brightgreen.svg" alt="Status">
  <img src="https://img.shields.io/badge/OS-Windows_10_|_11-informational" alt="OS">
  <img src="https://img.shields.io/badge/Support-11_Languages-orange.svg" alt="Support">
  <img src="https://img.shields.io/badge/Contributions-Welcome-brightgreen.svg" alt="Contributions">
</p>

---

## Script Actions

The `1_install.bat` script runs `management\install.ps1`, which creates two main Scheduled Tasks.
*   The first, **`WindowsOrchestrator-SystemStartup`**, runs `config_systeme.ps1` when Windows starts.
*   The second, **`WindowsOrchestrator-UserLogon`**, runs `config_utilisateur.ps1` when the user logs on.

Depending on the settings in the `config.ini` file, the scripts perform the following actions:

*   **Automatic Logon Management:**
    *   `Script Action:` The script writes the value `1` to the `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\AutoAdminLogon` Registry key.
    *   `User Action:` For this function to be operational, the user must first save the password in the Registry. The script does not handle this information. The **Sysinternals AutoLogon** utility is an external tool that can perform this action.

*   **Changing Power Settings:**
    *   Runs the commands `powercfg /change standby-timeout-ac 0` and `powercfg /change hibernate-timeout-ac 0` to disable sleep mode.
    *   Runs the command `powercfg /change monitor-timeout-ac 0` to disable the display from turning off.
    *   Writes the value `0` to the `HiberbootEnabled` Registry key to disable Fast Startup.

*   **Managing Windows Updates:**
    *   Writes the value `1` to the `NoAutoUpdate` and `NoAutoRebootWithLoggedOnUsers` Registry keys.
    *   Changes the startup type of the `wuauserv` Windows service to `Disabled` and runs the `Stop-Service` command on it.

*   **Scheduling a Daily Reboot:**
    *   Creates a Scheduled Task named `WindowsOrchestrator-SystemScheduledReboot` that runs `shutdown.exe /r /f /t 60` at the defined time.
    *   Creates a Scheduled Task named `WindowsOrchestrator-SystemPreRebootAction` that runs a user-defined command before the reboot.

*   **Logging Actions:**
    *   Writes timestamped lines to `.txt` files in the `Logs` folder.
    *   A `Rotate-LogFile` function renames and archives existing log files. The number of files to keep is defined by the `MaxSystemLogsToKeep` and `MaxUserLogsToKeep` keys in `config.ini`.

*   **Sending Gotify Notifications:**
    *   If the `EnableGotify` key is set to `true` in `config.ini`, the scripts send an HTTP POST request to the specified URL.
    *   The request contains a JSON payload with a title and a message. The message is a list of actions performed and errors encountered.

## Prerequisites

- **Operating System**: Windows 10 or Windows 11. The source code includes the `#Requires -Version 5.1` directive for PowerShell scripts.
- **Permissions**: The user must accept User Account Control (UAC) prompts for privilege elevation when running `1_install.bat` and `2_uninstall.bat`. This action is necessary to allow the scripts to create scheduled tasks and modify system-level Registry keys.
- **Automatic Logon (Auto-Login)**: If the user enables this option, they must use an external tool like **Microsoft Sysinternals AutoLogon** to save their password in the Registry.

## Installation and First-Time Setup

The user runs the **`1_install.bat`** file.

1.  **Configuration (`firstconfig.ps1`)**
    *   The `management\firstconfig.ps1` script runs and displays a graphical interface.
    *   If the `config.ini` file does not exist, it is created from the `management\defaults\default_config.ini` template.
    *   If it exists, the script asks the user if they want to replace it with the template.
    *   The user enters the settings. By clicking "Save and Close," the script writes the values to `config.ini`.

2.  **Task Installation (`install.ps1`)**
    *   After the wizard closes, `1_install.bat` runs `management\install.ps1`, requesting privilege elevation.
    *   The `install.ps1` script creates the two Scheduled Tasks:
        *   **`WindowsOrchestrator-SystemStartup`**: Runs `config_systeme.ps1` at Windows startup with the `NT AUTHORITY\SYSTEM` account.
        *   **`WindowsOrchestrator-UserLogon`**: Runs `config_utilisateur.ps1` at the logon of the user who launched the installation.
    *   To apply the configuration without waiting for a restart, `install.ps1` runs `config_systeme.ps1` and then `config_utilisateur.ps1` once at the end of the process.

## Usage and Post-Installation Configuration

Any configuration changes after installation are made via the `config.ini` file.

### 1. Manual Modification of the `config.ini` file

*   **User Action:** The user opens the `config.ini` file with a text editor and modifies the desired values.
*   **Script Action:**
    *   Changes in the `[SystemConfig]` section are read and applied by `config_systeme.ps1` **at the next computer restart**.
    *   Changes in the `[Process]` section are read and applied by `config_utilisateur.ps1` **at the next user logon**.

### 2. Using the GUI Assistant

*   **User Action:** The user runs `1_install.bat` again. The graphical interface opens, pre-filled with the current values from `config.ini`. The user modifies the settings and clicks "Save and Close."
*   **Script Action:** The `firstconfig.ps1` script writes the new values to `config.ini`.
*   **Usage Context:** After the wizard closes, the command prompt offers to proceed with task installation. The user can close this window to only update the configuration.

## Uninstallation

The user runs the **`2_uninstall.bat`** file. This file executes `management\uninstall.ps1` after a User Account Control (UAC) prompt for privilege elevation.

The `uninstall.ps1` script performs the following actions:

1.  **Automatic Logon:** The script displays a prompt asking if automatic logon should be disabled. If the user answers `y` (yes), the script writes the value `0` to the `AutoAdminLogon` Registry key.
2.  **Restoring certain system settings:**
    *   **Updates:** It sets the `NoAutoUpdate` Registry value to `0` and configures the startup type of the `wuauserv` service to `Automatic`.
    *   **Fast Startup:** It sets the `HiberbootEnabled` Registry value to `1`.
    *   **OneDrive:** It deletes the `DisableFileSyncNGSC` Registry value.
3.  **Deleting Scheduled Tasks:** The script finds and deletes the `WindowsOrchestrator-SystemStartup`, `WindowsOrchestrator-UserLogon`, `WindowsOrchestrator-SystemScheduledReboot`, and `WindowsOrchestrator-SystemPreRebootAction` tasks.

### Note on Restoring Settings

**The uninstallation script does not restore the power settings** that were modified by the `powercfg` command.
*   **Consequence for the user:** If the machine's or display's sleep mode was disabled by the scripts, it will remain so after uninstallation.
*   **Required user action:** To re-enable sleep mode, the user must manually reconfigure these options in Windows "Power & sleep settings."

The uninstallation process **does not delete any files**. The project directory and its contents remain on the disk.

## Project Structure

```
WindowsOrchestrator/
├── 1_install.bat                # Runs the graphical configuration then the task installation.
├── 2_uninstall.bat              # Runs the uninstallation script.
├── Close-App.bat                # Runs the Close-AppByTitle.ps1 PowerShell script.
├── Close-AppByTitle.ps1         # Script that finds a window by its title and sends it a key sequence.
├── config.ini                   # Configuration file read by the main scripts.
├── config_systeme.ps1           # Script for machine settings, executed at startup.
├── config_utilisateur.ps1       # Script for process management, executed at logon.
├── Fix-Encoding.ps1             # Tool to convert script files to UTF-8 with BOM encoding.
├── LaunchApp.bat                # Example batch script to launch an external application.
├── List-VisibleWindows.ps1      # Utility that lists visible windows and their processes.
├── i18n/
│   ├── en-US/
│   │   └── strings.psd1         # String file for English.
│   └── ... (other languages)
└── management/
    ├── firstconfig.ps1          # Displays the graphical configuration wizard.
    ├── install.ps1              # Creates the scheduled tasks and runs the scripts once.
    ├── uninstall.ps1            # Deletes tasks and restores system settings.
    └── defaults/
        └── default_config.ini   # Template to create the initial config.ini file.
```

## Technical Principles

*   **Native Commands**: The project exclusively uses native Windows and PowerShell commands. No external dependencies need to be installed.
*   **System Libraries**: Advanced interactions with the system rely solely on libraries built into Windows (e.g., `user32.dll`).

## Key File Descriptions

### `1_install.bat`
This batch file is the entry point for the installation process. It runs `management\firstconfig.ps1` for configuration, then executes `management\install.ps1` with elevated privileges.

### `2_uninstall.bat`
This batch file is the entry point for uninstallation. It runs `management\uninstall.ps1` with elevated privileges.

### `config.ini`
This is the central configuration file. It contains the instructions (keys and values) that are read by the `config_systeme.ps1` and `config_utilisateur.ps1` scripts to determine which actions to perform.

### `config_systeme.ps1`
Executed at computer startup by a Scheduled Task, this script reads the `[SystemConfig]` section of the `config.ini` file. It applies settings by modifying the Windows Registry, running system commands (`powercfg`), and managing services (`wuauserv`).

### `config_utilisateur.ps1`
Executed at user logon by a Scheduled Task, this script reads the `[Process]` section of the `config.ini` file. Its role is to stop any existing instance of the target process and then restart it using the provided parameters.

### `management\firstconfig.ps1`
This PowerShell script displays the graphical interface that allows reading and writing settings to the `config.ini` file.

### `management\install.ps1`
This script contains the logic for creating the `WindowsOrchestrator-SystemStartup` and `WindowsOrchestrator-UserLogon` Scheduled Tasks.

### `management\uninstall.ps1`
This script contains the logic for deleting the Scheduled Tasks and restoring system Registry keys to their default values.

## Management by Scheduled Tasks

Automation relies on the Windows Task Scheduler (`taskschd.msc`). The following tasks are created by the scripts:

*   **`WindowsOrchestrator-SystemStartup`**: Triggers at PC startup and runs `config_systeme.ps1`.
*   **`WindowsOrchestrator-UserLogon`**: Triggers at user logon and runs `config_utilisateur.ps1`.
*   **`WindowsOrchestrator-SystemScheduledReboot`**: Created by `config_systeme.ps1` if `ScheduledRebootTime` is defined in `config.ini`.
*   **`WindowsOrchestrator-SystemPreRebootAction`**: Created by `config_systeme.ps1` if `PreRebootActionCommand` is defined in `config.ini`.

**Important**: Deleting these tasks manually via the Task Scheduler stops the automation but does not restore system settings. The user must use `2_uninstall.bat` for a complete and controlled uninstallation.

## License and Contributions

This project is distributed under the **GPLv3** license. The full text is available in the `LICENSE` file.

Contributions, whether bug reports, improvement suggestions, or pull requests, are welcome.