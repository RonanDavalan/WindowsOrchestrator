# =================================================================================================
# MODULE UTILITAIRE CENTRAL - WINDOWSORCHESTRATOR
# =================================================================================================
#
# DESCRIPTION:
#   Ce module regroupe toutes les fonctions communes utilisées par les différents scripts
#   de l'orchestrateur (installation, configuration, désinstallation).
#   Le centraliser ici permet de simplifier la maintenance et d'éviter la duplication de code.
#
# FONCTIONS EXPORTÉES:
#   - Set-OrchestratorLanguage: Charge les fichiers de langue (i18n).
#   - Get-IniContent: Lit et parse les fichiers de configuration .ini.
#   - Write-StyledHost: Affiche des messages formatés dans la console.
#   - Get-ConfigValue: Récupère les valeurs de configuration de manière sécurisée.
#
#   Projet      : WindowsOrchestrator
#   Version     : 1.72
#   Licence     : GNU GPLv3
#
# CRÉDITS & RÔLES
#   Ce projet est le fruit d'une collaboration hybride Humain-IA :
#
#   Architecte Principal & QA      : Ronan Davalan
#   Architecte IA & Planification  : Google Gemini
#   Développeur IA Principal       : Grok (xAI)
#   Consultant Technique IA        : Claude (Anthropic)
#
# =================================================================================================

function Set-OrchestratorLanguage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ScriptRoot
    )

    $lang = @{}
    try {
        $projectRoot = (Resolve-Path (Join-Path $ScriptRoot "..\")).Path
        
        # DÉTECTION AUTOMATIQUE PURE (Source de vérité système)
        $cultureName = (Get-Culture).Name

        # CHARGEMENT
        $langFilePath = Join-Path $projectRoot "i18n\$cultureName\strings.psd1"
        
        # Fallback : Si la langue précise n'existe pas, on tente l'anglais (en-US)
        if (-not (Test-Path $langFilePath)) {
             $langFilePath = Join-Path $projectRoot "i18n\en-US\strings.psd1"
        }

        if (Test-Path $langFilePath) {
            $langContent = Get-Content -Path $langFilePath -Raw -Encoding UTF8
            $lang = Invoke-Expression $langContent
        } else {
            throw "Aucun fichier de langue valide trouvé (ni pour '$cultureName', ni en-US)."
        }

        if ($null -eq $lang -or $lang.Count -eq 0) {
            throw "Le fichier de langue '$langFilePath' est vide ou invalide."
        }

        return $lang
    } catch {
        throw "FATAL ERROR: Could not load language files. Details: $($_.Exception.Message)"
    }
}

function Get-IniContent {
    param($FilePath)
    $ini = @{}
    if (-not (Test-Path $FilePath -PathType Leaf)) { return $ini }
    $section = ""
    Get-Content $FilePath -Encoding UTF8 | ForEach-Object {
        $line = $_.Trim()
        if ($line -match '^\[(.+)\]$') {
            $section = $matches[1]
            $ini[$section] = @{}
        } elseif ($line -match '^([^=]+)=(.*)$' -and $section) {
            $ini[$section][$matches[1].Trim()] = $matches[2].Trim()
        }
    }
    return $ini
}

function Write-StyledHost {
    param([string]$Message, [string]$Type = "INFO")
    $color = switch ($Type.ToUpper()) { "INFO"{"Cyan"}; "SUCCESS"{"Green"}; "WARNING"{"Yellow"}; "ERROR"{"Red"}; default{"White"} }
    Write-Host "[$Type] " -ForegroundColor $color -NoNewline; Write-Host $Message
}

<#
.SYNOPSIS
    Récupère de manière sécurisée une valeur depuis l'objet de configuration global.
.DESCRIPTION
    Cette fonction est le moyen standard pour interroger la configuration chargée depuis config.ini. Elle gère les cas
    où la section ou la clé n'existe pas, fournit des valeurs par défaut, et effectue une conversion de type
    sécurisée (ex: de chaîne vers booléen ou entier), tout en enregistrant une erreur en cas d'échec de la conversion.
.PARAMETER Section
    Le nom de la section INI (ex: "SystemConfig").
.PARAMETER Key
    Le nom de la clé dans la section (ex: "DisableFastStartup").
.PARAMETER DefaultValue
    La valeur à retourner si la clé n'est pas trouvée.
.PARAMETER Type
    Le type de données vers lequel convertir la valeur (ex: [bool], [int]).
.RETURN
    La valeur convertie, la valeur par défaut, ou $null.
.EXAMPLE
    PS C:\> $disableUpdates = Get-ConfigValue -Section "SystemConfig" -Key "DisableWindowsUpdate" -Type ([bool]) -DefaultValue $false
.NOTES
    Auteurs et Collaboration (v1.72)

    Ce projet est le fruit d'une collaboration tripartite :
    - Chef de Projet & Assurance Qualité : Ronan Davalan
    - Architecte IA & Planification : Google Gemini
    - Implémentation du Code : Grok
#>
function Get-ConfigValue {
    param(
        [string]$Section,
        [string]$Key,
        [object]$DefaultValue = $null,
        [System.Type]$Type = ([string]),
        [bool]$KeyMustExist = $false
    )

    $value = $null
    $keyExists = $false
    if ($null -ne $Global:Config) {
        $keyExists = $Global:Config.ContainsKey($Section) -and $Global:Config[$Section].ContainsKey($Key)
        if ($keyExists) {
            $value = $Global:Config[$Section][$Key]
        }
    }

    if ($KeyMustExist -and (-not $keyExists)) {
        return [pscustomobject]@{ Undefined = $true }
    }

    if (-not $keyExists) {
        if ($null -ne $DefaultValue) { return $DefaultValue }
        if ($Type -eq ([bool])) { return $false }
        if ($Type -eq ([int])) { return 0 }
        return $null
    }

    if ([string]::IsNullOrWhiteSpace($value) -and $Type -eq ([bool])) {
        if ($null -ne $DefaultValue) { return $DefaultValue }
        return $false
    }

    try {
        return [System.Convert]::ChangeType($value, $Type)
    }
    catch {
        Add-Error -DefaultErrorMessage "Invalid config value for [$($Section)]$($Key): '$value'. Expected type '$($Type.Name)'. Default/empty value used." -ErrorId "Error_InvalidConfigValue" -ErrorArgs $Section, $Key, $value, $Type.Name
        if ($null -ne $DefaultValue) { return $DefaultValue }
        if ($Type -eq ([bool])) { return $false }
        if ($Type -eq ([int])) { return 0 }
        return $null
    }
}

<#
.SYNOPSIS
    Écrit ou met à jour une valeur dans un fichier de configuration au format INI.
.DESCRIPTION
    Cette fonction robuste modifie un fichier .ini. Elle peut créer le fichier s'il n'existe pas,
    ajouter une nouvelle section, ajouter une nouvelle clé dans une section existante, ou simplement
    mettre à jour la valeur d'une clé existante.
.PARAMETER FilePath
    Chemin complet vers le fichier .ini à modifier.
.PARAMETER Section
    Le nom de la section (ex: "[SystemConfig]") dans laquelle écrire.
.PARAMETER Key
    Le nom de la clé à écrire ou à mettre à jour.
.PARAMETER Value
    La valeur à assigner à la clé.
.EXAMPLE
    PS C:\> Set-IniValue -FilePath "C:\temp\config.ini" -Section "Process" -Key "ProcessName" -Value "chrome.exe"
#>
function Set-IniValue {
    param($FilePath, $Section, $Key, $Value)
    $fileExists = Test-Path $FilePath -PathType Leaf
    $iniContent = if ($fileExists) { Get-Content $FilePath -Encoding UTF8 -ErrorAction SilentlyContinue } else { [string[]]@() }
    $newContent = [System.Collections.Generic.List[string]]::new()
    $sectionExists = $false; $keyExists = $false; $inTargetSection = $false
    foreach ($line in $iniContent) {
        if ($line.Trim() -eq "[$Section]") {
            $sectionExists = $true; $inTargetSection = $true
            $newContent.Add($line)
        } elseif ($line.Trim().StartsWith("[")) {
            if ($inTargetSection -and -not $keyExists) { $newContent.Add("$Key=$Value"); $keyExists = $true }
            $inTargetSection = $false
            $newContent.Add($line)
        } elseif ($inTargetSection -and $line -match "^$([regex]::Escape($Key))\s*=") {
            $newContent.Add("$Key=$Value"); $keyExists = $true
        } else { $newContent.Add($line) }
    }
    if ($inTargetSection -and -not $keyExists) {
         $newContent.Add("$Key=$Value"); $keyExists = $true
    }
    if (-not $sectionExists) {
        if ($newContent.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($newContent[$newContent.Count -1])) { $newContent.Add("") }
        $newContent.Add("[$Section]"); $newContent.Add("$Key=$Value")
    } elseif (-not $keyExists) {
        $sectionIndex = -1; for ($i = 0; $i -lt $newContent.Count; $i++) { if ($newContent[$i].Trim() -eq "[$Section]") { $sectionIndex = $i; break }}
        if ($sectionIndex -ne -1) {
            $insertAt = $sectionIndex + 1
            while ($insertAt -lt $newContent.Count -and -not $newContent[$insertAt].Trim().StartsWith("[")) { $insertAt++ }
            $newContent.Insert($insertAt, "$Key=$Value")
        } else { $newContent.Add("$Key=$Value") }
    }
    $ParentDir = Split-Path -Path $FilePath -Parent
    if (-not (Test-Path $ParentDir -PathType Container)) {
        New-Item -Path $ParentDir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    }
    Out-File -FilePath $FilePath -InputObject $newContent -Encoding utf8 -Force
}

<#
.SYNOPSIS
    Écrit un message dans le journal avec un niveau de sévérité spécifié.
.DESCRIPTION
    Cette fonction écrit un message formaté dans le fichier journal et optionnellement dans la console.
    Elle utilise les fichiers de langue pour les messages internationalisés.
.PARAMETER DefaultMessage
    Le message par défaut si la clé de langue n'est pas trouvée.
.PARAMETER MessageId
    L'identifiant du message dans le fichier de langue.
.PARAMETER MessageArgs
    Les arguments à substituer dans le message.
.PARAMETER Level
    Le niveau de sévérité (INFO, WARN, ERROR, DEBUG).
.PARAMETER NoConsole
    Si spécifié, n'affiche pas dans la console.
.EXAMPLE
    Write-Log -DefaultMessage "Action completed" -Level "INFO"
#>
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$DefaultMessage,
        [string]$MessageId,
        [object[]]$MessageArgs,
        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")][string]$Level = "INFO",
        [switch]$NoConsole
    )

    process {
        $messageTemplate = if ($Global:lang -and $Global:lang.ContainsKey($MessageId)) { $Global:lang[$MessageId] } else { $DefaultMessage }

        try {
            $formattedMessage = $messageTemplate -f $MessageArgs
        } catch {
            $formattedMessage = $messageTemplate
        }

        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "$timestamp [$Level] - $formattedMessage"

        $LogParentDir = Split-Path $Global:LogFile -Parent
        if (-not (Test-Path -Path $LogParentDir -PathType Container)) {
            try {
                New-Item -Path $LogParentDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
            } catch {
                # Ne peut pas créer le dossier de log, va utiliser le fallback
            }
        }

        try {
            Add-Content -Path $Global:LogFile -Value $logEntry -Encoding UTF8 -ErrorAction Stop
        }
        catch {
            $fallbackLogDir = "C:\ProgramData\StartupScriptLogs"
            if (-not (Test-Path $fallbackLogDir)) {
                try {
                    New-Item $fallbackLogDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
                } catch {
                    # Ne peut même pas créer le dossier de fallback, affichera uniquement dans la console
                }
            }
            $fallbackLogFile = Join-Path $fallbackLogDir "config_systeme_ps_FATAL_LOG_ERROR.txt"
            $fallbackMessage = "$timestamp [FATAL_LOG_ERROR] - Could not write to '$Global:LogFile': $($_.Exception.Message). Original: $logEntry"
            Write-Host $fallbackMessage -ForegroundColor Red
            try {
                Add-Content $fallbackLogFile $fallbackMessage -Encoding UTF8 -ErrorAction Stop
            } catch {
                # La dernière tentative a échoué, l'erreur a déjà été écrite dans la console.
            }
        }

        if (-not $NoConsole -and ($Host.Name -eq "ConsoleHost" -or $PSEdition -eq "Core")) {
            Write-Host $logEntry
        }
    }
}

<#
.SYNOPSIS
    Enregistre une action effectuée par le script dans une liste globale et dans le journal.
.DESCRIPTION
    Wrapper pour Write-Log qui ajoute un message formaté à la liste globale $Global:ActionsEffectuees.
    Cette liste est utilisée à la fin du script pour construire un rapport de synthèse.
.PARAMETER DefaultActionMessage
    Le message d'action par défaut.
.PARAMETER ActionId
    L'identifiant du message d'action dans le fichier de langue.
.PARAMETER ActionArgs
    Les arguments pour le message d'action.
.EXAMPLE
    Add-Action -DefaultActionMessage "Service started" -ActionId "Action_ServiceStarted" -ActionArgs "wuauserv"
#>
function Add-Action {
    param(
        [string]$DefaultActionMessage,
        [string]$ActionId,
        [object[]]$ActionArgs
    )

    $messageTemplate = if ($Global:lang -and $Global:lang.ContainsKey($ActionId)) { $Global:lang[$ActionId] } else { $DefaultActionMessage }
    $formattedMessage = try { $messageTemplate -f $ActionArgs } catch { $messageTemplate }

    $Global:ActionsEffectuees.Add($formattedMessage)
    Write-Log -DefaultMessage "ACTION: $formattedMessage" -Level "INFO" -NoConsole
}

<#
.SYNOPSIS
    Enregistre une erreur survenue pendant l'exécution dans une liste globale et dans le journal.
.DESCRIPTION
    Wrapper pour Write-Log qui ajoute un message d'erreur formaté à la liste globale $Global:ErreursRencontrees.
    Cette liste est utilisée pour déterminer si le script s'est terminé avec des erreurs.
.PARAMETER DefaultErrorMessage
    Le message d'erreur par défaut.
.PARAMETER ErrorId
    L'identifiant du message d'erreur dans le fichier de langue.
.PARAMETER ErrorArgs
    Les arguments pour le message d'erreur.
.EXAMPLE
    Add-Error -DefaultErrorMessage "Failed to start service" -ErrorId "Error_ServiceStartFailed" -ErrorArgs "wuauserv"
#>
function Add-Error {
    [CmdletBinding()]
    param (
        [string]$DefaultErrorMessage,
        [string]$ErrorId,
        [object[]]$ErrorArgs
    )

    $messageTemplate = if ($Global:lang -and $Global:lang.ContainsKey($ErrorId)) { $Global:lang[$ErrorId] } else { $DefaultErrorMessage }
    $formattedMessage = try { $messageTemplate -f $ErrorArgs } catch { $messageTemplate }

    $detailedErrorMessage = if ([string]::IsNullOrWhiteSpace($formattedMessage) -and $global:Error.Count -gt 0) {
        "Unspecified PowerShell error: $($global:Error[0].Exception.Message) - Stack: $($global:Error[0].ScriptStackTrace)"
    } else {
        $formattedMessage
    }

    $Global:ErreursRencontrees.Add($detailedErrorMessage)
    Write-Log -DefaultMessage "CAPTURED ERROR: $detailedErrorMessage" -MessageId "Log_CapturedError" -MessageArgs $detailedErrorMessage -Level "ERROR"
}

<#
.SYNOPSIS
    Gère la rotation des fichiers logs (archivage et suppression des anciens).
#>
function Invoke-LogFileRotation {
    param(
        [string]$BaseLogPath,
        [string]$LogExtension = ".txt",
        [int]$MaxLogsToKeep = 7
    )

    $logFiles = Get-ChildItem -Path "$BaseLogPath*$LogExtension" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending

    if ($logFiles.Count -gt $MaxLogsToKeep) {
        $filesToDelete = $logFiles | Select-Object -Skip $MaxLogsToKeep
        $filesToDelete | Remove-Item -Force -ErrorAction SilentlyContinue
    }

    for ($i = $MaxLogsToKeep - 1; $i -ge 1; $i--) {
        $currentFile = "$BaseLogPath.$i$LogExtension"
        $nextFile = "$BaseLogPath." + ($i + 1) + $LogExtension
        if (Test-Path $currentFile) {
            Move-Item -Path $currentFile -Destination $nextFile -Force -ErrorAction SilentlyContinue
        }
    }

    $baseFile = "$BaseLogPath$LogExtension"
    if (Test-Path $baseFile) {
        Move-Item -Path $baseFile -Destination "$BaseLogPath.1$LogExtension" -Force -ErrorAction SilentlyContinue
    }
}

function Start-OrchestratorProcess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$ProcessToLaunch,
        [string]$ProcessArguments,
        [string]$ProcessToMonitor,
        [Parameter(Mandatory=$true)][string]$ScriptDir,
        [Parameter(Mandatory=$true)][ValidateSet("System", "User")][string]$Context
    )

    try {
        $expandedLaunchPath = $ProcessToLaunch
        if (-not ([System.IO.Path]::IsPathRooted($expandedLaunchPath))) {
            $expandedLaunchPath = [System.IO.Path]::GetFullPath((Join-Path $ScriptDir $expandedLaunchPath))
        }

        $extension = [System.IO.Path]::GetExtension($expandedLaunchPath).ToLower()
        $launchConsoleMode = Get-ConfigValue -Section "Process" -Key "LaunchConsoleMode" -DefaultValue "Standard"
        $launchMethod = "direct"
        $startProcessSplat = @{ ErrorAction = 'Stop' }

        # --- LOGIQUE CORRIGÉE : Le mode Legacy est géré en premier ---
        if ($launchConsoleMode -eq 'Legacy' -and $extension -in ('.bat', '.cmd')) {
            $launchMethod = "Legacy (cmd.exe)"
            $startProcessSplat.FilePath = "cmd.exe"
            $processTitle = if (-not [string]::IsNullOrWhiteSpace($ProcessToMonitor)) { $ProcessToMonitor } else { "WindowsOrchestrator Launch" }
            
            # CORRECTION CRITIQUE : La syntaxe des arguments a été simplifiée et corrigée pour être
            # correctement interprétée par cmd.exe. 
            $startProcessSplat.ArgumentList = "/c start `"$processTitle`" `"$expandedLaunchPath`" $ProcessArguments"
        } 
        # --- Si ce n'est pas le mode Legacy, on applique la logique standard ---
        else {
            $launchMethod = switch ($extension) {
                ".ps1" { "powershell" }
                { $_ -in ".bat", ".cmd" } { "cmd" }
                default { "direct" }
            }

            switch ($launchMethod) {
                "direct" {
                    $startProcessSplat.FilePath = $expandedLaunchPath
                    if (-not [string]::IsNullOrWhiteSpace($ProcessArguments)) { $startProcessSplat.ArgumentList = $ProcessArguments }
                }
                "powershell" {
                    $startProcessSplat.FilePath = "powershell.exe"
                    $commandToRun = "& `"$expandedLaunchPath`" $ProcessArguments"
                    $startProcessSplat.ArgumentList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", $commandToRun)
                }
                "cmd" {
                    $startProcessSplat.FilePath = "cmd.exe"
                    $commandToRun = "/c `"`"$expandedLaunchPath`" $ProcessArguments`""
                    $startProcessSplat.ArgumentList = $commandToRun
                }
            }
        }
        
        $workingDir = try { Split-Path -Path $expandedLaunchPath -Parent -ErrorAction Stop } catch { $ScriptDir }
        if ([string]::IsNullOrWhiteSpace($workingDir)) { $workingDir = $ScriptDir }

        $launchMinimized = Get-ConfigValue -Section "Process" -Key "StartProcessMinimized" -Type ([bool])

        if (Test-Path -Path $workingDir) { $startProcessSplat.WorkingDirectory = $workingDir }
        if ($launchMinimized -and $launchMethod -ne 'Legacy (cmd.exe)') { $startProcessSplat.Add("WindowStyle", "Minimized") }

        if ($Context -eq 'System') {
            Write-Log -DefaultMessage "Starting background process '{0}' via {1}..." -MessageId "Log_System_ProcessStarting" -MessageArgs $expandedLaunchPath, $launchMethod
        } else {
            Write-Log -DefaultMessage "Process '{0}' not found. Starting via {1}: '{2}' with args: '{3}'" -MessageId "Log_User_ProcessStarting" -MessageArgs $ProcessToMonitor, $launchMethod, $expandedLaunchPath, $ProcessArguments
        }
        
        Start-Process @startProcessSplat
        
        $actionMsgProcess = if (-not [string]::IsNullOrWhiteSpace($ProcessToMonitor)) { $ProcessToMonitor } else { $expandedLaunchPath }

        if ($Context -eq 'System') {
            Add-Action -DefaultActionMessage "Background process '{0}' started (via {1})." -ActionId "Action_System_ProcessStarted" -ActionArgs $actionMsgProcess, $launchMethod
        } else {
            Add-Action -DefaultActionMessage "Process '{0}' started (via {1})." -ActionId "Action_User_ProcessStarted" -ActionArgs $actionMsgProcess, $launchMethod
        }
    } catch {
        if ($Context -eq 'System') {
            Add-Error -DefaultErrorMessage "Failed to manage background process '{0}': {1}" -ErrorId "Error_System_ProcessManagementFailed" -ErrorArgs $ProcessToLaunch, $_.Exception.Message
        } else {
            Add-Error -DefaultErrorMessage "Failed to manage process '{0}' (Méthode: {1}, Chemin: '{2}', Args: '{3}'): {4}. StackTrace: {5}" -ErrorId "Error_User_ProcessManagementFailed" -ErrorArgs $ProcessToMonitor, $launchMethod, $expandedLaunchPath, $ProcessArguments, $_.Exception.Message, $_.ScriptStackTrace
        }
    }
}

<#
.SYNOPSIS
    Gère la logique de sortie du script (redémarrage ou fermeture manuelle/automatique).
.DESCRIPTION
    Cette fonction centralise la logique de sortie pour éviter la duplication de code.
    Elle lit la configuration pour déterminer si redémarrer ou fermer la fenêtre.
.PARAMETER Config
    L'objet de configuration chargé depuis config.ini.
.PARAMETER Lang
    L'objet de langue chargé.
.PARAMETER RebootMessageKey
    La clé de langue pour le message de redémarrage (ex: 'Install_RebootMessage').
.PARAMETER PressEnterKey
    La clé de langue pour "Press Enter to close" (ex: 'Install_PressEnterToClose').
#>
function Invoke-ExitLogic {
    param(
        [object]$Config,
        [object]$Lang,
        [string]$RebootMessageKey = "Install_RebootMessage",
        [string]$PressEnterKey = "Install_PressEnterToClose"
    )

    $rebootOnCompletion = $false
    if ($Config -and $Config.ContainsKey('Installation') -and $Config['Installation'].ContainsKey('RebootOnCompletion') -and $Config['Installation']['RebootOnCompletion'] -eq 'true') {
        $rebootOnCompletion = $true
    }

    if ($rebootOnCompletion) {
        $rebootGracePeriod = 15
        if ($Config -and $Config.ContainsKey('Installation') -and $Config['Installation'].ContainsKey('RebootGracePeriod')) {
            $rebootGracePeriod = [int]$Config['Installation']['RebootGracePeriod']
        }
        $rebootMessageTemplate = if ($Lang.ContainsKey($RebootMessageKey)) { $Lang[$RebootMessageKey] } else { "Installation complete. The system will restart in {0} seconds." }
        $rebootMessage = $rebootMessageTemplate -f $rebootGracePeriod

        Write-StyledHost $rebootMessage "WARNING"
        Start-Process -FilePath "shutdown.exe" -ArgumentList "-r -t $rebootGracePeriod /c `"$rebootMessage`"" -WindowStyle Hidden
    } else {
        $exitMode = 'manual'
        if ($Config -and $Config.ContainsKey('Installation') -and $Config['Installation'].ContainsKey('PowerShellExitMode')) {
            $exitMode = $Config['Installation']['PowerShellExitMode']
        }

        if ($exitMode -eq 'automatic') {
            $exitDelay = 15
            if ($Config -and $Config.ContainsKey('Installation') -and $Config['Installation'].ContainsKey('PowerShellExitDelay')) {
                $exitDelay = [int]$Config['Installation']['PowerShellExitDelay']
            }

            # Utilise la clé de langue pour le message de fermeture
            $exitMessageTemplate = if ($Lang -and $Lang.ContainsKey('Exit_AutoCloseMessage')) { $Lang.Exit_AutoCloseMessage } else { "This window will close in {0} seconds..." }
            $exitMessage = $exitMessageTemplate -f $exitDelay
            Write-Host $exitMessage

            Start-Sleep -Seconds $exitDelay
        } else {
            Read-Host $Lang[$PressEnterKey]
        }
    }
}

function Start-WaitingUI {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )

    $splashScriptContent = @'
#Requires -Version 5.1

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Création de la fenêtre
$form = New-Object System.Windows.Forms.Form
$form.Text = "Windows Orchestrator"
$form.Size = New-Object System.Drawing.Size(400, 150)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.TopMost = $true

# Label principal
$labelMain = New-Object System.Windows.Forms.Label
$labelMain.Text = "Windows Orchestrator"
$labelMain.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$labelMain.Location = New-Object System.Drawing.Point(10, 10)
$labelMain.Size = New-Object System.Drawing.Size(380, 30)
$labelMain.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($labelMain)

# Label secondaire (Texte français corrigé)
$labelSecondary = New-Object System.Windows.Forms.Label
$labelSecondary.Text = "{0}"
$labelSecondary.Location = New-Object System.Drawing.Point(10, 50)
$labelSecondary.Size = New-Object System.Drawing.Size(380, 20)
$labelSecondary.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($labelSecondary)

# ProgressBar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 80)
$progressBar.Size = New-Object System.Drawing.Size(380, 20)
$progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
$form.Controls.Add($progressBar)

# Affichage de la fenêtre (boucle jusqu'à fermeture externe)
$form.ShowDialog() | Out-Null
'@ -f $Message

    # Encodage en Base64 (Unicode pour les accents et pour le paramètre -EncodedCommand)
    $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($splashScriptContent))

    try {
        # Lancement du processus PowerShell avec le code encodé (sans minimisation pour garantir l'affichage graphique)
        # Nous acceptons la fenêtre console visible pour garantir la stabilité.
        $Global:WaitingUIProcess = Start-Process -FilePath "powershell.exe" `
            -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-EncodedCommand", $encodedCommand `
            -PassThru

        return $Global:WaitingUIProcess.Id
    } catch {
        Write-Warning "Impossible de lancer l'interface d'attente (Base64): $($_.Exception.Message)"
        return $null
    }
}

function Stop-WaitingUI {
    [CmdletBinding()]
    param()

    if ($Global:WaitingUIProcess -and -not $Global:WaitingUIProcess.HasExited) {
        try {
            # Tuer le processus et attendre sa fin
            Stop-Process -Id $Global:WaitingUIProcess.Id -Force -ErrorAction Stop
        } catch {
            Write-Warning "Failed to stop waiting UI: $($_.Exception.Message)"
        }
    }
    $Global:WaitingUIProcess = $null
}

# Exporte les fonctions pour les rendre disponibles aux scripts qui importeront ce module.
Export-ModuleMember -Function 'Set-OrchestratorLanguage', 'Get-IniContent', 'Write-StyledHost', 'Get-ConfigValue', 'Set-IniValue', 'Write-Log', 'Add-Action', 'Add-Error', 'Invoke-ExitLogic', 'Invoke-LogFileRotation', 'Start-OrchestratorProcess', 'Start-WaitingUI', 'Stop-WaitingUI'
