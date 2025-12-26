# WindowsOrchestrator 1.73

<p align="center">
  <img src="https://img.shields.io/badge/Version-v1.73-2ea44f" alt="Version">
  <img src="https://img.shields.io/badge/Licence-GPLv3-blue.svg" alt="Licence">
  <img src="https://img.shields.io/badge/Plateforme-Windows_10_|_11-0078D6" alt="OS Supportés">
  <img src="https://img.shields.io/badge/Architecture-x86_|_x64_|_ARM64-blueviolet" alt="Architecture CPU">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue" alt="Version PowerShell">
  <img src="https://img.shields.io/badge/Type-Portable_App-orange" alt="Sans Installation">
</p>

[🇺🇸 English](../../README.md) | [🇫🇷 Français](../fr-FR/README.md) | **🇩🇪 Deutsch** | [🇪🇸 Español](../es-ES/README.md)

## Beschreibung

**WindowsOrchestrator** ist eine PowerShell-Automatisierungs-Lösung, die einen standardmäßigen Windows-Arbeitsplatz in ein autonomes System ("Kiosk" oder "Appliance") verwandelt.

Sie ermöglicht die Konfiguration, Sicherung und Orchestrierung des Lebenszyklus des Betriebssystems. Sobald parametrisiert, stellt sie sicher, dass der Arbeitsplatz startet, eine Session öffnet und eine Geschäftsanwendung ohne menschliche Intervention startet, während sie die tägliche Wartung (Sicherung, Neustart) verwaltet.

## Anwendungsfälle und Zielpublikum

Standardmäßig ist Windows für menschliche Interaktion konzipiert (Anmeldebildschirm, Updates, Benachrichtigungen). WindowsOrchestrator entfernt diese Reibungen für dedizierte Verwendungen:

* **Dynamische Anzeige**: Werbetafeln, Informations-Panels, Menü-Boards.
* **Interaktive Terminals**: Ticketverkauf, Bestell-Terminals, Automaten.
* **Industrielle PCs**: Mensch-Maschine-Schnittstellen (HMI), Steuerautomaten in Produktionslinien.
* **Windows-Server**: Automatischer Start von Anwendungen, die eine persistente interaktive Session benötigen.

## Philosophie: Ein modularer Orchestrator

WindowsOrchestrator ist kein starres "Härtungs"-Skript. Es ist ein flexibles Tool, das sich an Ihren Bedarf anpasst.

* **Vollständige Flexibilität**: Keine Konfiguration wird erzwungen. Sie können den schnellen Start deaktivieren, ohne Windows Update zu berühren, oder umgekehrt.
* **Verantwortung**: Das Tool wendet strikt an, was Sie anfordern. Es ist für kontrollierte Umgebungen konzipiert, wo Stabilität vor kontinuierlichen funktionalen Updates priorisiert wird.
* **Architektur Multi-Kontexte**:
  * **Standard**: Behält den Windows-Anmeldebildschirm (Logon UI). Startet die Anwendung, sobald der Benutzer manuell angemeldet ist.
  * **Autologon**: Öffnet automatisch die Benutzer-Session und zeigt den Desktop an.

## Technische Philosophie: Nativer Ansatz

Der Orchestrator priorisiert Stabilität und die Verwendung nativer Windows-Mechanismen, um die Nachhaltigkeit der Konfigurationen zu gewährleisten.

* **Energie-Management "hart"**: Direkte Modifikation der AC/DC-Strompläne via `powercfg.exe`. Keine Simulation von Maus-/Tastatur-Aktivität.
* **Updates via GPO**: Verwendung der Registrierungsschlüssel `HKLM:\SOFTWARE\Policies` (Unternehmens-Methode) um gegen die Selbstreparatur-Mechanismen von Windows Update zu widerstehen.
* **Stabilität durch "Cold Boot"**: Deaktivierung des schnellen Starts (`HiberbootEnabled`) um einen vollständigen Neuladen von Treibern und Kernel bei jedem Neustart zu erzwingen.
* **Sicherheit von Anmeldedaten (LSA)**: Im Autologon-Modus wird das Passwort niemals im Klartext gespeichert. Der Orchestrator delegiert die Verschlüsselung an das Tool **Sysinternals Autologon**, das die Anmeldedaten in den Secrets LSA (Local Security Authority) von Windows speichert.

## Funktionale Fähigkeiten

### Session-Management (Autologon)
* Automatisierte Konfiguration des Winlogon-Registers.
* Integration des offiziellen Microsoft Sysinternals Autologon-Tools.
* Native Unterstützung der Architekturen x86, AMD64 und ARM64.
* Automatischer Download und Start des Tools für die Konfiguration von Anmeldedaten.

### Automatischer Start
* Verwendung des **Aufgabenplaners** (Trigger *AtLogon*) um den Start mit den entsprechenden Rechten zu garantieren.
* **Konsolen-Start-Modi**:
  * *Standard*: Verwendet das Standard-Terminal (z.B. Windows Terminal).
  * *Legacy*: Erzwingt die Verwendung von `conhost.exe` für Kompatibilität mit alten `.bat`-Skripten.
* Option, die Anwendung minimiert in der Taskleiste zu starten.

### Daten-Sicherung
* Intelligentes Sicherungsmodul, das vor dem Neustart ausgeführt wird.
* **Differenzielle Logik**: Kopiert nur Dateien, die in den letzten 24 Stunden modifiziert wurden.
* **Unterstützung gepaarter Dateien**: Ideal für Datenbanken (z.B. gleichzeitige Kopie von `.db`, `.db-wal`, `.db-shm`).
* **Aufbewahrungs-Politik**: Automatische Löschung von Archiven, die ein definiertes Alter überschreiten (Standard: 30 Tage).

### Umgebungs-Management des Systems
* **Windows Update**: Blockierung des Dienstes und Deaktivierung des erzwungenen Neustarts nach Update.
* **Fast Startup**: Deaktivierung für saubere Neustarts.
* **Stromversorgung**: Deaktivierung des Ruhezustands (S3/S4) und des Bildschirm-Ruhezustands.
* **OneDrive**: Drei Management-Modi (`Block` via GPO, `Close` den Prozess, oder `Ignore`).

### Aufgaben-Planung
* **Anwendungs-Schließung**: Senden von sauberen Schließbefehlen (z.B. {ESC}{ESC}x{ENTER} via API) zu einer bestimmten Zeit.
* **System-Neustart**: Vollständiger Neustart planmäßig täglich.
* **Sicherung**: Unabhängige Aufgabe, parallel zur Schließung ausgeführt.

### Stille Modus
* Installation und Deinstallation möglich ohne sichtbare Konsolen-Fenster (`-WindowStyle Hidden`).
* **Splash Screen**: Grafische Warteoberfläche mit Fortschrittsbalken, um den Benutzer zu beruhigen.
* **Feedback**: Endbenachrichtigung via Dialogbox (`MessageBox`) mit Erfolg oder Fehler.

### Internationalisierung & Benachrichtigungen
* **i18n**: Automatische Sprach-Erkennung des Systems (Native Unterstützung: `fr-FR`, `en-US`, `es-ES`, `de-DE`).
* **Gotify**: Optionales Modul für den Versand von Ausführungsberichten (Erfolg/Fehler) an einen Gotify-Server.

### Neue Funktionen v1.73

#### Dynamischer Launcher
* **Konfigurationsbasierter Start**: Liest `config.ini`, um dynamisch Anwendungsstartparameter, -modi und -pfade zu bestimmen, ohne feste Kodierung.
* **Flexible Ausführungsmodi**: Unterstützt mehrere Startstrategien basierend auf Konfiguration, einschließlich minimiertem Start und Konsolenauswahl.

#### Watchdog-Sicherheit
* **Prozessüberwachung**: Kontinuierliche Überwachung von gestarteten Anwendungsprozessen zur Erkennung von Fehlern oder Abstürzen.
* **Automatische Wiederherstellung**: Bei Erkennung von Prozessbeendigung aktiviert automatische Neustartmechanismen zur Aufrechterhaltung der Systembetriebszeit.
* **Gesundheitsprüfungen**: Periodische Überprüfung der Anwendungsreaktionsfähigkeit, um stille Fehler zu verhindern.

#### Zeitliche Intelligenz (Automatische Inferenz und Domino-Effekt)
* **Intelligente Planung**: Analysiert Nutzungsmuster und Systemzustände, um automatisch optimale Zeiten für Sicherungen, Neustarts und Wartung zu inferieren.
* **Domino-Effekt-Prävention**: Erkennt kaskadierende Abhängigkeiten zwischen Systemoperationen, um Konflikte zu vermeiden und sequentielle Ausführung zu gewährleisten.
* **Adaptives Verhalten**: Passt Zeitpläne basierend auf Echtzeit-Systemleistung und Anwendungsbedürfnissen an.

## Bereitstellungs-Prozedur

### Voraussetzungen
* **OS**: Windows 10 oder Windows 11 (Alle Editionen).
* **Rechte**: Administrator-Zugang erforderlich (für HKLM-Modifikation und Aufgaben-Erstellung).
* **PowerShell**: Version 5.1 oder höher.

### Installation

1. Downloaden und extrahieren Sie das Projekt-Archiv.
2. Führen Sie das Skript **`Install.bat`** aus (akzeptieren Sie die Berechtigungsanfrage).
3. Der **Konfigurations-Assistent** (`firstconfig.ps1`) öffnet sich:
   * Geben Sie den Pfad der zu startenden Anwendung ein.
   * Definieren Sie die Zeiten des täglichen Zyklus (Schließung / Sicherung / Neustart).
   * Aktivieren Sie Autologon falls nötig.
   * In der Registerkarte "Erweitert" konfigurieren Sie die Sicherung und den stillen Modus.
4. Klicken Sie auf **"Speichern und Schließen"**.
5. Die automatische Installation (`install.ps1`) übernimmt:
   * Erstellung der geplanten Aufgaben.
   * *Falls Autologon aktiviert*: Automatischer Download des Sysinternals-Tools und Öffnung des Fensters für die Passwort-Eingabe.

> **Hinweis**: Falls der Autologon-Modus mit `UseAutologonAssistant=true` aktiviert ist, versucht der Assistent, das Tool herunterzuladen. Falls der PC kein Internet hat, wird ein Dialog angezeigt, um die Datei `Autologon.zip` manuell auszuwählen.

### Deinstallation

1. Führen Sie das Skript **`Uninstall.bat`** aus.
2. Das Bereinigungs-Skript (`uninstall.ps1`) läuft:
   * Löschung aller geplanten `WindowsOrchestrator-*`-Aufgaben.
   * Wiederherstellung der Standardeinstellungen von Windows (Windows Update, Fast Startup, OneDrive).
   * *Falls Autologon erkannt*: Start des Autologon-Tools für eine saubere Deaktivierung (Bereinigung der LSA-Secrets).
   * Anzeige eines Endberichts.

> **Hinweis**: Aus Sicherheitsgründen werden die Konfigurationsdateien (`config.ini`) und Logs (`Logs/`) nicht automatisch gelöscht.

## Konfiguration und Beobachtbarkeit

### Konfigurationsdatei (`config.ini`)
Generiert in der Projekt-Root durch den Assistenten, steuert das gesamte System.
* `[SystemConfig]`: Kritische Parameter (Session, FastStartup, WindowsUpdate, OneDrive).
* `[Process]`: Pfade der Anwendung, Argumente, Zeiten, Prozess-Überwachung.
* `[DatabaseBackup]`: Aktivierung, Quell-/Ziel-Pfade, Aufbewahrung.
* `[Installation]`: Verhalten des Installers (Stiller Modus, Autologon-URL, Neustart nach Installation).
* `[Logging]`: Parameter der Log-Rotation.
* `[Gotify]`: Konfiguration der Push-Benachrichtigungen.

### Protokollierung
Der Orchestrator generiert detaillierte Logs für jede Operation.
* **Speicherort**: Ordner `Logs/` in der Projekt-Root.
* **Dateien**:
  * `config_systeme_ps_log.txt`: Aktionen des SYSTEM-Kontexts (Start, Hintergrund-Aufgaben).
  * `config_utilisateur_log.txt`: Aktionen in der Benutzer-Session (App-Start).
  * `Invoke-DatabaseBackup_log.txt`: Spezifischer Bericht der Sicherungen.
* **Rotation**: Beibehaltung der letzten 7 Dateien (konfigurierbar) um Festplatten-Sättigung zu vermeiden.
* **Fallback**: Falls der `Logs/`-Ordner unzugänglich ist, werden kritische Fehler in `C:\ProgramData\StartupScriptLogs` geschrieben.

### Geplante Aufgaben erstellt
Die Installation registriert die folgenden Aufgaben im Windows-Aufgabenplaner:
| Aufgaben-Name | Kontext | Trigger | Aktion |
| :--- | :--- | :--- | :--- |
| `WindowsOrchestrator-SystemStartup` | SYSTEM | System-Start | Wendet System-Konfiguration an (Power, Update...) |
| `WindowsOrchestrator-UserLogon` | Benutzer | Session-Öffnung | Startet die Geschäftsanwendung |
| `WindowsOrchestrator-SystemBackup` | SYSTEM | Geplante Zeit | Führt Daten-Sicherung aus |
| `WindowsOrchestrator-SystemScheduledReboot` | SYSTEM | Geplante Zeit | Startet den PC neu |
| `WindowsOrchestrator-User-CloseApp` | Benutzer | Geplante Zeit | Schließt die Anwendung sauber |

## Dokumentation

Für weitere Informationen konsultieren Sie die detaillierten Leitfäden:

📘 **[Benutzerhandbuch](BENUTZERHANDBUCH.md)**
*Zielpublikum: Systemadministratoren und Bereitstellungs-Techniker.*
Enthält Schritt-für-Schritt-Prozeduren, Bildschirmfotos des Assistenten und Fehlerbehebungs-Leitfäden.

🛠️ **[Entwickler-Leitfaden](ENTWICKLER_LEITFADEN.md)**
*Zielpublikum: Integratoren und Sicherheits-Auditoren.*
Detailliert die interne Architektur, Code-Analyse, LSA-Sicherheits-Mechanismen und Modul-Struktur.

## Konformität und Sicherheit

* **Lizenz**: Dieses Projekt wird unter **GPLv3**-Lizenz vertrieben. Siehe `LICENSE`-Datei für Details.
* **Abhängigkeiten**:
  * Das Projekt ist eigenständig ("Portable App").
  * Die Aktivierung von Autologon lädt das Tool **Microsoft Sysinternals Autologon** herunter (unterliegt seiner eigenen EULA, die der Benutzer bei der Installation akzeptieren muss).
* **Datensicherheit**:
  * WindowsOrchestrator speichert **keine Passwörter** im Klartext in seinen Konfigurationsdateien.
  * Die Privilegien sind abgeschottet: Das Benutzer-Skript kann keine System-Parameter ändern.

## Beitrag und Support

Dieses Projekt wird in der Freizeit entwickelt und geteilt.
* **Bugs**: Falls Sie einen technischen Bug finden, melden Sie ihn bitte via **GitHub Issues**.
* **Beiträge**: Pull Requests sind willkommen, um das Tool zu verbessern.
