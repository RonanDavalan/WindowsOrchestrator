# Der Windows-Orchestrator

[🇺🇸 English](README.md) | [🇫🇷 Français](README-fr-FR.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

Der Windows-Orchestrator ist eine Sammlung von Skripten, die die Windows-Aufgabenplanung verwenden, um PowerShell-Skripte (`.ps1`) auszuführen. Ein grafischer Assistent (`firstconfig.ps1`) ermöglicht es dem Benutzer, eine Konfigurationsdatei `config.ini` zu erstellen. Die Hauptskripte (`config_systeme.ps1`, `config_utilisateur.ps1`) lesen diese Datei, um spezifische Aktionen durchzuführen:
*   Änderung von Schlüsseln in der Windows-Registrierung.
*   Ausführung von Systembefehlen (`powercfg`, `shutdown`).
*   Verwaltung von Windows-Diensten (Änderung des Starttyps und Beenden des `wuauserv`-Dienstes).
*   Starten oder Beenden von benutzerdefinierten Anwendungsprozessen.
*   Senden von HTTP-POST-Anfragen an einen Gotify-Benachrichtigungsdienst über den Befehl `Invoke-RestMethod`.

Die Skripte erkennen die Sprache des Betriebssystems des Benutzers und laden die Zeichenketten (für Protokolle, die grafische Benutzeroberfläche und Benachrichtigungen) aus den `.psd1`-Dateien im Verzeichnis `i18n`.

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 Besuchen Sie die offizielle Homepage für eine vollständige Vorstellung!</strong></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Lizenz-GPLv3-blue.svg" alt="Lizenz">
  <img src="https://img.shields.io/badge/PowerShell_Version-5.1%2B-blue" alt="PowerShell Version">
  <img src="https://img.shields.io/badge/Status-Betriebsbereit-brightgreen.svg" alt="Status">
  <img src="https://img.shields.io/badge/Betriebssystem-Windows_10_|_11-informational" alt="Betriebssystem">
  <img src="https://img.shields.io/badge/Unterstützung-11_Sprachen-orange.svg" alt="Unterstützung">
  <img src="https://img.shields.io/badge/Beiträge-Willkommen-brightgreen.svg" alt="Beiträge">
</p>

---

## Aktionen der Skripte

Das Skript `1_install.bat` führt `management\install.ps1` aus, welches zwei geplante Hauptaufgaben erstellt.
*   Die erste, **`WindowsOrchestrator-SystemStartup`**, führt `config_systeme.ps1` beim Start von Windows aus.
*   Die zweite, **`WindowsOrchestrator-UserLogon`**, führt `config_utilisateur.ps1` bei der Benutzeranmeldung aus.

Abhängig von den Einstellungen in der `config.ini`-Datei führen die Skripte die folgenden Aktionen aus:

*   **Verwaltung der automatischen Anmeldung:**
    *   `Aktion des Skripts:` Das Skript schreibt den Wert `1` in den Registrierungsschlüssel `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\AutoAdminLogon`.
    *   `Aktion des Benutzers:` Damit diese Funktion betriebsbereit ist, muss der Benutzer zuvor das Passwort in der Registrierung speichern. Das Skript verwaltet diese Information nicht. Das Dienstprogramm **Sysinternals AutoLogon** ist ein externes Werkzeug, das diese Aktion durchführen kann.

*   **Änderung der Energieeinstellungen:**
    *   Führt die Befehle `powercfg /change standby-timeout-ac 0` und `powercfg /change hibernate-timeout-ac 0` aus, um den Standby-Modus und den Ruhezustand zu deaktivieren.
    *   Führt den Befehl `powercfg /change monitor-timeout-ac 0` aus, um das Ausschalten des Bildschirms zu deaktivieren.
    *   Schreibt den Wert `0` in den Registrierungsschlüssel `HiberbootEnabled`, um den Schnellstart zu deaktivieren.

*   **Verwaltung von Windows-Updates:**
    *   Schreibt den Wert `1` in die Registrierungsschlüssel `NoAutoUpdate` und `NoAutoRebootWithLoggedOnUsers`.
    *   Ändert den Starttyp des Windows-Dienstes `wuauserv` auf `Disabled` (Deaktiviert) und führt den Befehl `Stop-Service` darauf aus.

*   **Planung eines täglichen Neustarts:**
    *   Erstellt eine geplante Aufgabe namens `WindowsOrchestrator-SystemScheduledReboot`, die `shutdown.exe /r /f /t 60` zur festgelegten Zeit ausführt.
    *   Erstellt eine geplante Aufgabe namens `WindowsOrchestrator-SystemPreRebootAction`, die einen vom Benutzer definierten Befehl vor dem Neustart ausführt.

*   **Protokollierung der Aktionen:**
    *   Schreibt zeitgestempelte Zeilen in `.txt`-Dateien im Ordner `Logs`.
    *   Eine Funktion `Rotate-LogFile` benennt vorhandene Protokolldateien um und archiviert sie. Die Anzahl der aufzubewahrenden Dateien wird durch die Schlüssel `MaxSystemLogsToKeep` und `MaxUserLogsToKeep` in der `config.ini` festgelegt.

*   **Senden von Gotify-Benachrichtigungen:**
    *   Wenn der Schlüssel `EnableGotify` in der `config.ini` auf `true` gesetzt ist, senden die Skripte eine HTTP-POST-Anfrage an die angegebene URL.
    *   Die Anfrage enthält eine JSON-Payload mit einem Titel und einer Nachricht. Die Nachricht ist eine Liste der durchgeführten Aktionen und aufgetretenen Fehler.

## Voraussetzungen

- **Betriebssystem**: Windows 10 oder Windows 11. Der Quellcode enthält die Direktive `#Requires -Version 5.1` für PowerShell-Skripte.
- **Berechtigungen**: Der Benutzer muss die Anfragen zur Erhöhung der Berechtigungen (UAC) bei der Ausführung von `1_install.bat` und `2_uninstall.bat` akzeptieren. Diese Aktion ist erforderlich, um den Skripten zu erlauben, geplante Aufgaben zu erstellen und Registrierungsschlüssel auf Systemebene zu ändern.
- **Automatische Anmeldung (Auto-Login)**: Wenn der Benutzer diese Option aktiviert, muss er ein externes Werkzeug wie **Microsoft Sysinternals AutoLogon** verwenden, um sein Passwort in der Registrierung zu speichern.

## Installation und Erstkonfiguration

Der Benutzer führt die Datei **`1_install.bat`** aus.

1.  **Konfiguration (`firstconfig.ps1`)**
    *   Das Skript `management\firstconfig.ps1` wird ausgeführt und zeigt eine grafische Benutzeroberfläche an.
    *   Wenn die Datei `config.ini` nicht existiert, wird sie aus der Vorlage `management\defaults\default_config.ini` erstellt.
    *   Wenn sie existiert, fragt das Skript den Benutzer, ob er sie durch die Vorlage ersetzen möchte.
    *   Der Benutzer gibt die Parameter ein. Durch Klicken auf "Speichern und Schließen" schreibt das Skript die Werte in die `config.ini`.

2.  **Installation der Aufgaben (`install.ps1`)**
    *   Nach dem Schließen des Assistenten führt `1_install.bat` das Skript `management\install.ps1` aus und fordert eine Erhöhung der Berechtigungen an.
    *   Das Skript `install.ps1` erstellt die beiden geplanten Aufgaben:
        *   **`WindowsOrchestrator-SystemStartup`**: Führt `config_systeme.ps1` beim Start von Windows mit dem Konto `NT AUTHORITY\SYSTEM` aus.
        *   **`WindowsOrchestrator-UserLogon`**: Führt `config_utilisateur.ps1` bei der Anmeldung des Benutzers aus, der die Installation gestartet hat.
    *   Um die Konfiguration anzuwenden, ohne auf einen Neustart zu warten, führt `install.ps1` am Ende des Prozesses einmalig `config_systeme.ps1` und dann `config_utilisateur.ps1` aus.

## Verwendung und Konfiguration nach der Installation

Jede Änderung der Konfiguration nach der Installation erfolgt über die Datei `config.ini`.

### 1. Manuelle Änderung der `config.ini`-Datei

*   **Aktion des Benutzers:** Der Benutzer öffnet die Datei `config.ini` mit einem Texteditor und ändert die gewünschten Werte.
*   **Aktion der Skripte:**
    *   Änderungen im Abschnitt `[SystemConfig]` werden von `config_systeme.ps1` gelesen und **beim nächsten Neustart des Computers** angewendet.
    *   Änderungen im Abschnitt `[Process]` werden von `config_utilisateur.ps1` gelesen und **bei der nächsten Benutzeranmeldung** angewendet.

### 2. Verwendung des grafischen Assistenten

*   **Aktion des Benutzers:** Der Benutzer führt `1_install.bat` erneut aus. Die grafische Benutzeroberfläche öffnet sich, vorausgefüllt mit den aktuellen Werten aus der `config.ini`. Der Benutzer ändert die Einstellungen und klickt auf "Speichern und Schließen".
*   **Aktion des Skripts:** Das Skript `firstconfig.ps1` schreibt die neuen Werte in die `config.ini`.
*   **Anwendungskontext:** Nach dem Schließen des Assistenten bietet die Eingabeaufforderung an, mit der Installation der Aufgaben fortzufahren. Der Benutzer kann dieses Fenster schließen, um nur die Konfiguration zu aktualisieren.

## Deinstallation

Der Benutzer führt die Datei **`2_uninstall.bat`** aus. Diese führt `management\uninstall.ps1` nach einer Anforderung zur Erhöhung der Berechtigungen (UAC) aus.

Das Skript `uninstall.ps1` führt die folgenden Aktionen aus:

1.  **Automatische Anmeldung:** Das Skript zeigt eine Aufforderung an, ob die automatische Anmeldung deaktiviert werden soll. Wenn der Benutzer mit `j` (ja) antwortet, schreibt das Skript den Wert `0` in den Registrierungsschlüssel `AutoAdminLogon`.
2.  **Wiederherstellung einiger Systemeinstellungen:**
    *   **Updates:** Es setzt den Registrierungswert `NoAutoUpdate` auf `0` und konfiguriert den Starttyp des Dienstes `wuauserv` auf `Automatic` (Automatisch).
    *   **Schnellstart:** Es setzt den Registrierungswert `HiberbootEnabled` auf `1`.
    *   **OneDrive:** Es löscht den Registrierungswert `DisableFileSyncNGSC`.
3.  **Löschen der geplanten Aufgaben:** Das Skript sucht und löscht die Aufgaben `WindowsOrchestrator-SystemStartup`, `WindowsOrchestrator-UserLogon`, `WindowsOrchestrator-SystemScheduledReboot` und `WindowsOrchestrator-SystemPreRebootAction`.

### Hinweis zur Wiederherstellung der Einstellungen

**Das Deinstallationsskript stellt die Energieeinstellungen nicht wieder her**, die durch den `powercfg`-Befehl geändert wurden.
*   **Konsequenz für den Benutzer:** Wenn der Ruhezustand des Computers oder des Bildschirms durch die Skripte deaktiviert wurde, bleibt er auch nach der Deinstallation deaktiviert.
*   **Erforderliche Aktion des Benutzers:** Um den Ruhezustand wieder zu aktivieren, muss der Benutzer diese Optionen manuell in den "Energie- und Ruhezustandseinstellungen" von Windows neu konfigurieren.

Der Deinstallationsprozess **löscht keine Dateien**. Das Projektverzeichnis und sein Inhalt bleiben auf der Festplatte.

## Projektstruktur

```
WindowsOrchestrator/
├── 1_install.bat                # Führt die grafische Konfiguration und dann die Installation der Aufgaben aus.
├── 2_uninstall.bat              # Führt das Deinstallationsskript aus.
├── Close-App.bat                # Führt das PowerShell-Skript Close-AppByTitle.ps1 aus.
├── Close-AppByTitle.ps1         # Skript, das ein Fenster nach seinem Titel findet und ihm eine Tastenfolge sendet.
├── config.ini                   # Konfigurationsdatei, die von den Hauptskripten gelesen wird.
├── config_systeme.ps1           # Skript für Maschineneinstellungen, wird beim Start ausgeführt.
├── config_utilisateur.ps1       # Skript zur Prozessverwaltung, wird bei der Anmeldung ausgeführt.
├── Fix-Encoding.ps1             # Werkzeug zum Konvertieren von Skriptdateien in die Kodierung UTF-8 mit BOM.
├── LaunchApp.bat                # Beispiel-Batch-Skript zum Starten einer externen Anwendung.
├── List-VisibleWindows.ps1      # Dienstprogramm, das sichtbare Fenster und ihre Prozesse auflistet.
├── i18n/
│   ├── en-US/
│   │   └── strings.psd1         # Datei mit Zeichenketten für Englisch.
│   └── ... (andere Sprachen)
└── management/
    ├── firstconfig.ps1          # Zeigt den grafischen Konfigurationsassistenten an.
    ├── install.ps1              # Erstellt die geplanten Aufgaben und führt die Skripte einmal aus.
    ├── uninstall.ps1            # Löscht die Aufgaben und stellt die Systemeinstellungen wieder her.
    └── defaults/
        └── default_config.ini   # Vorlage zum Erstellen der anfänglichen config.ini-Datei.
```

## Technische Grundlagen

*   **Native Befehle**: Das Projekt verwendet ausschließlich native Befehle von Windows und PowerShell. Es müssen keine externen Abhängigkeiten installiert werden.
*   **Systembibliotheken**: Fortgeschrittene Interaktionen mit dem System stützen sich ausschließlich auf in Windows integrierte Bibliotheken (z.B. `user32.dll`).

## Beschreibung der Schlüsseldateien

### `1_install.bat`
Diese Batch-Datei ist der Einstiegspunkt für den Installationsprozess. Sie führt `management\firstconfig.ps1` für die Konfiguration aus und anschließend `management\install.ps1` mit erhöhten Berechtigungen.

### `2_uninstall.bat`
Diese Batch-Datei ist der Einstiegspunkt für die Deinstallation. Sie führt `management\uninstall.ps1` mit erhöhten Berechtigungen aus.

### `config.ini`
Dies ist die zentrale Konfigurationsdatei. Sie enthält die Anweisungen (Schlüssel und Werte), die von den Skripten `config_systeme.ps1` und `config_utilisateur.ps1` gelesen werden, um zu bestimmen, welche Aktionen durchgeführt werden sollen.

### `config_systeme.ps1`
Dieses Skript wird beim Start des Computers durch eine geplante Aufgabe ausgeführt und liest den Abschnitt `[SystemConfig]` der Datei `config.ini`. Es wendet die Einstellungen an, indem es die Windows-Registrierung ändert, Systembefehle (`powercfg`) ausführt und Dienste (`wuauserv`) verwaltet.

### `config_utilisateur.ps1`
Dieses Skript wird bei der Benutzeranmeldung durch eine geplante Aufgabe ausgeführt und liest den Abschnitt `[Process]` der Datei `config.ini`. Seine Aufgabe ist es, alle vorhandenen Instanzen des Zielprozesses zu beenden und ihn dann mit den angegebenen Parametern neu zu starten.

### `management\firstconfig.ps1`
Dieses PowerShell-Skript zeigt die grafische Benutzeroberfläche an, mit der die Parameter in der Datei `config.ini` gelesen und geschrieben werden können.

### `management\install.ps1`
Dieses Skript enthält die Logik zur Erstellung der geplanten Aufgaben `WindowsOrchestrator-SystemStartup` und `WindowsOrchestrator-UserLogon`.

### `management\uninstall.ps1`
Dieses Skript enthält die Logik zum Löschen der geplanten Aufgaben und zur Wiederherstellung der Systemregistrierungsschlüssel auf ihre Standardwerte.

## Verwaltung durch die Aufgabenplanung

Die Automatisierung basiert auf der Windows-Aufgabenplanung (`taskschd.msc`). Die folgenden Aufgaben werden von den Skripten erstellt:

*   **`WindowsOrchestrator-SystemStartup`**: Wird beim Start des PCs ausgelöst und führt `config_systeme.ps1` aus.
*   **`WindowsOrchestrator-UserLogon`**: Wird bei der Benutzeranmeldung ausgelöst und führt `config_utilisateur.ps1` aus.
*   **`WindowsOrchestrator-SystemScheduledReboot`**: Wird von `config_systeme.ps1` erstellt, wenn `ScheduledRebootTime` in `config.ini` definiert ist.
*   **`WindowsOrchestrator-SystemPreRebootAction`**: Wird von `config_systeme.ps1` erstellt, wenn `PreRebootActionCommand` in `config.ini` definiert ist.

**Wichtig**: Das manuelle Löschen dieser Aufgaben über die Aufgabenplanung stoppt die Automatisierung, stellt jedoch die Systemeinstellungen nicht wieder her. Der Benutzer muss unbedingt `2_uninstall.bat` für eine vollständige und kontrollierte Deinstallation verwenden.

## Lizenz und Beiträge

Dieses Projekt wird unter der **GPLv3**-Lizenz vertrieben. Der vollständige Text ist in der Datei `LICENSE` verfügbar.

Beiträge, ob in Form von Fehlerberichten, Verbesserungsvorschlägen oder Pull-Requests, sind willkommen.