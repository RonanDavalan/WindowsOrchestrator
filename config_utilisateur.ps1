#Requires -Version 5.1

<#
.SYNOPSIS
    Script de configuration utilisateur automatisée.
.DESCRIPTION
    Ce script, destiné à s'exécuter à l'ouverture de session d'un utilisateur, lit les paramètres depuis
    un fichier config.ini. Sa tâche principale est de gérer un processus applicatif spécifique à l'utilisateur
    (le relancer si nécessaire) et de journaliser ses actions dans la langue configurée.
.EXAMPLE
    Ce script est conçu pour être exécuté par une tâche planifiée au logon de l'utilisateur. Il ne prend pas
    de paramètres en ligne de commande.

    Pour l'exécuter manuellement pour un test :
    PS C:\Path\To\Scripts\> .\config_utilisateur.ps1
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
    PS C:\> $config['UserApp']['Path']

    Récupère la valeur de la clé 'Path' dans la section '[UserApp]'.
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
                return # Ignore comments and empty lines
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
    Écrit un message dans le fichier journal de l'utilisateur et, optionnellement, dans la console.
.DESCRIPTION
    Fonction centralisée pour la journalisation des actions utilisateur. Elle utilise le système de traduction,
    formate le message, et le préfixe avec un horodatage, un niveau, et le nom de l'utilisateur courant.
    Possède une logique de secours pour écrire dans un répertoire de repli en cas d'échec.
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
    PS C:\> Write-UserLog -DefaultMessage "Application '{0}' started." -MessageId "Log_User_AppStarted" -MessageArgs "Calc"
#>
function Write-UserLog {
    [CmdletBinding()]
    param (
        [string]$DefaultMessage,
        [string]$MessageId,
        [object[]]$MessageArgs,
        # Définit un paramètre de type chaîne nommé 'Level' avec des valeurs validées et une valeur par défaut "INFO".
        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")][string]$Level = "INFO",
        # Définit un paramètre de type switch nommé 'NoConsole'.
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
        $logEntry = "$timestamp [$Level] [UserScript:$($env:USERNAME)] - $formattedMessage"

        $LogParentDirUser = Split-Path $LogFileUser -Parent
        if (-not (Test-Path -Path $LogParentDirUser -PathType Container)) {
            try {
                New-Item -Path $LogParentDirUser -ItemType Directory -Force -ErrorAction Stop | Out-Null
            } catch {
                # Impossible de créer le répertoire de log, on continue vers la solution de secours.
            }
        }

        try {
            # Ajoute le contenu de '$logEntry' au fichier spécifié par '$LogFileUser' avec l'encodage UTF8.
            Add-Content -Path $LogFileUser -Value $logEntry -Encoding UTF8 -ErrorAction Stop
        }
        catch {
            $fallbackLogDir = "C:\ProgramData\StartupScriptLogs"
            if (-not (Test-Path -Path $fallbackLogDir)) {
                try {
                    New-Item -Path $fallbackLogDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
                } catch {
                    # Impossible de créer même le répertoire de secours.
                }
            }
            $fallbackLogFile = Join-Path -Path $fallbackLogDir -ChildPath "config_utilisateur_FATAL_LOG_ERROR.txt"
            $fallbackMessage = "$timestamp [FATAL_USER_LOG_ERROR] - Could not write to '$LogFileUser': $($_.Exception.Message). Original: $logEntry"
            Write-Host $fallbackMessage -ForegroundColor Red
            try {
                Add-Content -Path $fallbackLogFile -Value $fallbackMessage -Encoding UTF8 -ErrorAction Stop
            } catch {
                # La tentative finale a échoué.
            }
        }

        if (-not $NoConsole -and ($Host.Name -eq "ConsoleHost" -or $PSEdition -eq "Core")) {
            Write-Host $logEntry
        }
    }
}

<#
.SYNOPSIS
    Enregistre une action effectuée par le script utilisateur dans une liste globale et dans le journal.
.DESCRIPTION
    Wrapper pour Write-UserLog qui ajoute un message formaté à la liste globale $Global:UserActionsEffectuees.
    Cette liste sert à construire un rapport de synthèse à la fin de l'exécution.
.EXAMPLE
    PS C:\> Add-UserAction -DefaultActionMessage "Process '{0}' started." -ActionId "Action_User_ProcessStarted" -ActionArgs "notepad"
#>
function Add-UserAction {
    param(
        [string]$DefaultActionMessage,
        [string]$ActionId,
        [object[]]$ActionArgs
    )

    $messageTemplate = if ($lang -and $lang.ContainsKey($ActionId)) { $lang[$ActionId] } else { $DefaultActionMessage }
    $formattedMessage = try { $messageTemplate -f $ActionArgs } catch { $messageTemplate }

    $Global:UserActionsEffectuees.Add($formattedMessage)
    Write-UserLog -DefaultMessage "ACTION: $formattedMessage" -Level "INFO" -NoConsole
}

<#
.SYNOPSIS
    Enregistre une erreur survenue pendant l'exécution du script utilisateur.
.DESCRIPTION
    Wrapper pour Write-UserLog qui ajoute un message d'erreur formaté à la liste globale $Global:UserErreursRencontrees,
    utilisée pour le rapport final et la notification.
.EXAMPLE
    PS C:\> Add-UserError -DefaultErrorMessage "File not found: {0}" -ErrorId "Error_User_FileNotFound" -ErrorArgs "C:\data.txt"
#>
function Add-UserError {
    [CmdletBinding()]
    param (
        [string]$DefaultErrorMessage,
        [string]$ErrorId,
        [object[]]$ErrorArgs
    )

    $messageTemplate = if ($lang -and $lang.ContainsKey($ErrorId)) { $lang[$ErrorId] } else { $DefaultErrorMessage }
    $formattedMessage = try { $messageTemplate -f $ErrorArgs } catch { $messageTemplate }

    $detailedErrorMessage = if ([string]::IsNullOrWhiteSpace($formattedMessage) -and $global:Error.Count -gt 0) {
        "Unspecified user error. PowerShell: $($global:Error[0].Exception.Message) - StackTrace: $($global:Error[0].ScriptStackTrace)"
    } else {
        $formattedMessage
    }

    $Global:UserErreursRencontrees.Add($detailedErrorMessage)
    Write-UserLog -DefaultMessage "CAPTURED ERROR: $detailedErrorMessage" -MessageId "Log_CapturedError" -MessageArgs $detailedErrorMessage -Level "ERROR"
}

<#
.SYNOPSIS
    Récupère de manière sécurisée une valeur depuis l'objet de configuration global.
.DESCRIPTION
    Cette fonction est le moyen standard pour interroger la configuration chargée depuis config.ini. Elle gère les cas
    où la section ou la clé n'existe pas, fournit des valeurs par défaut, et effectue une conversion de type
    sécurisée (ex: de chaîne vers booléen ou entier), tout en enregistrant une erreur en cas d'échec de la conversion.
.PARAMETER Section
    Le nom de la section INI (ex: "Process").
.PARAMETER Key
    Le nom de la clé dans la section (ex: "ProcessName").
.PARAMETER DefaultValue
    La valeur à retourner si la clé n'est pas trouvée.
.PARAMETER Type
    Le type de données vers lequel convertir la valeur (ex: [bool], [int]).
.RETURN
    La valeur convertie, la valeur par défaut, ou $null.
.EXAMPLE
    PS C:\> $priority = Get-ConfigValue -Section "Gotify" -Key "Priority" -Type ([int]) -DefaultValue 5
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
        Add-UserError -DefaultErrorMessage "Invalid config value for [$($Section)]$($Key): '$value'. Expected type '$($Type.Name)'. Default/empty value used." -ErrorId "Error_InvalidConfigValue" -ErrorArgs $Section, $Key, $value, $Type.Name
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

    # Ce bloc lit la langue depuis config.ini avant le chargement complet de la configuration.
    # C'est une étape intentionnelle pour garantir que les erreurs de lecture de config.ini
    # puissent être traduites, si possible.
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
    if (-not (Test-Path $langFilePath)) {
        $langFilePath = Join-Path $PSScriptRoot "i18n\en-US\strings.psd1"
    }

    if (Test-Path $langFilePath) {
        $lang = Invoke-Expression (Get-Content -Path $langFilePath -Raw -Encoding UTF8)
    }
} catch {
    $i18nLoadingError = $_.Exception.Message
}


# --- Configuration Globale et Initialisation des Logs ---
$ScriptIdentifierUser = "WindowsOrchestrator-User"
$ScriptInternalBuildUser = "Build-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$ScriptDir = $PSScriptRoot

$TargetLogDirUser = Join-Path -Path $ScriptDir -ChildPath "Logs"
$LogDirToUseUser = if (Test-Path $TargetLogDirUser -PathType Container) { $TargetLogDirUser } else { $ScriptDir }
try {
    if ($LogDirToUseUser -ne $TargetLogDirUser) {
        New-Item -Path $TargetLogDirUser -ItemType Directory -Force -ErrorAction Stop | Out-Null
        $LogDirToUseUser = $TargetLogDirUser
    }
} catch {
    # If creation fails, LogDirToUseUser remains $ScriptDir
}

$LogFileUser = Join-Path -Path $LogDirToUseUser -ChildPath "config_utilisateur_log.txt"
$ConfigFile = Join-Path -Path $ScriptDir -ChildPath "config.ini"
$Global:UserActionsEffectuees = [System.Collections.Generic.List[string]]::new()
$Global:UserErreursRencontrees = [System.Collections.Generic.List[string]]::new()
$Global:Config = $null


# --- Corps Principal du Script ---
try {
    $Global:Config = Get-IniContent -FilePath $ConfigFile
    if (-not $Global:Config) {
        Write-UserLog -DefaultMessage "Could not read or parse '{0}'. Halting user configurations." -MessageId "Log_User_CannotReadConfig" -MessageArgs $ConfigFile -Level ERROR
        throw "Critical failure: Could not load config.ini for user script."
    }

    if ($i18nLoadingError) {
        Add-UserError -DefaultErrorMessage "A critical error occurred while loading language files: $i18nLoadingError" -ErrorId "Error_LanguageFileLoad" -ErrorArgs $i18nLoadingError
    }

    Write-UserLog -DefaultMessage "Starting {0} ({1}) for user '{2}'..." -MessageId "Log_User_StartingScript" -MessageArgs $ScriptIdentifierUser, $ScriptInternalBuildUser, $env:USERNAME
    Write-UserLog -DefaultMessage "Executing configured actions for user '{0}'..." -MessageId "Log_User_ExecutingActions" -MessageArgs $env:USERNAME

    # --- Gestion du processus spécifié ---
    $processNameToManageRaw = Get-ConfigValue -Section "Process" -Key "ProcessName"
    $processNameToManageExpanded = ""

    # L'utilisation de ExpandEnvironmentVariables est cruciale pour résoudre les chemins spécifiques à l'utilisateur,
    # comme %APPDATA% ou %LOCALAPPDATA%, qui sont courants dans les configurations au niveau de la session.
    if (-not [string]::IsNullOrWhiteSpace($processNameToManageRaw)) {
        try {
            $processNameToManageExpanded = [System.Environment]::ExpandEnvironmentVariables($processNameToManageRaw.Trim('"'))
        }
        catch {
            Add-UserError -DefaultErrorMessage "Error expanding variables for ProcessName '{0}': {1}" -ErrorId "Error_User_VarExpansionFailed" -ErrorArgs $processNameToManageRaw, $_.Exception.Message
            $processNameToManageExpanded = $processNameToManageRaw.Trim('"')
        }
    }

    $processArgumentsToPass = Get-ConfigValue -Section "Process" -Key "ProcessArguments"
    $launchMethod = (Get-ConfigValue -Section "Process" -Key "LaunchMethod" -DefaultValue "direct").ToLower()

    if (-not [string]::IsNullOrWhiteSpace($processNameToManageExpanded)) {
        Write-UserLog -DefaultMessage "Managing user process (raw:'{0}', resolved:'{1}'). Method: {2}" -MessageId "Log_User_ManagingProcess" -MessageArgs $processNameToManageRaw, $processNameToManageExpanded, $launchMethod
        if (-not [string]::IsNullOrWhiteSpace($processArgumentsToPass)) {
            Write-UserLog -DefaultMessage "With arguments: '{0}'" -MessageId "Log_User_ProcessWithArgs" -MessageArgs $processArgumentsToPass -Level DEBUG
        }

        $processNameIsFilePath = Test-Path -LiteralPath $processNameToManageExpanded -PathType Leaf -ErrorAction SilentlyContinue

        if (($launchMethod -eq "direct" -and $processNameIsFilePath) -or ($launchMethod -ne "direct")) {
            $exeForStartProcess = ""
            $argsForStartProcess = ""
            $processBaseNameToMonitor = ""

            switch ($launchMethod) {
                "direct" {
                    $exeForStartProcess = $processNameToManageExpanded
                    $argsForStartProcess = $processArgumentsToPass
                    try { $processBaseNameToMonitor = [System.IO.Path]::GetFileNameWithoutExtension($processNameToManageExpanded) } catch { $processBaseNameToMonitor = "UnknownProcess" }
                }
                "powershell" {
                    $exeForStartProcess = "powershell.exe"
                    $commandToRun = "& `"$processNameToManageExpanded`""
                    if (-not [string]::IsNullOrWhiteSpace($processArgumentsToPass)) { $commandToRun += " $processArgumentsToPass" }
                    $argsForStartProcess = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", $commandToRun)
                    try { $processBaseNameToMonitor = [System.IO.Path]::GetFileNameWithoutExtension($processNameToManageExpanded) } catch { $processBaseNameToMonitor = "powershell" }
                }
                "cmd" {
                    $exeForStartProcess = "cmd.exe"
                    $commandToRun = "/c `"`"$processNameToManageExpanded`" $processArgumentsToPass`""
                    $argsForStartProcess = $commandToRun
                    try { $processBaseNameToMonitor = [System.IO.Path]::GetFileNameWithoutExtension($processNameToManageExpanded) } catch { $processBaseNameToMonitor = "cmd" }
                }
                default {
                    Add-UserError -DefaultErrorMessage "LaunchMethod '{0}' not recognized. Options: direct, powershell, cmd." -ErrorId "Error_User_LaunchMethodUnknown" -ErrorArgs $launchMethod
                    throw "Unhandled LaunchMethod."
                }
            }

            $workingDir = if ($processNameIsFilePath) { try { Split-Path -Path $processNameToManageExpanded -Parent } catch { } } else { $ScriptDir }

            try {
                # Il est impératif de vérifier que le processus existant appartient bien à l'utilisateur courant.
                # Ceci évite d'arrêter le processus d'un autre utilisateur sur un système multi-session (ex: TSE/RDS).
                $currentUserSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
                $runningProcess = Get-Process -Name $processBaseNameToMonitor -ErrorAction SilentlyContinue | ForEach-Object {
                    try {
                        $ownerInfo = Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)" | Select-Object -ExpandProperty @{Name = "Owner"; Expression = { $_.GetProcessOwner() } } -ErrorAction SilentlyContinue
                        if ($ownerInfo -and $ownerInfo.SID -eq $currentUserSID) {
                            return $_
                        }
                    } catch {
                        # Ignore errors on processes we can't query (e.g. system processes)
                    }
                } | Select-Object -First 1

                # L'utilisation de "splatting" (@startProcessSplat) rend l'appel à Start-Process plus propre
                # et plus facile à maintenir, surtout avec des paramètres conditionnels.
                $startProcessSplat = @{
                    FilePath    = $exeForStartProcess
                    ErrorAction = 'Stop'
                }
                if (($argsForStartProcess -is [array] -and $argsForStartProcess.Count -gt 0) -or ($argsForStartProcess -is [string] -and -not [string]::IsNullOrWhiteSpace($argsForStartProcess))) {
                    $startProcessSplat.ArgumentList = $argsForStartProcess
                }
                if (-not [string]::IsNullOrWhiteSpace($workingDir) -and (Test-Path -LiteralPath $workingDir -PathType Container)) {
                    $startProcessSplat.WorkingDirectory = $workingDir
                }

                if ($runningProcess) {
                    Write-UserLog -DefaultMessage "Process '{0}' (PID: {1}) is running. Stopping..." -MessageId "Log_User_ProcessStopping" -MessageArgs $processBaseNameToMonitor, $runningProcess.Id
                    $runningProcess | Stop-Process -Force -ErrorAction Stop
                    Add-UserAction -DefaultActionMessage "Process '{0}' stopped." -ActionId "Action_User_ProcessStopped" -ActionArgs $processBaseNameToMonitor
                }

                $logArgsForStart = if ($argsForStartProcess -is [array]) { $argsForStartProcess -join ' ' } else { $argsForStartProcess }
                Write-UserLog -DefaultMessage "Starting process '{0}' via {1}: '{2}' with args: '{3}'" -MessageId "Log_User_ProcessStarting" -MessageArgs @($processBaseNameToMonitor, $launchMethod, $exeForStartProcess, $logArgsForStart)

                Start-Process @startProcessSplat
                Add-UserAction -DefaultActionMessage "Process '{0}' started (via {1})." -ActionId "Action_User_ProcessStarted" -ActionArgs $processBaseNameToMonitor, $launchMethod

            } catch {
                $logArgsCatch = if ($argsForStartProcess -is [array]) { $argsForStartProcess -join ' ' } else { $argsForStartProcess }
                Add-UserError -DefaultErrorMessage "Failed to manage process '{0}': {1}" -ErrorId "Error_User_ProcessManagementFailed" -ErrorArgs $processBaseNameToMonitor, $_.Exception.Message
            }
        } else {
            Add-UserError -DefaultErrorMessage "Executable file for ProcessName '{0}' (direct mode) NOT FOUND." -ErrorId "Error_User_ExeNotFound" -ErrorArgs $processNameToManageExpanded
        }
    } else {
        Write-UserLog -DefaultMessage "No ProcessName specified in [Process] section." -MessageId "Log_User_NoProcessSpecified"
    }

} catch {
    if ($null -ne $Global:Config) {
        Add-UserError -DefaultErrorMessage "FATAL USER SCRIPT ERROR '{0}': {1}" -ErrorId "Error_User_FatalScriptError" -ErrorArgs $env:USERNAME, $_.Exception.Message
    } else {
        $timestampError = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $errorMsg = "$timestampError [FATAL SCRIPT USER ERROR - CONFIG NOT LOADED] - Error: $($_.Exception.Message)"
        try {
            Add-Content -Path (Join-Path $LogDirToUseUser "config_utilisateur_FATAL_ERROR.txt") -Value $errorMsg -Encoding UTF8 -ErrorAction SilentlyContinue
        } catch {
            # Ultime recours, impossible d'écrire le fichier d'erreur.
        }
    }
} finally {
    # --- Envoi de la notification Gotify (si configurée) ---
    if ($Global:Config -and (Get-ConfigValue -Section "Gotify" -Key "EnableGotify" -Type ([bool]))) {
        $gotifyUrl = Get-ConfigValue -Section "Gotify" -Key "Url"
        $gotifyToken = Get-ConfigValue -Section "Gotify" -Key "Token"
        $gotifyPriority = Get-ConfigValue -Section "Gotify" -Key "Priority" -Type ([int]) -DefaultValue 5

        if ((-not [string]::IsNullOrWhiteSpace($gotifyUrl)) -and (-not [string]::IsNullOrWhiteSpace($gotifyToken))) {
            $titleSuccessTemplateUser = Get-ConfigValue -Section "Gotify" -Key "GotifyTitleSuccessUser" -DefaultValue ("%COMPUTERNAME% %USERNAME% " + $ScriptIdentifierUser + " OK")
            $titleErrorTemplateUser = Get-ConfigValue -Section "Gotify" -Key "GotifyTitleErrorUser" -DefaultValue ("ERROR " + $ScriptIdentifierUser + " %USERNAME% on %COMPUTERNAME%")

            $finalMessageTitleUser = if ($Global:UserErreursRencontrees.Count -gt 0) {
                $titleErrorTemplateUser -replace "%COMPUTERNAME%", $env:COMPUTERNAME -replace "%USERNAME%", $env:USERNAME
            } else {
                $titleSuccessTemplateUser -replace "%COMPUTERNAME%", $env:COMPUTERNAME -replace "%USERNAME%", $env:USERNAME
            }

            $dateStr = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            $dateLineTemplate = if ($lang -and $lang.ContainsKey('Gotify_MessageDate')) { $lang.Gotify_MessageDate } else { "On {0}." }
            $messageBodyUser = ($dateLineTemplate -f $dateStr) + "`n"

            if ($Global:UserActionsEffectuees.Count -gt 0) {
                $actionsHeader = if ($lang -and $lang.ContainsKey('Gotify_UserActionsHeader')) { $lang.Gotify_UserActionsHeader } else { "USER Actions:" }
                $messageBodyUser += "$actionsHeader`n" + ($Global:UserActionsEffectuees -join "`n")
            } else {
                $noActionsMessage = if ($lang -and $lang.ContainsKey('Gotify_NoUserActions')) { $lang.Gotify_NoUserActions } else { "No USER actions." }
                $messageBodyUser += $noActionsMessage
            }

            if ($Global:UserErreursRencontrees.Count -gt 0) {
                $errorsHeader = if ($lang -and $lang.ContainsKey('Gotify_UserErrorsHeader')) { $lang.Gotify_UserErrorsHeader } else { "USER Errors:" }
                $messageBodyUser += "`n`n$errorsHeader`n" + ($Global:UserErreursRencontrees -join "`n")
            }

            $payloadUser = @{
                message  = $messageBodyUser
                title    = $finalMessageTitleUser
                priority = $gotifyPriority
            } | ConvertTo-Json -Depth 3 -Compress

            $fullUrlUser = "$($gotifyUrl.TrimEnd('/'))/message?token=$gotifyToken"

            try {
                Invoke-RestMethod -Uri $fullUrlUser -Method Post -Body $payloadUser -ContentType "application/json; charset=utf-8" -TimeoutSec 30 -ErrorAction Stop
            }
            catch {
                Add-UserError -DefaultErrorMessage "Gotify notification (IRM) failed: $($_.Exception.Message)"
            }
        } else {
            Add-UserError -DefaultErrorMessage "Gotify parameters are incomplete in config.ini for user script."
        }
    }

    Write-UserLog -DefaultMessage "{0} ({1}) for '{2}' finished." -MessageId "Log_User_ScriptFinished" -MessageArgs $ScriptIdentifierUser, $ScriptInternalBuildUser, $env:USERNAME
    if ($Global:UserErreursRencontrees.Count -gt 0) {
        Write-UserLog -DefaultMessage "Errors occurred during execution." -MessageId "Log_ErrorsOccurred" -Level WARN
    }
}
