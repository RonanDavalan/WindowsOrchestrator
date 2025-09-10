#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Script de configuration système automatisée pour Windows.
.DESCRIPTION
    Ce script lit les paramètres depuis un fichier config.ini, applique un ensemble de configurations au niveau du système
    (démarrage rapide, veille, connexion automatique, Windows Update, etc.), et journalise toutes ses actions.
    Il est conçu pour s'exécuter au démarrage du système et gère l'internationalisation de ses logs.
.EXAMPLE
    Ce script n'est pas conçu pour être lancé manuellement avec des paramètres. Il est exécuté par une tâche planifiée
    et tire toute sa configuration du fichier 'config.ini' situé dans le même répertoire.

    Pour l'exécuter pour un test :
    PS C:\Path\To\Scripts\> .\config_systeme.ps1
.NOTES
    Auteur: Ronan Davalan & Gemini
    Version: i18n - Corrigée
#>

#=======================================================================================================================
# --- DÉFINITION DES FONCTIONS ---
#=======================================================================================================================

#region --- Fonctions principales et de base ---

<#
.SYNOPSIS
    Fait pivoter les fichiers journaux pour en conserver un nombre défini.
.DESCRIPTION
    Cette fonction gère la rotation des logs. Avant de créer un nouveau log, elle renomme les anciens en ajoutant
    un suffixe numérique (ex: log.txt -> log.1.txt, log.1.txt -> log.2.txt). Elle supprime le plus ancien
    fichier journal pour ne conserver que le nombre maximal spécifié.
.PARAMETER BaseLogPath
    Le chemin complet du fichier journal, sans son extension.
.PARAMETER LogExtension
    L'extension du fichier journal (ex: ".txt").
.PARAMETER MaxLogsToKeep
    Le nombre maximum de fichiers journaux archivés à conserver.
.EXAMPLE
    PS C:\> Rotate-LogFile -BaseLogPath "C:\Logs\MyScriptLog" -MaxLogsToKeep 5

    Ceci va gérer la rotation pour "MyScriptLog.txt", en conservant jusqu'à "MyScriptLog.5.txt".
#>
function Rotate-LogFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$BaseLogPath,
        [Parameter(Mandatory = $true)][string]$LogExtension = ".txt",
        [Parameter(Mandatory = $true)][int]$MaxLogsToKeep = 7
    )
    if ($MaxLogsToKeep -lt 1) { return }

    $oldestArchiveIndex = if ($MaxLogsToKeep -eq 1) { 1 } else { $MaxLogsToKeep - 1 }
    $oldestArchive = "$($BaseLogPath).$($oldestArchiveIndex)$LogExtension"
    if (Test-Path $oldestArchive) {
        Remove-Item $oldestArchive -ErrorAction SilentlyContinue
    }

    if ($MaxLogsToKeep -gt 1) {
        for ($i = $MaxLogsToKeep - 2; $i -ge 1; $i--) {
            $currentArchive = "$($BaseLogPath).$i$LogExtension"
            $nextArchive = "$($BaseLogPath).$($i + 1)$LogExtension"
            if (Test-Path $currentArchive) {
                if (Test-Path $nextArchive) {
                    Remove-Item $nextArchive -Force -ErrorAction SilentlyContinue
                }
                Rename-Item $currentArchive $nextArchive -ErrorAction SilentlyContinue
            }
        }
    }

    $currentLogFileToArchive = "$BaseLogPath$LogExtension"
    $firstArchive = "$($BaseLogPath).1$LogExtension"
    if (Test-Path $currentLogFileToArchive) {
        if (Test-Path $firstArchive) {
            Remove-Item $firstArchive -Force -ErrorAction SilentlyContinue
        }
        Rename-Item $currentLogFileToArchive $firstArchive -ErrorAction SilentlyContinue
    }
}

<#
.SYNOPSIS
    Analyse un fichier de configuration .ini et le convertit en une table de hachage PowerShell.
.DESCRIPTION
    Lit un fichier texte au format INI ligne par ligne et le transforme en une table de hachage imbriquée,
    où les clés de premier niveau sont les sections ([Section]) et les clés de second niveau sont les paires clé=valeur.
    Ignore les lignes vides et les commentaires (commençant par '#' ou ';').
.PARAMETER FilePath
    Le chemin d'accès complet au fichier .ini à analyser.
.RETURN
    Une table de hachage représentant le contenu du fichier .ini, ou $null si le fichier n'existe pas ou ne peut être lu.
.EXAMPLE
    PS C:\> $config = Get-IniContent -FilePath "C:\Settings\config.ini"
    PS C:\> $config['Database']['Server']

    Récupère la valeur de la clé 'Server' dans la section '[Database]'.
#>
function Get-IniContent {
    [CmdletBinding()]
    param ([Parameter(Mandatory = $true)][string]$FilePath)

    $ini = @{}
    $currentSection = ""

    if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
        return $null
    }

    try {
        Get-Content $FilePath -Encoding UTF8 -ErrorAction Stop | ForEach-Object {
            $line = $_.Trim()
            if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith("#") -or $line.StartsWith(";")) {
                return # Ignore les commentaires et les lignes vides.
            }

            if ($line -match "^\[(.+)\]$") {
                $currentSection = $matches[1].Trim()
                $ini[$currentSection] = @{}
            }
            elseif ($line -match "^([^=]+)=(.*)") {
                if ($currentSection) {
                    $key = $matches[1].Trim()
                    $value = $matches[2].Trim()
                    $ini[$currentSection][$key] = $value
                }
            }
        }
    } catch {
        return $null
    }

    return $ini
}
#endregion

#region --- Fonctions Utilitaires (Log, Erreurs, Configuration) ---

<#
.SYNOPSIS
    Écrit un message dans le fichier journal et, optionnellement, dans la console.
.DESCRIPTION
    Fonction centralisée pour la journalisation. Elle utilise un système de traduction basé sur un ID de message
    pour l'internationalisation, formate le message avec des arguments, et le préfixe avec un horodatage et un niveau
    de log. Inclut une logique de secours robuste pour écrire dans un répertoire alternatif si le journal principal échoue.
.PARAMETER DefaultMessage
    Le message à utiliser si l'ID de message n'est pas trouvé dans le fichier de langue.
.PARAMETER MessageId
    L'identifiant unique du message à rechercher dans le fichier de langue chargé.
.PARAMETER MessageArgs
    Un tableau d'objets à insérer dans le message formaté (ex: -f $arg1, $arg2).
.PARAMETER Level
    Le niveau de gravité du message (INFO, WARN, ERROR, DEBUG).
.PARAMETER NoConsole
    Si spécifié, le message ne sera pas affiché dans la console, uniquement dans le fichier journal.
.EXAMPLE
    PS C:\> Write-Log -DefaultMessage "User '{0}' logged in." -MessageId "Log_UserLogin" -MessageArgs "Admin" -Level "INFO"
#>
function Write-Log {
    [CmdletBinding()]
    param (
        [string]$DefaultMessage,
        [string]$MessageId,
        [object[]]$MessageArgs,
        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")][string]$Level = "INFO",
        [switch]$NoConsole
    )

    process {
        $messageTemplate = if ($lang -and $lang.ContainsKey($MessageId)) { $lang[$MessageId] } else { $DefaultMessage }

        try {
            $formattedMessage = $messageTemplate -f $MessageArgs
        } catch {
            $formattedMessage = $messageTemplate
        }

        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "$timestamp [$Level] - $formattedMessage"

        $LogParentDir = Split-Path $LogFile -Parent
        if (-not (Test-Path -Path $LogParentDir -PathType Container)) {
            try {
                New-Item -Path $LogParentDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
            } catch {
                # Ne peut pas créer le dossier de log, va utiliser le fallback
            }
        }

        try {
            Add-Content -Path $LogFile -Value $logEntry -Encoding UTF8 -ErrorAction Stop
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
            $fallbackMessage = "$timestamp [FATAL_LOG_ERROR] - Could not write to '$LogFile': $($_.Exception.Message). Original: $logEntry"
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
    Cette liste est utilisée à la fin du script pour construire un rapport de synthèse (ex: pour une notification Gotify).
.EXAMPLE
    PS C:\> Add-Action -DefaultActionMessage "Service '{0}' started." -ActionId "Action_ServiceStarted" -ActionArgs "wuauserv"
#>
function Add-Action {
    param(
        [string]$DefaultActionMessage,
        [string]$ActionId,
        [object[]]$ActionArgs
    )

    $messageTemplate = if ($lang -and $lang.ContainsKey($ActionId)) { $lang[$ActionId] } else { $DefaultActionMessage }
    $formattedMessage = try { $messageTemplate -f $ActionArgs } catch { $messageTemplate }

    $Global:ActionsEffectuees.Add($formattedMessage)
    Write-Log -DefaultMessage "ACTION: $formattedMessage" -Level "INFO" -NoConsole
}

<#
.SYNOPSIS
    Enregistre une erreur survenue pendant l'exécution dans une liste globale et dans le journal.
.DESCRIPTION
    Wrapper pour Write-Log qui ajoute un message d'erreur formaté à la liste globale $Global:ErreursRencontrees.
    Cette liste est utilisée pour déterminer si le script s'est terminé avec des erreurs et pour construire un rapport.
.EXAMPLE
    PS C:\> Add-Error -DefaultErrorMessage "Failed to start service '{0}'." -ErrorId "Error_ServiceStartFailed" -ErrorArgs "wuauserv"
#>
function Add-Error {
    [CmdletBinding()]
    param (
        [string]$DefaultErrorMessage,
        [string]$ErrorId,
        [object[]]$ErrorArgs
    )

    $messageTemplate = if ($lang -and $lang.ContainsKey($ErrorId)) { $lang[$ErrorId] } else { $DefaultErrorMessage }
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
#endregion

#=======================================================================================================================
# --- DÉBUT DU SCRIPT PRINCIPAL ---
#=======================================================================================================================

# --- Initialisation de l'Internationalisation (I18N) ---
$lang = @{}
try {
    if ($MyInvocation.MyCommand.CommandType -eq 'ExternalScript') {
        $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    }
    else {
        try {
            $PSScriptRoot = Split-Path -Parent $script:MyInvocation.MyCommand.Path -ErrorAction Stop
        } catch {
            $PSScriptRoot = Get-Location
        }
    }

    # Ce bloc de code lit manuellement la langue depuis config.ini AVANT de charger la configuration complète.
    # C'est une étape intentionnelle pour s'assurer que si Get-IniContent échoue plus tard,
    # les messages d'erreur peuvent déjà être dans la bonne langue.
    $configLanguage = ""
    $tempConfigPath = Join-Path $PSScriptRoot "config.ini"
    if (Test-Path $tempConfigPath) {
        $langLine = Get-Content $tempConfigPath -Encoding UTF8 | Select-String -Pattern "^\s*Language\s*=" -SimpleMatch | Select-Object -Last 1
        if ($langLine) {
            $configLanguage = ($langLine -split '=')[1].Trim()
        }
    }

    $cultureName = if (-not [string]::IsNullOrWhiteSpace($configLanguage)) {
        switch ($configLanguage.ToLower()) {
            'ar' { 'ar-SA' }
            'bn' { 'bn-BD' }
            'de' { 'de-DE' }
            'en' { 'en-US' }
            'es' { 'es-ES' }
            'fr' { 'fr-FR' }
            'hi' { 'hi-IN' }
            'id' { 'id-ID' }
            'ja' { 'ja-JP' }
            'ru' { 'ru-RU' }
            'zh' { 'zh-CN' }
            default { (Get-Culture).Name }
        }
    } else {
        (Get-Culture).Name
    }

    $langFilePath = Join-Path $PSScriptRoot "i18n\$cultureName\strings.psd1"
    # Si le fichier de langue n'existe pas, on se rabat sur l'anglais.
    if (-not (Test-Path $langFilePath)) {
        $langFilePath = Join-Path $PSScriptRoot "i18n\en-US\strings.psd1"
    }

    if (Test-Path $langFilePath) {
        $langContent = Get-Content -Path $langFilePath -Raw -Encoding UTF8
        $lang = Invoke-Expression $langContent
    }
} catch {
    $i18nLoadingError = $_.Exception.Message
}


# --- Configuration Globale et Initialisation des Logs ---
$ScriptIdentifier = "WindowsOrchestrator-System"
$ScriptInternalBuild = "Build-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$ScriptDir = $PSScriptRoot

$TargetLogDir = Join-Path -Path $ScriptDir -ChildPath "Logs"
$LogDirToUse = $ScriptDir
if (Test-Path $TargetLogDir -PathType Container) {
    $LogDirToUse = $TargetLogDir
}
else {
    try {
        New-Item -Path $TargetLogDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
        $LogDirToUse = $TargetLogDir
    } catch {
        # Si la création échoue, le répertoire des journaux reste le répertoire du script.
    }
}

$BaseLogPathForRotationSystem = Join-Path -Path $LogDirToUse -ChildPath "config_systeme_ps_log"
$BaseLogPathForRotationUser = Join-Path -Path $LogDirToUse -ChildPath "config_utilisateur_log"
$DefaultMaxLogs = 7

$tempConfigFile = Join-Path -Path $ScriptDir -ChildPath "config.ini"
$tempIniContent = Get-IniContent -FilePath $tempConfigFile
$rotationEnabledByConfig = $true
if ($null -ne $tempIniContent -and $tempIniContent.ContainsKey("Logging") -and $tempIniContent["Logging"].ContainsKey("EnableLogRotation")) {
    if ($tempIniContent["Logging"]["EnableLogRotation"].ToLower() -eq "false") {
        $rotationEnabledByConfig = $false
    }
}

if ($rotationEnabledByConfig) {
    Rotate-LogFile -BaseLogPath $BaseLogPathForRotationSystem -LogExtension ".txt" -MaxLogsToKeep $DefaultMaxLogs
    Rotate-LogFile -BaseLogPath $BaseLogPathForRotationUser -LogExtension ".txt" -MaxLogsToKeep $DefaultMaxLogs
}

$LogFile = Join-Path -Path $LogDirToUse -ChildPath "config_systeme_ps_log.txt"
$ConfigFile = Join-Path -Path $ScriptDir -ChildPath "config.ini"
$Global:ActionsEffectuees = [System.Collections.Generic.List[string]]::new()
$Global:ErreursRencontrees = [System.Collections.Generic.List[string]]::new()
$Global:Config = $null


# --- Corps Principal du Script ---
try {
    $Global:Config = Get-IniContent -FilePath $ConfigFile
    if (-not $Global:Config) {
        $tsInitErr = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        try {
            Add-Content -Path $LogFile -Value "$tsInitErr [ERROR] - Cannot read '$ConfigFile'. Halting." -Encoding UTF8
        } catch {
            # Impossible d'écrire dans le journal, mais le programme va s'arrêter juste après de toute façon.
        }
        throw "Critical failure: config.ini."
    }

    if ($i18nLoadingError) {
        Add-Error -DefaultErrorMessage "A critical error occurred while loading language files: $i18nLoadingError" -ErrorId "Error_LanguageFileLoad" -ErrorArgs $i18nLoadingError
    }

    Write-Log -DefaultMessage "Starting $ScriptIdentifier ($ScriptInternalBuild)..." -MessageId "Log_StartingScript" -MessageArgs $ScriptIdentifier, $ScriptInternalBuild

    # --- Vérification de la connectivité réseau ---
    $networkReady = $false
    Write-Log -DefaultMessage "Checking network connectivity..." -MessageId "Log_CheckingNetwork"
    for ($i = 0; $i -lt 6; $i++) {
        if (Test-NetConnection -ComputerName "8.8.8.8" -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue) {
            Write-Log -DefaultMessage "Network connectivity detected." -MessageId "Log_NetworkDetected"
            $networkReady = $true
            break
        }
        if ($i -lt 5) {
            Write-Log -DefaultMessage "Network unavailable, retrying in 10s..." -MessageId "Log_NetworkRetry"
            Start-Sleep -Seconds 10
        }
    }
    if (-not $networkReady) {
        Write-Log -DefaultMessage "Network not established. Gotify may fail." -MessageId "Log_NetworkFailed" -Level "WARN"
    }

    Write-Log -DefaultMessage "Executing configured SYSTEM actions..." -MessageId "Log_ExecutingSystemActions"

    # --- Détermination de l'utilisateur cible ---
    $targetUsernameForConfiguration = Get-ConfigValue -Section "SystemConfig" -Key "AutoLoginUsername"
    if ([string]::IsNullOrWhiteSpace($targetUsernameForConfiguration)) {
        Write-Log -DefaultMessage "AutoLoginUsername not specified. Attempting to read DefaultUserName from Registry." -MessageId "Log_ReadRegistryForUser" -Level INFO
        try {
            $regDefaultUser = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -ErrorAction SilentlyContinue).DefaultUserName
            if (-not [string]::IsNullOrWhiteSpace($regDefaultUser)) {
                $targetUsernameForConfiguration = $regDefaultUser
                Write-Log -DefaultMessage "Using Registry DefaultUserName as target user: {0}." -MessageId "Log_RegistryUserFound" -MessageArgs $targetUsernameForConfiguration -Level INFO
            } else {
                Write-Log -DefaultMessage "Registry DefaultUserName not found or empty. No default target user." -MessageId "Log_RegistryUserNotFound" -Level WARN
            }
        } catch {
            Write-Log -DefaultMessage "Error reading DefaultUserName from Registry: {0}" -MessageId "Log_RegistryReadError" -MessageArgs $_.Exception.Message -Level WARN
        }
    } else {
        Write-Log -DefaultMessage "Using AutoLoginUsername from config.ini as target user: {0}." -MessageId "Log_ConfigUserFound" -MessageArgs $targetUsernameForConfiguration -Level INFO
    }

    # --- Configuration du Démarrage Rapide (Fast Startup) ---
    $disableFastStartup = Get-ConfigValue -Section "SystemConfig" -Key "DisableFastStartup" -Type ([bool])
    $powerRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
    if ($disableFastStartup) {
        if ((Get-ItemProperty $powerRegPath -ErrorAction SilentlyContinue).HiberbootEnabled -ne 0) {
            try {
                Set-ItemProperty $powerRegPath HiberbootEnabled 0 -Force -ErrorAction Stop
                Add-Action -DefaultActionMessage "FastStartup disabled." -ActionId "Action_FastStartupDisabled"
            } catch {
                Add-Error -DefaultErrorMessage "Failed to disable FastStartup: $($_.Exception.Message)" -ErrorId "Error_DisableFastStartupFailed" -ErrorArgs $_.Exception.Message
            }
        } else {
            Add-Action -DefaultActionMessage "FastStartup verified (already disabled)." -ActionId "Action_FastStartupVerifiedDisabled"
        }
    }
    else {
        if ((Get-ItemProperty $powerRegPath -ErrorAction SilentlyContinue).HiberbootEnabled -ne 1) {
            try {
                Set-ItemProperty $powerRegPath HiberbootEnabled 1 -Force -ErrorAction Stop
                Add-Action -DefaultActionMessage "FastStartup enabled." -ActionId "Action_FastStartupEnabled"
            } catch {
                Add-Error -DefaultErrorMessage "Failed to enable FastStartup: $($_.Exception.Message)" -ErrorId "Error_EnableFastStartupFailed" -ErrorArgs $_.Exception.Message
            }
        } else {
            Add-Action -DefaultActionMessage "FastStartup verified (already enabled)." -ActionId "Action_FastStartupVerifiedEnabled"
        }
    }

    # --- Configuration de la Veille (Sleep) ---
    if (Get-ConfigValue "SystemConfig" "DisableSleep" -Type ([bool])) {
        try {
            powercfg /change standby-timeout-ac 0
            powercfg /change hibernate-timeout-ac 0
            Add-Action -DefaultActionMessage "Machine sleep (S3/S4) disabled." -ActionId "Action_SleepDisabled"
        } catch {
            Add-Error -DefaultErrorMessage "Failed to disable machine sleep: $($_.Exception.Message)" -ErrorId "Error_DisableSleepFailed" -ErrorArgs $_.Exception.Message
        }
    }
    if (Get-ConfigValue "SystemConfig" "DisableScreenSleep" -Type ([bool])) {
        try {
            powercfg /change monitor-timeout-ac 0
            Add-Action -DefaultActionMessage "Screen sleep disabled." -ActionId "Action_ScreenSleepDisabled"
        } catch {
            Add-Error -DefaultErrorMessage "Failed to disable screen sleep: $($_.Exception.Message)" -ErrorId "Error_DisableScreenSleepFailed" -ErrorArgs $_.Exception.Message
        }
    }

    # --- Configuration de la Connexion Automatique (AutoLogin) ---
    $winlogonKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    if (Get-ConfigValue "SystemConfig" "EnableAutoLogin" -Type ([bool])) {
        if (-not [string]::IsNullOrWhiteSpace($targetUsernameForConfiguration)) {
            try {
                Set-ItemProperty -Path $winlogonKey -Name AutoAdminLogon -Value "1" -Type String -Force -ErrorAction Stop
                Add-Action -DefaultActionMessage "AutoAdminLogon enabled." -ActionId "Action_AutoAdminLogonEnabled"

                Set-ItemProperty -Path $winlogonKey -Name DefaultUserName -Value $targetUsernameForConfiguration -Type String -Force -ErrorAction Stop
                Add-Action -DefaultActionMessage "DefaultUserName set to: {0}." -ActionId "Action_DefaultUserNameSet" -ActionArgs $targetUsernameForConfiguration
            } catch {
                Add-Error -DefaultErrorMessage "Failed to configure AutoLogin: $($_.Exception.Message)" -ErrorId "Error_AutoLoginFailed" -ErrorArgs $_.Exception.Message
            }
        } else {
            Add-Error -DefaultErrorMessage "AutoLogin enabled but target user could not be determined." -ErrorId "Error_AutoLoginUserUnknown"
        }
    }
    else {
        try {
            Set-ItemProperty -Path $winlogonKey -Name AutoAdminLogon -Value "0" -Type String -Force -ErrorAction Stop
            Add-Action -DefaultActionMessage "AutoAdminLogon disabled." -ActionId "Action_AutoAdminLogonDisabled"
        } catch {
            Add-Error -DefaultErrorMessage "Failed to disable AutoAdminLogon: $($_.Exception.Message)" -ErrorId "Error_DisableAutoLoginFailed" -ErrorArgs $_.Exception.Message
        }
    }

    # --- Configuration de Windows Update ---
    $wuPolicyKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $wuService = "wuauserv"
    if (-not (Test-Path $wuPolicyKey)) {
        New-Item $wuPolicyKey -Force -ErrorAction Stop | Out-Null
    }
    if (Get-ConfigValue "SystemConfig" "DisableWindowsUpdate" -Type ([bool])) {
        try {
            Set-ItemProperty $wuPolicyKey NoAutoUpdate 1 -Type DWord -Force -ErrorAction Stop
            Get-Service $wuService -ErrorAction Stop | Set-Service -StartupType Disabled -PassThru -ErrorAction Stop | Stop-Service -Force -ErrorAction SilentlyContinue
            Add-Action -DefaultActionMessage "Win Updates disabled." -ActionId "Action_UpdatesDisabled"
        } catch {
            Add-Error -DefaultErrorMessage "Failed to manage Win Updates: $($_.Exception.Message)" -ErrorId "Error_UpdateMgmtFailed" -ErrorArgs $_.Exception.Message
        }
    }
    else {
        try {
            Set-ItemProperty $wuPolicyKey NoAutoUpdate 0 -Type DWord -Force -ErrorAction Stop
            Get-Service $wuService -ErrorAction Stop | Set-Service -StartupType Automatic -PassThru -ErrorAction Stop | Start-Service -ErrorAction SilentlyContinue
            Add-Action -DefaultActionMessage "Win Updates enabled." -ActionId "Action_UpdatesEnabled"
        } catch {
            Add-Error -DefaultErrorMessage "Failed to manage Win Updates: $($_.Exception.Message)" -ErrorId "Error_UpdateMgmtFailed" -ErrorArgs $_.Exception.Message
        }
    }
    if (Get-ConfigValue "SystemConfig" "DisableAutoReboot" -Type ([bool])) {
        try {
            Set-ItemProperty $wuPolicyKey NoAutoRebootWithLoggedOnUsers 1 -Type DWord -Force -ErrorAction Stop
            Add-Action -DefaultActionMessage "Auto-reboot (WU) disabled." -ActionId "Action_AutoRebootDisabled"
        } catch {
            Add-Error -DefaultErrorMessage "Failed to disable auto-reboot: $($_.Exception.Message)" -ErrorId "Error_DisableAutoRebootFailed" -ErrorArgs $_.Exception.Message
        }
    }

    # --- Configuration du Redémarrage Planifié ---
    $rebootTime = Get-ConfigValue "SystemConfig" "ScheduledRebootTime"
    $rebootTaskName = "WindowsOrchestrator-SystemScheduledReboot"
    if (-not [string]::IsNullOrWhiteSpace($rebootTime)) {
        $rebootDesc = "Daily reboot by AllSysConfig (Build: $ScriptInternalBuild)"
        $rebootAction = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r /f /t 60 /c `"$rebootDesc`""
        $rebootTrigger = New-ScheduledTaskTrigger -Daily -At $rebootTime
        Register-ScheduledTask $rebootTaskName -Action $rebootAction -Trigger $rebootTrigger -Principal (New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\System" -LogonType ServiceAccount -RunLevel Highest) -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries) -Description $rebootDesc -Force
        Add-Action -DefaultActionMessage "Scheduled reboot at {0} (Task: {1})." -ActionId "Action_RebootScheduled" -ActionArgs $rebootTime, $rebootTaskName
    } else {
        Unregister-ScheduledTask $rebootTaskName -Confirm:$false -ErrorAction SilentlyContinue
    }

    # --- Configuration de l'Action Pré-Redémarrage ---
    $preRebootActionTime = Get-ConfigValue -Section "SystemConfig" -Key "PreRebootActionTime"
    $preRebootCmdFromFile = Get-ConfigValue -Section "SystemConfig" -Key "PreRebootActionCommand"
    $preRebootArgsFromFile = Get-ConfigValue -Section "SystemConfig" -Key "PreRebootActionArguments"
    $preRebootLaunchMethod = (Get-ConfigValue -Section "SystemConfig" -Key "PreRebootActionLaunchMethod" -DefaultValue "direct").ToLower()
    $preRebootTaskName = "WindowsOrchestrator-SystemPreRebootAction"
    if ((-not [string]::IsNullOrWhiteSpace($preRebootActionTime)) -and (-not [string]::IsNullOrWhiteSpace($preRebootCmdFromFile))) {

        $programToExecute = $preRebootCmdFromFile.Trim('"')

        # Remplace la variable %USERPROFILE% par le chemin réel du profil de l'utilisateur cible.
        if ($programToExecute -match "%USERPROFILE%") {
            if (-not [string]::IsNullOrWhiteSpace($targetUsernameForConfiguration)) {
                try {
                    # Trouve le SID (Identifiant de Sécurité) de l'utilisateur pour localiser son profil.
                    $userAccount = New-Object System.Security.Principal.NTAccount($targetUsernameForConfiguration)
                    $userSid = $userAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
                    # Récupère le chemin du profil depuis le registre Windows.
                    $userProfilePathTarget = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$userSid" -Name ProfileImagePath -ErrorAction Stop).ProfileImagePath
                    if ($userProfilePathTarget) {
                        # Effectue le remplacement dans la commande à exécuter.
                        $programToExecute = $programToExecute -replace "%USERPROFILE%", [regex]::Escape($userProfilePathTarget)
                    }
                } catch {
                    Add-Error -DefaultErrorMessage "Could not determine profile path for '$targetUsernameForConfiguration' for PreRebootAction."
                }
            } else {
                Add-Error -DefaultErrorMessage "%USERPROFILE% detected in PreRebootActionCommand, but target user could not be determined."
            }
        }

        # Convertit un chemin relatif (ex: 'programme.exe') en chemin complet (ex: 'C:\script\programme.exe').
        # Cette vérification est effectuée seulement si le chemin n'est pas déjà un chemin absolu, UNC, ou une variable système.
        if (($programToExecute -notmatch '^[a-zA-Z]:\\') -and ($programToExecute -notmatch '^\\\\') -and ($programToExecute -notmatch '^%') -and (-not (Get-Command $programToExecute -CommandType Application,ExternalScript -ErrorAction SilentlyContinue))) {
            # Construit un chemin complet en se basant sur l'emplacement du script actuel.
            $potentialPath = Join-Path -Path $ScriptDir -ChildPath $programToExecute -Resolve -ErrorAction SilentlyContinue
            # Si ce nouveau chemin pointe vers un fichier qui existe, on l'utilise.
            if (Test-Path -LiteralPath $potentialPath -PathType Leaf) {
                $programToExecute = $potentialPath
            }
        }

        $programToExecute = [System.Environment]::ExpandEnvironmentVariables($programToExecute)
        $exeForTaskScheduler = ""
        $argumentStringForTaskScheduler = ""
        $workingDirectoryForTask = ""
        if (Test-Path -LiteralPath $programToExecute -PathType Leaf) {
            $workingDirectoryForTask = Split-Path -Path $programToExecute -Parent
        }

        switch ($preRebootLaunchMethod) {
            "direct"     { $exeForTaskScheduler = $programToExecute; $argumentStringForTaskScheduler = $preRebootArgsFromFile }
            "powershell" { $exeForTaskScheduler = "powershell.exe"; $argumentStringForTaskScheduler = "-NoProfile -ExecutionPolicy Bypass -Command `"& `"$programToExecute`" $preRebootArgsFromFile`"" }
            "cmd"        { $exeForTaskScheduler = "cmd.exe"; $argumentStringForTaskScheduler = "/c `"`"$programToExecute`" $preRebootArgsFromFile`"" }
            default      { Add-Error -DefaultErrorMessage "Invalid PreRebootActionLaunchMethod: '$preRebootLaunchMethod'." }
        }

        if ($exeForTaskScheduler -and ( (Test-Path -LiteralPath $programToExecute -PathType Leaf) -or (Get-Command $programToExecute -ErrorAction SilentlyContinue) ) ) {
            try {
                $taskAction = New-ScheduledTaskAction -Execute $exeForTaskScheduler -Argument $argumentStringForTaskScheduler -WorkingDirectory $workingDirectoryForTask
                $taskTrigger = New-ScheduledTaskTrigger -Daily -At $preRebootActionTime

                $principalUserForPreReboot = if (-not [string]::IsNullOrWhiteSpace($targetUsernameForConfiguration)) { $targetUsernameForConfiguration } else { "NT AUTHORITY\System" }
                $principalLogonType = if (-not [string]::IsNullOrWhiteSpace($targetUsernameForConfiguration)) { "Interactive" } else { "ServiceAccount" }
                $taskPrincipal = New-ScheduledTaskPrincipal -UserId $principalUserForPreReboot -LogonType $principalLogonType -RunLevel Highest

                Unregister-ScheduledTask -TaskName $preRebootTaskName -Confirm:$false -ErrorAction SilentlyContinue
                Register-ScheduledTask -TaskName $preRebootTaskName -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries) -Description "Pre-reboot action by AllSysConfig" -Force -ErrorAction Stop

                Add-Action -DefaultActionMessage "Pre-reboot action at '{0}' configured (Task: {1})." -ActionId "Action_PreRebootConfigured" -ActionArgs $preRebootActionTime, $preRebootTaskName
            } catch {
                Add-Error -DefaultErrorMessage "Failed to create/update pre-reboot task '$preRebootTaskName': $($_.Exception.Message)"
            }
        } else {
            Add-Error -DefaultErrorMessage "Pre-reboot command '$programToExecute' could not be found or resolved."
        }
    } else {
        Unregister-ScheduledTask -TaskName $preRebootTaskName -Confirm:$false -ErrorAction SilentlyContinue
    }

    # --- Configuration de OneDrive ---
    $oneDrivePolicyKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
    if (Get-ConfigValue -Section "SystemConfig" -Key "DisableOneDrive" -Type ([bool])) {
        if (-not (Test-Path $oneDrivePolicyKey)) {
            New-Item -Path $oneDrivePolicyKey -Force | Out-Null
        }
        Set-ItemProperty -Path $oneDrivePolicyKey -Name DisableFileSyncNGSC -Value 1 -Force
        Add-Action -DefaultActionMessage "OneDrive disabled (policy)." -ActionId "Action_OneDriveDisabled"
    }
    else {
        if (Test-Path $oneDrivePolicyKey) {
            Remove-ItemProperty -Path $oneDrivePolicyKey -Name DisableFileSyncNGSC -Force -ErrorAction SilentlyContinue
        }
        Add-Action -DefaultActionMessage "OneDrive allowed (policy)." -ActionId "Action_OneDriveEnabled"
    }

} catch {
    # Si la configuration a été chargée avant que l'erreur ne survienne,
    # on enregistre une erreur détaillée en utilisant le système de journalisation normal.
    if ($null -ne $Global:Config) {
        Add-Error -DefaultErrorMessage "FATAL SCRIPT ERROR (main block): $($_.Exception.Message) `n$($_.ScriptStackTrace)" -ErrorId "Error_FatalScriptError" -ErrorArgs $_.Exception.Message, $_.ScriptStackTrace
    }
    # Si l'erreur s'est produite avant même que la configuration ne puisse être lue...
    else {
        $tsErr = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $errMsg = "$tsErr [FATAL SCRIPT ERROR - CONFIG NOT LOADED] - Error: $($_.Exception.Message)"
        # ...on tente une dernière fois d'écrire l'erreur dans un fichier de secours dédié.
        try {
            Add-Content -Path (Join-Path $LogDirToUse "config_systeme_ps_FATAL_ERROR.txt") -Value $errMsg -Encoding UTF8 -ErrorAction SilentlyContinue
        } catch {
            # Ultime recours, si même l'écriture du fichier d'erreur de secours échoue.
        }
    }
} finally {
    # --- Envoi de la notification Gotify (si configurée) ---
    if ($Global:Config -and (Get-ConfigValue -Section "Gotify" -Key "EnableGotify" -Type ([bool]))) {
        $gotifyUrl = Get-ConfigValue -Section "Gotify" -Key "Url"
        $gotifyToken = Get-ConfigValue -Section "Gotify" -Key "Token"
        $gotifyPriority = Get-ConfigValue -Section "Gotify" -Key "Priority" -Type ([int]) -DefaultValue 5

        if ((-not [string]::IsNullOrWhiteSpace($gotifyUrl)) -and (-not [string]::IsNullOrWhiteSpace($gotifyToken))) {
            if ($networkReady) {
                $titleSuccessTemplate = Get-ConfigValue -Section "Gotify" -Key "GotifyTitleSuccessSystem" -DefaultValue ("%COMPUTERNAME% " + $ScriptIdentifier + " OK")
                $titleErrorTemplate = Get-ConfigValue -Section "Gotify" -Key "GotifyTitleErrorSystem" -DefaultValue ("ERROR " + $ScriptIdentifier + " on %COMPUTERNAME%")

                $finalMessageTitle = if ($Global:ErreursRencontrees.Count -gt 0) {
                    $titleErrorTemplate -replace "%COMPUTERNAME%", $env:COMPUTERNAME
                } else {
                    $titleSuccessTemplate -replace "%COMPUTERNAME%", $env:COMPUTERNAME
                }

                $dateStr = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
                $dateLineTemplate = if ($lang -and $lang.ContainsKey('Gotify_MessageDate')) { $lang.Gotify_MessageDate } else { "On {0}." }
                $messageBody = ($dateLineTemplate -f $dateStr) + "`n"

                if ($Global:ActionsEffectuees.Count -gt 0) {
                    $actionsHeader = if ($lang -and $lang.ContainsKey('Gotify_SystemActionsHeader')) { $lang.Gotify_SystemActionsHeader } else { "SYSTEM Actions:" }
                    $messageBody += "$actionsHeader`n" + ($Global:ActionsEffectuees -join "`n")
                } else {
                    $noActionsMessage = if ($lang -and $lang.ContainsKey('Gotify_NoSystemActions')) { $lang.Gotify_NoSystemActions } else { "No SYSTEM actions." }
                    $messageBody += $noActionsMessage
                }

                if ($Global:ErreursRencontrees.Count -gt 0) {
                    $errorsHeader = if ($lang -and $lang.ContainsKey('Gotify_SystemErrorsHeader')) { $lang.Gotify_SystemErrorsHeader } else { "SYSTEM Errors:" }
                    $messageBody += "`n`n$errorsHeader`n" + ($Global:ErreursRencontrees -join "`n")
                }

                $payload = @{
                    message  = $messageBody
                    title    = $finalMessageTitle
                    priority = $gotifyPriority
                } | ConvertTo-Json -Depth 3 -Compress

                $fullUrl = "$($gotifyUrl.TrimEnd('/'))/message?token=$gotifyToken"

                try {
                    Invoke-RestMethod -Uri $fullUrl -Method Post -Body $payload -ContentType "application/json; charset=utf-8" -TimeoutSec 30 -ErrorAction Stop
                }
                catch {
                    Add-Error -DefaultErrorMessage "Gotify (IRM) failed: $($_.Exception.Message)"
                }
            } else {
                Add-Error -DefaultErrorMessage "Network unavailable for Gotify (system)."
            }
        } else {
            Add-Error -DefaultErrorMessage "Gotify params incomplete."
        }
    }

    Write-Log -DefaultMessage "{0} ({1}) finished." -MessageId "Log_ScriptFinished" -MessageArgs $ScriptIdentifier, $ScriptInternalBuild
    if ($Global:ErreursRencontrees.Count -gt 0) {
        Write-Log -DefaultMessage "Errors occurred during execution." -MessageId "Log_ErrorsOccurred" -Level WARN
    }
}
