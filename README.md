# Windows Orchestrator

<p align="center">
  <img src="https://img.shields.io/badge/License-GPLv3-blue.svg" alt="License">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue" alt="PowerShell Version">
  <img src="https://img.shields.io/badge/Support-11_Languages-orange.svg" alt="Multilingual Support">
  <img src="https://img.shields.io/badge/OS-Windows_10_|_11-informational" alt="Supported OS">
</p>

**🇺🇸 English** | [🇫🇷 Français](README-fr-FR.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

---

This project automates a Windows workstation so that an application can run on it unattended.

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 Visit the official homepage for a full overview!</strong></a>
</p>

After an unexpected restart (due to a power outage or an incident), this project handles opening the Windows session and automatically relaunching your application, thus ensuring its service continuity. It also allows scheduling daily reboots to maintain system stability.

All actions are driven by a single configuration file, created during installation.

### **Installation**

1.  **Prerequisite (for automatic login):** If you want the Windows session to open by itself, first use the **[Sysinternals AutoLogon](https://learn.microsoft.com/en-us/sysinternals/downloads/autologon)** tool to save the password. This is the only external configuration required.
2.  **Launch:** Run **`1_install.bat`**. A graphical wizard will guide you through creating your configuration file. The installation will then proceed and request administrator permission (UAC).

A graphical configuration wizard will appear, allowing you to easily set up all the project's parameters. The installation will then proceed and request administrator permission (UAC).

<p align="center">
  <img src="assets/screenshot-wizard.png" alt="WindowsOrchestrator Configuration Wizard" width="700">
</p>

### **Usage**

Once installed, the project is autonomous. To modify the configuration (change the application to launch, the restart time, etc.), simply edit the `config.ini` file located in the project directory.

### **Uninstallation**

Run **`2_uninstall.bat`**. The script will remove all automation and restore the main Windows settings to their default values.

*   **Important Note:** The only settings not restored are those related to power management (`powercfg`).
*   The project directory with all its files remains on your disk and can be deleted manually.

### **Technical Documentation**

For a detailed description of the architecture, each script, and all configuration options, please consult the reference documentation.

➡️ **[Consult the Detailed Technical Documentation](./docs/en-US/DEVELOPER_GUIDE.md)**

---
**License**: This project is distributed under the GPLv3 license. See the `LICENSE` file.
