# Der Windows-Orchestrator

<p align="center">
  <img src="https://img.shields.io/badge/Lizenz-GPLv3-blue.svg" alt="Lizenz">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue" alt="PowerShell-Version">
  <img src="https://img.shields.io/badge/Unterstützung-11_Sprachen-orange.svg" alt="Mehrsprachige Unterstützung">
  <img src="https://img.shields.io/badge/OS-Windows_10_|_11-informational" alt="Unterstützte Betriebssysteme">
</p>

[🇺🇸 English](README.md) | [🇫🇷 Français](README-fr-FR.md) | **🇩🇪 Deutsch** | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

---

Dieses Projekt automatisiert eine Windows-Arbeitsstation, damit eine Anwendung unbeaufsichtigt darauf laufen kann.

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 Besuchen Sie die offizielle Homepage für eine vollständige Präsentation!</strong></a>
</p>

Nach einem unerwarteten Neustart (aufgrund eines Stromausfalls oder eines Vorfalls) kümmert sich dieses Projekt darum, die Windows-Sitzung zu öffnen und Ihre Anwendung automatisch neu zu starten, um die Kontinuität des Dienstes zu gewährleisten. Es ermöglicht auch die Planung täglicher Neustarts, um die Stabilität des Systems zu erhalten.

Alle Aktionen werden durch eine einzige Konfigurationsdatei gesteuert, die bei der Installation erstellt wird.

### **Installation**

1.  **Voraussetzung (für die automatische Anmeldung):** Wenn Sie möchten, dass sich die Windows-Sitzung von selbst öffnet, verwenden Sie zuvor das Tool **[Sysinternals AutoLogon](https://learn.microsoft.com/de-de/sysinternals/downloads/autologon)**, um das Passwort zu speichern. Dies ist die einzige erforderliche externe Konfiguration.
2.  **Start:** Führen Sie **`1_install.bat`** aus. Ein grafischer Assistent führt Sie durch die Erstellung Ihrer Konfigurationsdatei. Die Installation wird dann fortgesetzt und erfordert eine Administratorberechtigung (UAC).

### **Verwendung**

Einmal installiert, ist das Projekt autonom. Um die Konfiguration zu ändern (die zu startende Anwendung, die Neustartzeit usw. zu ändern), bearbeiten Sie einfach die Datei `config.ini` im Projektverzeichnis.

### **Deinstallation**

Führen Sie **`2_uninstall.bat`** aus. Das Skript entfernt die gesamte Automatisierung und stellt die wichtigsten Windows-Einstellungen auf ihre Standardwerte zurück.

*   **Wichtiger Hinweis:** Die einzigen nicht wiederhergestellten Einstellungen sind die zur Energieverwaltung (`powercfg`).
*   Das Projektverzeichnis mit all seinen Dateien verbleibt auf Ihrer Festplatte und kann manuell gelöscht werden.

### **Technische Dokumentation**

Für eine detaillierte Beschreibung der Architektur, jedes Skripts und aller Konfigurationsoptionen konsultieren Sie bitte die Referenzdokumentation.

➡️ **[Konsultieren Sie die ausführliche technische Dokumentation](./docs/de-DE/ENTWICKLER_LEITFADEN.md)**

---
**Lizenz**: Dieses Projekt wird unter der GPLv3-Lizenz vertrieben. Siehe die `LICENSE`-Datei.
