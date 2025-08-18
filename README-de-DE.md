# WindowsAutoConfig ⚙️

[🇺🇸 English](README.md) | [🇫🇷 Français](README-fr-FR.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

**Ihr Autopilot für dedizierte Windows-Workstations. Einmal konfigurieren und das System zuverlässig sich selbst verwalten lassen.**

![Lizenz](https://img.shields.io/badge/Licence-GPLv3-blue.svg)![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1%2B-blue)![Status](https://img.shields.io/badge/Status-Operational-brightgreen.svg)![OS](https://img.shields.io/badge/OS-Windows_10_|_11-informational)![Unterstützung](https://img.shields.io/badge/Support-11_Languages-orange.svg)![Beiträge](https://img.shields.io/badge/Contributions-Welcome-brightgreen.svg)

---

## 🎯 Unsere Mission

Stellen Sie sich eine absolut zuverlässige und autonome Windows-Workstation vor. Eine Maschine, die Sie einmal für ihre Aufgabe konfigurieren und dann vergessen können. Ein System, das sicherstellt, dass Ihre Anwendung **dauerhaft betriebsbereit** bleibt, ohne Unterbrechung.

Das ist das Ziel, das **WindowsAutoConfig** Ihnen hilft zu erreichen. Die Herausforderung besteht darin, dass ein Standard-Windows-PC von Haus aus nicht für diese Ausdauer ausgelegt ist. Er ist für die menschliche Interaktion konzipiert: Er geht in den Ruhezustand, installiert Updates, wenn er es für richtig hält, und startet eine Anwendung nach einem Neustart nicht automatisch neu.

**WindowsAutoConfig** ist die Lösung: eine Reihe von Skripten, die als intelligenter und permanenter Supervisor fungieren. Es verwandelt jeden PC in einen zuverlässigen Automaten und stellt sicher, dass Ihre kritische Anwendung immer betriebsbereit ist, ohne manuellen Eingriff.

### Warum wurde `WindowsAutoConfig` entwickelt? Die Geschichte eines echten Bedarfs.

`WindowsAutoConfig` ist eine technische Lösung, die aus der Notwendigkeit heraus entstand, die **Betriebskontinuität** auf einem Desktop-Betriebssystem zu gewährleisten. **Entwickelt als Teil unserer lokalen KI-Lösung AllSys, ist es jetzt ein eigenständiges Open-Source-Tool, das für jede Anwendung verwendet werden kann.**

Wir sahen uns nicht nur mit einer, sondern mit zwei Arten von Systemausfällen konfrontiert:

#### 1. Der plötzliche Ausfall: Der unerwartete Stromausfall

Das Szenario ist einfach: eine für den Fernzugriff konfigurierte Maschine und ein nächtlicher Stromausfall. Selbst mit einem für den automatischen Neustart konfigurierten BIOS schlägt die Mission fehl. Windows startet neu, bleibt aber auf dem Anmeldebildschirm; die kritische Anwendung wird nicht neu gestartet, die Sitzung wird nicht geöffnet. Das System ist unzugänglich.

#### 2. Die langsame Verschlechterung: Langfristige Instabilität

Noch heimtückischer ist das Verhalten von Windows im Laufe der Zeit. Als interaktives Betriebssystem konzipiert, ist es nicht für unterbrechungsfrei laufende Prozesse optimiert. Allmählich treten Speicherlecks und Leistungsverschlechterungen auf, die das System instabil machen und einen manuellen Neustart erfordern.

### Die Antwort: Eine native Zuverlässigkeitsschicht

Angesichts dieser Herausforderungen erwiesen sich Dienstprogramme von Drittanbietern als unzureichend. Wir haben uns daher entschieden, **unsere eigene Systemresilienzschicht zu entwickeln.**

`WindowsAutoConfig` fungiert als Autopilot, der die Kontrolle über das Betriebssystem übernimmt, um:

- **Automatische Wiederherstellung zu gewährleisten:** Nach einem Ausfall garantiert es das Öffnen der Sitzung und den Neustart Ihrer Hauptanwendung.
- **Vorbeugende Wartung zu garantieren:** Es ermöglicht Ihnen, einen kontrollierten täglichen Neustart mit der vorherigen Ausführung von benutzerdefinierten Skripten zu planen.
- **Die Anwendung** vor unerwünschten Unterbrechungen durch Windows (Updates, Ruhezustand...) zu schützen.

`WindowsAutoConfig` ist das unverzichtbare Werkzeug für jeden, der eine Windows-Workstation benötigt, die **zuverlässig, stabil und ohne kontinuierliche Überwachung betriebsbereit bleibt.**

---

## 💡 Typische Anwendungsfälle

*   **Digital Signage:** Sicherstellen, dass eine Signage-Software rund um die Uhr auf einem öffentlichen Bildschirm läuft.
*   **Heimserver und IoT:** Steuern eines Plex-Servers, eines Home Assistant-Gateways oder eines vernetzten Objekts von einem Windows-PC aus.
*   **Überwachungsstationen:** Eine Überwachungsanwendung (Kameras, Netzwerkprotokolle) immer aktiv halten.
*   **Interaktive Kioske:** Sicherstellen, dass die Kiosk-Anwendung nach jedem Neustart automatisch neu startet.
*   **Leichte Automatisierung:** Skripte oder Prozesse kontinuierlich für Data-Mining- oder Testaufgaben ausführen.

---

## ✨ Hauptmerkmale

*   **Grafischer Konfigurationsassistent:** Keine Notwendigkeit, Dateien für grundlegende Einstellungen zu bearbeiten.
*   **Vollständige mehrsprachige Unterstützung:** Benutzeroberfläche und Protokolle in 11 Sprachen verfügbar, mit automatischer Erkennung der Systemsprache.
*   **Energieverwaltung:** Deaktivieren Sie den Ruhezustand des Rechners, des Bildschirms und den Schnellstart von Windows für maximale Stabilität.
*   **Automatische Anmeldung (Auto-Login):** Verwaltet die automatische Anmeldung, auch in Synergie mit dem Tool **Sysinternals AutoLogon** für eine sichere Passwortverwaltung.
*   **Windows Update Kontrolle:** Verhindern Sie, dass erzwungene Updates und Neustarts Ihre Anwendung stören.
*   **Prozessmanager:** Startet, überwacht und startet Ihre Hauptanwendung bei jeder Sitzung automatisch neu.
*   **Geplanter täglicher Neustart:** Planen Sie einen täglichen Neustart, um die Systemfrische zu erhalten.
*   **Aktion vor dem Neustart:** Führen Sie ein benutzerdefiniertes Skript (Sicherung, Bereinigung...) vor dem geplanten Neustart aus.
*   **Detaillierte Protokollierung:** Alle Aktionen werden in Protokolldateien für eine einfache Diagnose aufgezeichnet.
*   **Benachrichtigungen (Optional):** Senden Sie Statusberichte über Gotify.

---

## 🎯 Zielgruppe und bewährte Praktiken

Dieses Projekt wurde entwickelt, um einen PC in einen zuverlässigen Automaten zu verwandeln, ideal für Anwendungsfälle, in denen die Maschine einer einzigen Anwendung gewidmet ist (Server für ein IoT-Gerät, Digital Signage, Überwachungsstation usw.). Es wird nicht für einen Allzweck-Büro- oder Alltagscomputer empfohlen.

*   **Große Windows-Updates:** Bei bedeutenden Updates (z. B. Upgrade von Windows 10 auf 11) ist das sicherste Verfahren, WindowsAutoConfig vor dem Update zu **deinstallieren** und danach **neu zu installieren**.
*   **Unternehmensumgebungen:** Wenn Ihr Computer Teil einer Unternehmensdomäne ist, die von Gruppenrichtlinienobjekten (GPOs) verwaltet wird, erkundigen Sie sich bei Ihrer IT-Abteilung, um sicherzustellen, dass die von diesem Skript vorgenommenen Änderungen nicht im Widerspruch zu den Richtlinien Ihrer Organisation stehen.

---

## 🚀 Installation und erste Schritte

**Hinweis zur Sprache:** Die Startskripte (`1_install.bat` und `2_uninstall.bat`) zeigen ihre Anweisungen auf **Englisch** an. Das ist normal. Diese Dateien fungieren als einfache Starter. Sobald der grafische Assistent oder die PowerShell-Skripte übernehmen, passt sich die Benutzeroberfläche automatisch der Sprache Ihres Betriebssystems an.

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
    3.  In der Konfiguration von **WindowsAutoConfig** können Sie nun das Feld `AutoLoginUsername` leer lassen (das Skript erkennt den von AutoLogon konfigurierten Benutzer durch Lesen des entsprechenden Registrierungsschlüssels) oder es zur Sicherheit ausfüllen. Unser Skript stellt sicher, dass der Registrierungsschlüssel `AutoAdminLogon` für die endgültige Konfiguration aktiviert ist.

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
├── LaunchApp.bat                # (Beispiel) Portabler Starter für Ihre Hauptanwendung
├── PreReboot.bat                # Beispielskript für die Aktion vor dem Neustart
├── Logs/                        # (Automatisch erstellt) Enthält die Protokolldateien
├── i18n/                        # Enthält alle Übersetzungsdateien
│   ├── de-DE/strings.psd1
│   └── ... (andere Sprachen)
└── management/
    ├── defaults/default_config.ini # Initiale Konfigurationsvorlage
    ├── tools/                   # Diagnosewerkzeuge
    │   └── Find-WindowInfo.ps1
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

### 🛠️ Diagnose- und Entwicklungstools

Das Projekt enthält nützliche Skripte, die Ihnen bei der Konfiguration und Wartung des Projekts helfen.

*   **`management/tools/Find-WindowInfo.ps1`**: Wenn Sie den genauen Titel eines Anwendungsfensters nicht kennen (um ihn beispielsweise in `Close-AppByTitle.ps1` zu konfigurieren), führen Sie dieses Skript aus. Es listet alle sichtbaren Fenster und deren Prozessnamen auf und hilft Ihnen so, die genauen Informationen zu finden.
*   **`Fix-Encoding.ps1`**: Wenn Sie die Skripte ändern, stellt dieses Tool sicher, dass sie mit der richtigen Kodierung (UTF-8 mit BOM) gespeichert werden, um eine perfekte Kompatibilität mit PowerShell 5.1 und internationalen Zeichen zu gewährleisten.

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
3.  Das Skript entfernt sauber alle geplanten Aufgaben und stellt die wichtigsten Systemeinstellungen wieder her.

**Hinweis zur Reversibilität:** Die Deinstallation entfernt nicht nur die geplanten Aufgaben. Sie stellt auch die wichtigsten Systemeinstellungen auf ihren Standardzustand zurück, um Ihnen ein sauberes System zu übergeben:
*   Windows-Updates werden wieder aktiviert.
*   Der Schnellstart wird wieder aktiviert.
*   Die Richtlinie zum Blockieren von OneDrive wird entfernt.
*   Das Skript wird Ihnen vorschlagen, die automatische Anmeldung zu deaktivieren.

Ihr System wird so wieder zu einer Standard-Workstation, ohne verbleibende Änderungen.

---

## ❤️ Lizenz und Beiträge
Dieses Projekt wird unter der **GPLv3**-Lizenz vertrieben. Der vollständige Text ist in der Datei `LICENSE` verfügbar.

Beiträge, sei es in Form von Fehlerberichten, Verbesserungsvorschlägen oder „Pull Requests“, sind willkommen.
