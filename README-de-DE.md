# WindowsAutoConfig ⚙️

[🇫🇷 Français](README-fr-FR.md) | [🇺🇸 English](README.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md)

**Ihr Autopilot für dedizierte Windows-Arbeitsplätze. Einmal konfigurieren und das System zuverlässig sich selbst verwalten lassen.**

![Lizenz](https://img.shields.io/badge/Licence-GPLv3-blue.svg)
![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![Status](https://img.shields.io/badge/Statut-Opérationnel-brightgreen.svg)
![OS](https://img.shields.io/badge/OS-Windows_10_|_11-informational)
![Beiträge](https://img.shields.io/badge/Contributions-Bienvenues-brightgreen.svg)

---

## 🎯 Das WindowsAutoConfig-Manifest

### Das Problem
Die Bereitstellung und Wartung eines Windows-Computers für eine einzelne Aufgabe (interaktiver Kiosk, Digital Signage, Kommandozentrale) ist eine ständige Herausforderung. Unzeitgemäße Updates, unerwartete Ruhemodi, die Notwendigkeit, eine Anwendung nach einem Neustart manuell neu zu starten... Jedes Detail kann zu einer Fehlerquelle werden und erfordert zeitaufwändige manuelle Eingriffe. Die Konfiguration jedes Arbeitsplatzes ist ein sich wiederholender, langwieriger und fehleranfälliger Prozess.

### Die Lösung: WindowsAutoConfig
**WindowsAutoConfig** verwandelt jeden Windows-PC in einen zuverlässigen und vorhersehbaren Automaten. Es ist ein Satz von Skripten, die Sie lokal installieren und die die Kontrolle über die Systemkonfiguration übernehmen, um sicherzustellen, dass Ihr Computer genau das tut, was Sie von ihm erwarten, 24 Stunden am Tag, 7 Tage die Woche.

Es fungiert als dauerhafter Supervisor, der Ihre Regeln bei jedem Start und jeder Anmeldung anwendet, damit Sie dies nicht mehr tun müssen.

## ✨ Hauptfunktionen
*   **Grafischer Konfigurationsassistent:** Keine Notwendigkeit, Dateien für grundlegende Einstellungen zu bearbeiten.
*   **Energieverwaltung:** Deaktivieren Sie den Ruhemodus des Rechners, des Bildschirms und den Schnellstart von Windows für maximale Stabilität.
*   **Automatische Anmeldung (Auto-Login):** Verwaltet die automatische Anmeldung, auch in Synergie mit dem Tool **Sysinternals AutoLogon** für eine sichere Passwortverwaltung.
*   **Windows Update Kontrolle:** Verhindern Sie, dass erzwungene Updates und Neustarts Ihre Anwendung stören.
*   **Prozessmanager:** Startet, überwacht und startet Ihre Hauptanwendung bei jeder Sitzung automatisch neu.
*   **Geplanter täglicher Neustart:** Planen Sie einen täglichen Neustart, um die Systemfrische zu erhalten.
*   **Aktion vor dem Neustart:** Führen Sie ein benutzerdefiniertes Skript (Sicherung, Bereinigung...) vor dem geplanten Neustart aus.
*   **Detaillierte Protokollierung:** Alle Aktionen werden in Protokolldateien für eine einfache Diagnose aufgezeichnet.
*   **Benachrichtigungen (Optional):** Senden Sie Statusberichte über Gotify.

---

## 🚀 Installation und erste Schritte
Die Einrichtung von **WindowsAutoConfig** ist ein einfacher und geführter Prozess.

1.  **Laden Sie** das Projekt auf den zu konfigurierenden Computer herunter oder klonen Sie es.
2.  Führen Sie `1_install.bat` aus. Das Skript führt Sie durch zwei Schritte:
    *   **Schritt 1: Konfiguration über den grafischen Assistenten.**
        Passen Sie die Optionen an Ihre Bedürfnisse an. Die wichtigsten sind in der Regel die Benutzer-ID für die automatische Anmeldung und die zu startende Anwendung. Klicken Sie auf `Speichern`, um zu speichern.
    *   **Schritt 2: Installation der Systemaufgaben.**
        Das Skript fragt Sie nach einer Bestätigung zum Fortfahren. Ein Windows-Sicherheitsfenster (UAC) wird geöffnet. **Sie müssen es akzeptieren**, um dem Skript die Erstellung der notwendigen geplanten Aufgaben zu ermöglichen.
3.  Fertig! Beim nächsten Neustart werden Ihre Konfigurationen angewendet.

---

## 🔧 Konfiguration
Sie können die Einstellungen jederzeit auf zwei Arten anpassen:

### 1. Grafischer Assistent (einfache Methode)
Führen Sie `1_install.bat` erneut aus, um die Konfigurationsoberfläche wieder zu öffnen. Ändern Sie Ihre Einstellungen und speichern Sie.

### 2. Datei `config.ini` (erweiterte Methode)
Öffnen Sie `config.ini` mit einem Texteditor für eine detailliertere Kontrolle.

#### Wichtiger Hinweis zu Auto-Login und Passwörtern
Aus Sicherheitsgründen **verwaltet und speichert WindowsAutoConfig Passwörter niemals im Klartext.** So konfigurieren Sie das Auto-Login effektiv und sicher:

*   **Szenario 1: Das Benutzerkonto hat kein Passwort.**
    Geben Sie einfach den Benutzernamen im grafischen Assistenten oder unter `AutoLoginUsername` in der Datei `config.ini` an.

*   **Szenario 2: Das Benutzerkonto hat ein Passwort (empfohlene Methode).**
    1.  Laden Sie das offizielle Tool **[Sysinternals AutoLogon](https://download.sysinternals.com/files/AutoLogon.zip)** von Microsoft herunter (direkter Download-Link).
    2.  Starten Sie AutoLogon und geben Sie den Benutzernamen, die Domäne und das Passwort ein. Dieses Tool speichert das Passwort sicher in der Registrierung.
    3.  In der Konfiguration von **WindowsAutoConfig** können Sie nun das Feld `AutoLoginUsername` leer lassen (das Skript erkennt den von AutoLogon konfigurierten Benutzer) oder es zur Sicherheit ausfüllen. Unser Skript stellt sicher, dass der Registrierungsschlüssel `AutoAdminLogon` für die endgültige Konfiguration aktiviert ist.

#### Erweiterte Konfiguration: `PreRebootActionCommand`
Diese leistungsstarke Funktion ermöglicht es Ihnen, ein Skript vor dem täglichen Neustart auszuführen. Der Pfad kann sein:
- **Absolut:** `C:\Skripte\mein_backup.bat`
- **Relativ zum Projekt:** `PreReboot.bat` (das Skript sucht diese Datei im Stammverzeichnis des Projekts).
- **Verwenden von `%USERPROFILE%`:** `%USERPROFILE%\Desktop\cleanup.ps1` (das Skript ersetzt `%USERPROFILE%` intelligent durch den Pfad zum Profil des Auto-Login-Benutzers).

---

## 📂 Projektstruktur
```
WindowsAutoConfig/
├── 1_install.bat                # Einstiegspunkt für Installation und Konfiguration
├── 2_uninstall.bat              # Einstiegspunkt für die Deinstallation
├── config.ini                   # Zentrale Konfigurationsdatei
├── config_systeme.ps1           # Hauptskript für Maschineneinstellungen (wird beim Start ausgeführt)
├── config_utilisateur.ps1       # Hauptskript für die Benutzerprozessverwaltung (wird bei der Anmeldung ausgeführt)
├── PreReboot.bat                # Beispielskript für die Aktion vor dem Neustart
├── Logs/                        # (Automatisch erstellt) Enthält die Protokolldateien
└── management/
    ├── firstconfig.ps1          # Der Code des grafischen Konfigurationsassistenten
    ├── install.ps1              # Das technische Skript für die Aufgabeninstallation
    └── uninstall.ps1            # Das technische Skript zum Löschen von Aufgaben
```

---

## ⚙️ Detaillierte Funktionsweise
Das Herzstück von **WindowsAutoConfig** basiert auf dem Windows Aufgabenplaner:

1.  **Beim Windows-Start**
    *   Die Aufgabe `WindowsAutoConfig_SystemStartup` wird mit `SYSTEM`-Rechten ausgeführt.
    *   Das Skript `config_systeme.ps1` liest `config.ini` und wendet alle Maschinenkonfigurationen an. Es verwaltet auch die Erstellung/Aktualisierung der Neustartaufgaben.

2.  **Bei der Benutzeranmeldung**
    *   Die Aufgabe `WindowsAutoConfig_UserLogon` wird ausgeführt.
    *   Das Skript `config_utilisateur.ps1` liest den Abschnitt `[Process]` in `config.ini` und stellt sicher, dass Ihre Hauptanwendung ordnungsgemäß gestartet wird. Wenn sie bereits ausgeführt wurde, wird sie zuerst beendet und dann sauber neu gestartet.

3.  **Täglich (falls konfiguriert)**
    *   Die Aufgabe `WindowsAutoConfig_PreRebootAction` führt Ihr Sicherungs-/Bereinigungsskript aus.
    *   Wenige Minuten später startet die Aufgabe `WindowsAutoConfig_ScheduledReboot` den Computer neu.

---

### 🛠️ Diagnosetools

Das Projekt enthält nützliche Skripte, die Ihnen bei der Konfiguration komplexer Anwendungen helfen.

*   **`management/tools/Find-WindowInfo.ps1`**: Wenn Sie die Aktion vor dem Neustart für eine neue Anwendung konfigurieren müssen und den genauen Titel des Fensters nicht kennen, ist dieses Tool genau das Richtige für Sie. Starten Sie Ihre Anwendung und führen Sie dieses Skript in einer PowerShell-Konsole aus. Es listet alle sichtbaren Fenster und deren Prozessnamen auf, sodass Sie den genauen Titel finden können, der im Skript `Close-AppByTitle.ps1` zu verwenden ist.

---

## 📄 Protokollierung (Logging)
Zur einfachen Fehlerbehebung wird alles protokolliert.
*   **Speicherort:** Im Unterordner `Logs/`.
*   **Dateien:** `config_systeme_ps_log.txt` und `config_utilisateur_log.txt`.
*   **Rotation:** Alte Protokolle werden automatisch archiviert, um zu verhindern, dass sie zu groß werden.

---

## 🗑️ Deinstallation
Um das System zu entfernen:
1.  Führen Sie `2_uninstall.bat` aus.
2.  **Akzeptieren Sie die Berechtigungsanfrage (UAC)**.
3.  Das Skript entfernt sauber alle vom Projekt erstellten geplanten Aufgaben.

**Hinweis:** Die Deinstallation macht Systemänderungen (z. B. bleibt der Ruhemodus deaktiviert) nicht rückgängig und löscht den Projektordner nicht.

---

## ❤️ Lizenz und Beiträge
Dieses Projekt wird unter der **GPLv3**-Lizenz vertrieben. Der vollständige Text ist in der Datei `LICENSE` verfügbar.

Beiträge, sei es in Form von Fehlerberichten, Verbesserungsvorschlägen oder „Pull Requests“, sind willkommen.