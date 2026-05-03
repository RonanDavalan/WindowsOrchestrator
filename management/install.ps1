param()

Add-Type -AssemblyName System.Windows.Forms

<#
.SYNOPSIS
    Installe et configure les tâches planifiées pour les scripts de configuration système et utilisateur.
.DESCRIPTION
    Ce script s'assure d'être exécuté en tant qu'administrateur et utilise la méthode de chargement de langue
    qui a été prouvée fonctionnelle.
.EXAMPLE
    PS C:\Chemin\Vers\Script\> .\install.ps1

    Lance le script d'installation. Le script demandera automatiquement une élévation de privilèges si nécessaire.
.NOTES
    Projet      : WindowsOrchestrator
    Version     : 1.74
    Licence     : GNU GPLv3

    --- CRÉDITS & RÔLES ---
    Ce projet est le fruit d'une collaboration hybride Humain-IA :

    Direction Produit & Spécifications  : Ronan Davalan
    Architecte Principal & QA           : Ronan Davalan
    Architecte IA & Planification       : Google Gemini
    Développeur IA Principal            : Grok (xAI)
    Consultant Technique IA             : Claude (Anthropic)
#>

# --- 1. Initialisation de l'Environnement (I18N & Modules) ---
$cultureName = (Get-Culture).Name
$lang = @{}
$ErrorActionPreference = "Stop" # Arrêt immédiat en cas d'erreur

try {
    # 1. Définition des Chemins (Nettoyage de la logique)
    # $PSScriptRoot est le dossier où se trouve ce script (donc 'management')
    $ScriptDir = $PSScriptRoot

    # Le dossier racine du projet est juste au-dessus (..)
    $ProjectRootDir = (Resolve-Path (Join-Path $ScriptDir "..\")).Path

    # CORRECTION DES CHEMINS : On pointe directement les fichiers à côté de nous
    $SystemScriptPath = Join-Path $ScriptDir "config_systeme.ps1"
    $UserScriptPath   = Join-Path $ScriptDir "config_utilisateur.ps1"
    $ConfigFile       = Join-Path $ProjectRootDir "config.ini"

    # 2. Chargement du Module (La boîte à outils)
    $modulePath = Join-Path $ScriptDir "modules\WindowsOrchestratorUtils\WindowsOrchestratorUtils.psm1"

    # Vérification physique avant chargement
    if (-not (Test-Path $modulePath)) {
        throw "Le module est introuvable ici : $modulePath"
    }
    Import-Module $modulePath -Force

    # 3. Chargement de la Langue (Via le module)
    $lang = Set-OrchestratorLanguage -ScriptRoot $ScriptDir

    # 4. Vérification du Mode Silencieux (Pour l'affichage d'attente)
    $silentMode = $false
    if (Test-Path $ConfigFile) {
        $config = Get-IniContent -FilePath $ConfigFile
        $silentMode = Get-ConfigValue -Section "Installation" -Key "SilentMode" -Type ([bool]) -DefaultValue $false
    }

    # Si silencieux, on lance la petite fenêtre d'attente
    if ($silentMode) { Start-WaitingUI -Message $lang.Install_SplashMessage }

} catch {
    # --- FILET DE SÉCURITÉ ANTI-FLASH ---
    # Si une erreur survient ci-dessus, on l'affiche en ROUGE et on ATTEND.
    Write-Host "ERREUR FATALE D'INITIALISATION :" -ForegroundColor Red
    Write-Host "$($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Chemin détecté : $ScriptDir" -ForegroundColor Yellow

    # C'est cette ligne qui empêche la fenêtre de se fermer tout de suite
    Read-Host "Appuyez sur Entrée pour quitter..."
    exit 1
}

# --- Configuration et Vérifications Préliminaires ---
# --- 2. Vérifications et Préparation ---
$OriginalErrorActionPreference = $ErrorActionPreference
$errorOccurredInScript = $false

try {
    # A. Vérification critique des fichiers
    # (On utilise les chemins sécurisés calculés au Bloc 1)
    if (-not (Test-Path $ConfigFile)) {
        throw ($lang.Install_InvalidProjectRootError -f $ProjectRootDir)
    }
    if (-not (Test-Path $SystemScriptPath)) {
        throw ($lang.Install_MissingSystemFile -f $SystemScriptPath)
    }
    if (-not (Test-Path $UserScriptPath)) {
        throw ($lang.Install_MissingUserFile -f $UserScriptPath)
    }

    # B. Définition des constantes
    $TaskNameSystem = "WindowsOrchestrator-SystemStartup"
    $TaskNameUser   = "WindowsOrchestrator-UserLogon"

    Write-StyledHost ($lang.Install_ProjectRootUsed -f $ProjectRootDir) "INFO"

    # C. Cible : Domaine\Utilisateur
    $TargetUserForUserTask = "$($env:USERDOMAIN)\$($env:USERNAME)"
    Write-StyledHost ($lang.Install_UserTaskTarget -f $TargetUserForUserTask) "INFO"

    # D. Consolidation de l'Utilisateur dans config.ini
    # Si l'utilisateur n'a rien mis dans 'AutoLoginUsername', on met l'utilisateur courant.
    $iniContent = Get-IniContent -FilePath $ConfigFile
    $currentConfigUser = if ($iniContent.SystemConfig.ContainsKey("AutoLoginUsername")) { $iniContent.SystemConfig.AutoLoginUsername } else { "" }

    if ([string]::IsNullOrWhiteSpace($currentConfigUser)) {
        Write-StyledHost $lang.Install_AutoLoginUserEmpty "INFO"

        # On utilise la fonction du module pour écrire proprement dans le INI
        Set-IniValue -FilePath $ConfigFile -Section "SystemConfig" -Key "AutoLoginUsername" -Value $env:USERNAME

        Write-StyledHost ($lang.Install_AutoLoginUserUpdated -f $env:USERNAME) "SUCCESS"
    }
    # --- Fin de la consolidation ---

    # --- Lecture de la configuration pour la gestion de session ---
    $config = Get-IniContent -FilePath (Join-Path $ProjectRootDir "config.ini")
    $sessionMode = if ($config.ContainsKey("SystemConfig")) { $config["SystemConfig"]["SessionStartupMode"] } else { "Standard" }
    $targetUsernameForConfig = if ($config.ContainsKey("SystemConfig")) { $config["SystemConfig"]["AutoLoginUsername"] } else { $env:USERNAME }
    if ([string]::IsNullOrWhiteSpace($targetUsernameForConfig)) { $targetUsernameForConfig = $env:USERNAME }

    # --- 3. Assistant Autologon (Si requis) ---

    # Lecture sécurisée de la configuration
    $sessionMode = Get-ConfigValue -Section "SystemConfig" -Key "SessionStartupMode" -DefaultValue "Standard"
    $useAssistant = Get-ConfigValue -Section "Installation" -Key "UseAutologonAssistant" -Type ([bool]) -DefaultValue $true

    if (($sessionMode -eq 'Autologon') -and $useAssistant) {

        $winlogonKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        $autoLogonStatus = (Get-ItemProperty -Path $winlogonKey -Name 'AutoAdminLogon' -ErrorAction SilentlyContinue).AutoAdminLogon

        # A. Vérification si déjà actif
        if ($autoLogonStatus -eq '1') {
            Write-StyledHost $lang.Install_AutologonAlreadyActive "INFO"
        } else {
            # B. Préparation du téléchargement
            $autologonUrl = Get-ConfigValue -Section "Installation" -Key "AutologonDownloadUrl" -DefaultValue "https://live.sysinternals.com/files/AutoLogon.zip"
            $toolsDir = Join-Path $ScriptDir "tools"
            $targetDir = Join-Path $toolsDir "Autologon"
            $zipPath = Join-Path $toolsDir "Autologon.zip"

            # C. Détection Architecture
            $exeName = switch ($env:PROCESSOR_ARCHITECTURE) {
                'x86'   { 'Autologon.exe' }
                'AMD64' { 'Autologon64.exe' }
                'ARM64' { 'Autologon64a.exe' }
                default { throw ($lang.Install_UnsupportedArchitectureError -f $env:PROCESSOR_ARCHITECTURE) }
            }
            $exePath = Join-Path $targetDir $exeName
            $eulaPath = Join-Path $targetDir "Eula.txt"

            # Fonction de nettoyage en cas d'échec
            $cleanExit = {
                if (Test-Path $targetDir) { Remove-Item -Path $targetDir -Recurse -Force -ErrorAction SilentlyContinue }
                if (Test-Path $zipPath) { Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue }
            }

            try {
                # D. Téléchargement (si absent)
                if (-not (Test-Path $exePath)) {
                    Write-StyledHost $lang.Install_DownloadingAutologon "INFO"
                    if (-not (Test-Path $toolsDir)) { New-Item -Path $toolsDir -ItemType Directory | Out-Null }

                    # Téléchargement
                    Invoke-WebRequest -Uri $autologonUrl -OutFile $zipPath -UseBasicParsing -ErrorAction Stop

                    # Extraction
                    Write-StyledHost $lang.Install_ExtractingArchive "INFO"
                    Expand-Archive -Path $zipPath -DestinationPath $targetDir -Force -ErrorAction Stop
                    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
                }

                if (-not (Test-Path $exePath)) { throw ($lang.Install_AutologonFilesMissing -f $exeName) }

                # E. Interactions Utilisateur (Gestion du Splash Screen)
                $skipEula = Get-ConfigValue -Section "Installation" -Key "SkipEulaPrompt" -Type ([bool]) -DefaultValue $false

                # --- PAUSE UI : On doit montrer des fenêtres ---
                if ($silentMode) { Stop-WaitingUI }

                # 1. EULA (Licence)
                if (-not $skipEula) {
                    Write-StyledHost $lang.Install_PromptReviewEula "INFO"
                    Start-Process notepad.exe -ArgumentList $eulaPath -Wait

                    $consent = [System.Windows.Forms.MessageBox]::Show($lang.Install_EulaConsentMessage, $lang.Install_EulaConsentCaption, 'YesNo', 'Question')

                    if ($consent -ne 'Yes') {
                        # Si refus, on relance l'UI pour quitter proprement
                        if ($silentMode) { Start-WaitingUI -Message $lang.Install_SplashMessage }
                        throw $lang.Install_EulaConsentRefused
                    }
                }

                # 2. Lancement de l'outil
                Write-StyledHost $lang.Install_PromptUseAutologonTool "INFO"

                # On lance l'outil et ON ATTEND qu'il soit fermé
                Start-Process -FilePath $exePath -ArgumentList '-accepteula' -Wait

                # --- REPRISE UI : Fin des interactions ---
                if ($silentMode) { Start-WaitingUI -Message $lang.Install_SplashMessage }

                Write-StyledHost $lang.Install_AutologonSuccess "SUCCESS"

            } catch {
                # Gestion des erreurs Autologon
                # Si c'est un refus de licence, on log en Warning. Sinon en Error.
                if ($_.Exception.Message -eq $lang.Install_EulaConsentRefused) {
                    Write-StyledHost $_.Exception.Message "WARNING"
                } else {
                    Write-StyledHost ($lang.Install_AutologonDownloadFailed + " " + $_.Exception.Message) "ERROR"

                    # Proposition de secours manuelle
                    $resp = [System.Windows.Forms.MessageBox]::Show($lang.Install_ConfirmContinueWithoutAutologon, "Autologon Error", 'YesNo', 'Warning')
                    if ($resp -eq 'No') {
                        & $cleanExit
                        exit 1 # Arrêt complet demandé par l'utilisateur
                    }
                }
                & $cleanExit # Nettoyage des fichiers temporaires
                # On continue l'installation sans Autologon
            }
        }
    }


    # --- 4. Installation des Tâches Planifiées ---
    Write-StyledHost $lang.Install_StartConfiguringTasks "INFO"

    # Préparation des arguments pour PowerShell
    # Note : On utilise les chemins absolus calculés au Bloc 1 pour éviter toute ambiguïté
    $finalArgumentSystem = "-NoProfile -ExecutionPolicy Bypass -File `"$SystemScriptPath`""
    $finalArgumentUser   = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$UserScriptPath`""

    # A. Tâche Système (Au démarrage de l'ordi)
    $ActionSystem = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $finalArgumentSystem -WorkingDirectory $ScriptDir
    $TriggerSystem = New-ScheduledTaskTrigger -AtStartup
    $PrincipalSystem = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -RunLevel Highest
    $SettingsSystem = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 2)

    Register-ScheduledTask -TaskName $TaskNameSystem -Action $ActionSystem -Trigger $TriggerSystem -Principal $PrincipalSystem -Settings $SettingsSystem -Description $lang.Install_SystemTaskDescription -Force -ErrorAction Stop
    Write-StyledHost ($lang.Install_SystemTaskConfiguredSuccess -f $TaskNameSystem) "SUCCESS"


    $ActionUser = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $finalArgumentUser -WorkingDirectory $ScriptDir
    $TriggerUser = New-ScheduledTaskTrigger -AtLogOn -User $TargetUserForUserTask
    $SettingsUser = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 1)

    # Création de la tâche utilisateur (Toujours en interactif pour l'UI)
    try {
        $PrincipalUser = New-ScheduledTaskPrincipal -UserId $TargetUserForUserTask -LogonType Interactive
        Register-ScheduledTask -TaskName $TaskNameUser -Action $ActionUser -Trigger $TriggerUser -Principal $PrincipalUser -Settings $SettingsUser -Description $lang.Install_UserTaskDescription -Force -ErrorAction Stop
        Write-StyledHost ($lang.Install_SystemTaskConfiguredSuccess -f $TaskNameUser) "SUCCESS"
    } catch {
        throw ($lang.Install_CriticalErrorDuringInstallation -f $_.Exception.Message)
    }

    Write-Host "`n"
    Write-StyledHost $lang.Install_MainTasksConfigured "INFO"

    # --- 5. Exécution Initiale et Lancement ---
    Write-StyledHost $lang.Install_AttemptingInitialLaunch "INFO"

    # Création du dossier de logs s'il n'existe pas
    $logDirectory = Join-Path $ProjectRootDir "Logs"
    if (-not (Test-Path $logDirectory)) { New-Item -Path $logDirectory -ItemType Directory -Force | Out-Null }

    # A. Lancement du Script Système (Bloquant)
    if (-not $errorOccurredInScript) {
        Write-StyledHost $lang.Install_ExecutingSystemScript "INFO"

        # On lance le script système et on attend qu'il finisse
        $proc = Start-Process -FilePath "powershell.exe" -ArgumentList $finalArgumentSystem -WorkingDirectory $ScriptDir -Wait -PassThru -ErrorAction Stop

        if ($proc.ExitCode -eq 0) {
            Write-StyledHost $lang.Install_SystemScriptSuccess "SUCCESS"
        } else {
            Write-StyledHost ($lang.Install_SystemScriptWarning -f $proc.ExitCode, $ProjectRootDir) "WARNING"
            $errorOccurredInScript = $true
        }
    }

    # =========================================================================
    # CORRECTIF V1.73 : LANCEMENT DE LA SÉQUENCE UTILISATEUR (Retour Logique v1.72)
    # =========================================================================
    # Si on ne redémarre pas, on déclenche la tâche utilisateur pour lancer l'appli maintenant.
    $rebootConfig = Get-ConfigValue -Section "Installation" -Key "RebootOnCompletion" -Type ([bool]) -DefaultValue $false

    if ((-not $rebootConfig) -and (-not $errorOccurredInScript)) {
        Write-StyledHost "Déclenchement immédiat de la configuration utilisateur..." "INFO"
        try {
            # C'est ici la magie : on dit à Windows "Fais comme si l'utilisateur venait de se connecter"
            Start-ScheduledTask -TaskName $TaskNameUser -ErrorAction Stop
            Write-StyledHost $lang.Install_UserConfigLaunched "SUCCESS"
        } catch {
            Write-StyledHost "Attention : Impossible de lancer la tâche utilisateur automatiquement ($($_.Exception.Message))" "WARNING"
        }
    }

    if (-not $errorOccurredInScript) {
        Write-StyledHost $lang.Install_InstallationCompleteSuccess "SUCCESS"
    }

} catch {
    # --- GESTION D'ERREUR GLOBALE (Anti-Flash) ---
    $errorOccurredInScript = $true
    Write-Host "`n===================================================" -ForegroundColor Red
    Write-Host " UNE ERREUR CRITIQUE EST SURVENUE" -ForegroundColor Red
    Write-Host "===================================================" -ForegroundColor Red
    Write-StyledHost ($lang.Install_CriticalErrorDuringInstallation -f $_.Exception.Message) "ERROR"
    Write-Host "Trace : $($_.ScriptStackTrace)" -ForegroundColor DarkGray

    # PAUSE OBLIGATOIRE si on n'est pas en mode silencieux
    if (-not $silentMode) {
        Write-Host "`n"
        Read-Host "Appuyez sur ENTRÉE pour fermer la fenêtre..."
    }

} finally {
    # Nettoyage de l'interface d'attente
    Stop-WaitingUI

    # Notification finale en Mode Silencieux (MessageBox)
    if ($silentMode) {
        Add-Type -AssemblyName System.Windows.Forms

        if ($errorOccurredInScript) {
            [System.Windows.Forms.MessageBox]::Show($lang.Install_SilentMode_CompletedWithErrors, "Installation", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
        } else {
            [System.Windows.Forms.MessageBox]::Show($lang.Install_SilentMode_CompletedSuccessfully, "Installation", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        }
    }

    # Gestion de la sortie (Redémarrage ou Fermeture)
    Invoke-ExitLogic -Config $config -Lang $lang
}
