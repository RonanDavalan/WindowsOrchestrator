param(
    # Accepte un argument de langue optionnel depuis la ligne de commande (ex: "en" ou "fr")
    [string]$LanguageOverride = ""
)

<#
.SYNOPSIS
    Assistant de configuration graphique pour WindowsOrchestrator.
.DESCRIPTION
    Ce script lance une interface graphique (GUI) qui permet à l'utilisateur de configurer
    facilement les options essentielles du projet. Il gère la création du fichier config.ini
    à partir d'un modèle par défaut et sauvegarde les choix de l'utilisateur.
.PARAMETER LanguageOverride
    Permet de forcer l'utilisation d'une langue spécifique pour l'interface (ex: "en-US", "fr-FR").
    DEPRECATED: Force le script à s'exécuter en anglais. La langue est maintenant détectée
    automatiquement. Ce paramètre sera supprimé dans une future version.
.EXAMPLE
    PS C:\Chemin\Vers\Script\> .\config-gui.ps1

    Lance l'assistant de configuration graphique.
.NOTES
    Auteur: Ronan Davalan & Gemini
    Version: i18n - Logique de chargement modifiée
#>

#=======================================================================================================================
# --- Définition des Fonctions ---
#=======================================================================================================================

<#
.SYNOPSIS
    Lit une valeur spécifique dans un fichier de configuration au format INI.
.DESCRIPTION
    Parcourt un fichier .ini pour trouver une section et une clé spécifiques et retourne la valeur correspondante.
    Si le fichier, la section ou la clé n'existent pas, la fonction retourne une valeur par défaut fournie.
.PARAMETER FilePath
    Chemin complet vers le fichier .ini.
.PARAMETER Section
    Le nom de la section (ex: "[SystemConfig]") dans laquelle chercher la clé.
.PARAMETER Key
    Le nom de la clé dont la valeur doit être récupérée.
.PARAMETER DefaultValue
    La valeur à retourner si la clé n'est pas trouvée ou si le fichier n'existe pas.
.RETURNS
    [string] La valeur trouvée, ou la valeur par défaut si elle n'est pas trouvée.
.EXAMPLE
    PS C:\> $rebootTime = Get-IniValue -FilePath "C:\temp\config.ini" -Section "SystemConfig" -Key "ScheduledRebootTime" -DefaultValue "03:00"
#>
function Get-IniValue {
    param($FilePath, $Section, $Key, $DefaultValue = "")
    if (-not (Test-Path $FilePath -PathType Leaf)) { return $DefaultValue }
    $iniContent = Get-Content $FilePath -Encoding UTF8 -ErrorAction SilentlyContinue
    $inSection = $false
    foreach ($line in $iniContent) {
        if ($line.Trim() -eq "[$Section]") { $inSection = $true; continue }
        if ($line.Trim().StartsWith("[") -and $inSection) { $inSection = $false; break }
        if ($inSection -and $line -match "^$([regex]::Escape($Key))\s*=(.*)") { return $matches[1].Trim() }
    }
    return $DefaultValue
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
    Crée, configure et ajoute une case à cocher à un formulaire Windows Forms.
.DESCRIPTION
    Fonction utilitaire conçue pour réduire la répétition de code lors de la création de l'interface graphique.
    Elle automatise la création d'une CheckBox et gère sa position verticale en mettant à jour une variable
    de position passée par référence.
.PARAMETER FormInst
    L'instance de l'objet Formauquel la case à cocher doit être ajoutée.
.PARAMETER KeyName
    Un nom de variable unique pour la case à cocher (ex: "cbDisableFastStartup").
.PARAMETER LabelText
    Le texte qui sera affiché à côté de la case à cocher.
.PARAMETER YPos_ref
    Une référence ([ref]) à la variable qui suit la position verticale (Y) pour le prochain contrôle.
    La fonction incrémente cette valeur après avoir placé la case à cocher.
.PARAMETER InitialValue
    La valeur booléenne (`$true` ou `$false`) pour déterminer si la case est cochée initialement.
.PARAMETER LocalXPadding
    La coordonnée horizontale (X) où la case à cocher sera placée.
.PARAMETER LocalItemSpacing
    L'espacement vertical à ajouter après la case à cocher.
.EXAMPLE
    # Utilisation à l'intérieur du script :
    # Create-And-Add-Checkbox $form "EnableAutoLogin" "Activer l'autologin" ([ref]$yCurrent) $true 20 5
#>
function Create-And-Add-Checkbox {
    param($FormInst, $KeyName, $LabelText, [ref]$YPos_ref, $InitialValue, [int]$LocalXPadding, [int]$LocalItemSpacing)
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Name = "cb$KeyName"
    $cb.Text = $LabelText
    $cb.Checked = $InitialValue
    $cb.Location = New-Object System.Drawing.Point([int]$LocalXPadding, [int]$YPos_ref.Value)
    $cb.AutoSize = $true
    $FormInst.Controls.Add($cb)
    $YPos_ref.Value += [int]($cb.Height + $LocalItemSpacing)
}

#=======================================================================================================================
# --- DÉBUT DU SCRIPT PRINCIPAL ---
#=======================================================================================================================

#region Initialisation et Prérequis
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Bloc d'Internationalisation (i18n) ---
$lang = @{}
try {
    # La détermination du chemin du script doit gérer plusieurs environnements d'exécution (console, ISE, etc.),
    # d'où la nécessité de tester le type de commande pour trouver le chemin de manière fiable.
    if ($MyInvocation.MyCommand.CommandType -eq 'ExternalScript') { $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition }
    else { try { $PSScriptRoot = Split-Path -Parent $script:MyInvocation.MyCommand.Path -ErrorAction Stop } catch { $PSScriptRoot = Get-Location } }

    $projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\")).Path

    $cultureName = (Get-Culture).Name
    $langFilePath = Join-Path $projectRoot "i18n\$cultureName\strings.psd1"
    if (-not (Test-Path $langFilePath)) {
        $langFilePath = Join-Path $projectRoot "i18n\en-US\strings.psd1"
    }

    if (Test-Path $langFilePath) {
        $langContent = Get-Content -Path $langFilePath -Raw -Encoding UTF8
        $lang = Invoke-Expression $langContent
    } else {
        throw "Aucun fichier de langue valide (ni pour $cultureName, ni en-US) n'a été trouvé."
    }

    if ($null -eq $lang -or $lang.Count -eq 0) {
        throw "Le fichier de langue '$langFilePath' a été trouvé mais n'a retourné aucune donnée."
    }
} catch {
    $errorMessage = "FATAL ERROR: Could not load language files.`n`n"
    $errorMessage += "Technical Details: $($_.Exception.Message)"
    [System.Windows.Forms.MessageBox]::Show($errorMessage, "Language Error", "OK", "Error")
    exit 1
}

try {
    $ProjectRootDir = $projectRoot
    $ConfigIniPath = Join-Path $ProjectRootDir "config.ini"
    $DefaultConfigPath = Join-Path $PSScriptRoot "defaults\default_config.ini"
} catch {
    $errorMsg = ($lang.ConfigForm_PathError -f $_.Exception.Message)
    $errorCaption = $lang.ConfigForm_PathErrorCaption
    [System.Windows.Forms.MessageBox]::Show($errorMsg, $errorCaption, "OK", "Error")
    exit 1
}
#endregion Initialisation et Prérequis

#region Gestion du Fichier de Configuration
if (-not (Test-Path $DefaultConfigPath -PathType Leaf)) {
    if (-not (Test-Path $ConfigIniPath -PathType Leaf)) {
        [System.Windows.Forms.MessageBox]::Show($lang.ConfigForm_ModelFileNotFoundError, $lang.ConfigForm_ModelFileNotFoundCaption, "OK", "Error")
        exit 1
    }
} else {
    if (-not (Test-Path $ConfigIniPath -PathType Leaf)) {
        try {
            Copy-Item -Path $DefaultConfigPath -Destination $ConfigIniPath -Force -ErrorAction Stop
        } catch {
            [System.Windows.Forms.MessageBox]::Show(($lang.ConfigForm_CopyError -f $_.Exception.Message), $lang.ConfigForm_CopyErrorCaption, "OK", "Error")
            exit 1
        }
    } else {
        $message = $lang.ConfigForm_OverwritePrompt
        $caption = $lang.ConfigForm_OverwriteCaption
        $result = [System.Windows.Forms.MessageBox]::Show($message, $caption, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning, [System.Windows.Forms.MessageBoxDefaultButton]::Button2)
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            try {
                Copy-Item -Path $DefaultConfigPath -Destination $ConfigIniPath -Force -ErrorAction Stop
                [System.Windows.Forms.MessageBox]::Show($lang.ConfigForm_ResetSuccess, $lang.ConfigForm_ResetSuccessCaption, "OK", "Information")
            } catch {
                [System.Windows.Forms.MessageBox]::Show(($lang.ConfigForm_OverwriteError -f $_.Exception.Message), $lang.ConfigForm_OverwriteErrorCaption, "OK", "Error")
                exit 1
            }
        }
    }
}
#endregion Gestion du Fichier de Configuration

#region Création du Formulaire
$form = New-Object System.Windows.Forms.Form
$form.Text = $lang.ConfigForm_Title
$form.Size = New-Object System.Drawing.Size(590, 530)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false
#endregion Création du Formulaire

#region Chargement des Valeurs Initiales depuis config.ini
$defaultValues = @{
    AutoLoginUsername = ""; DisableFastStartup = $true; DisableSleep = $true
    DisableScreenSleep = $false; EnableAutoLogin = $true; DisableWindowsUpdate = $true
    DisableAutoReboot = $true; PreRebootActionTime = "02:55"; PreRebootActionCommand = ""
    PreRebootActionArguments = ""; PreRebootActionLaunchMethod = "cmd"
    ScheduledRebootTime = "03:00"; DisableOneDrive = $true; ProcessName = ""
    ProcessArguments = ""; LaunchMethod = "cmd"; Language = "en"
}
$currentValues = @{}
foreach ($key in $defaultValues.Keys) {
    $section = "SystemConfig" # Par défaut
    if ($key -in ("ProcessName", "ProcessArguments", "LaunchMethod")) { $section = "Process" }
    if ($key -in ("Language", "EnableLogRotation", "MaxSystemLogsToKeep", "MaxUserLogsToKeep")) { $section = "Logging" }

    $rawValue = Get-IniValue -FilePath $ConfigIniPath -Section $section -Key $key -DefaultValue $defaultValues[$key]

    # Les fichiers INI ne stockent que des chaînes. Il faut donc convertir explicitement
    # les valeurs "true"/"false" en booléens PowerShell pour les contrôles CheckBox.
    if ($defaultValues[$key] -is [boolean]) {
        if ($rawValue -is [boolean]) { $currentValues[$key] = $rawValue }
        elseif ([string]::IsNullOrWhiteSpace($rawValue.ToString())) { $currentValues[$key] = $defaultValues[$key] }
        else {
            if ($rawValue.ToString().ToLower() -eq "true" -or $rawValue.ToString() -eq "1") { $currentValues[$key] = $true }
            elseif ($rawValue.ToString().ToLower() -eq "false" -or $rawValue.ToString() -eq "0") { $currentValues[$key] = $false }
            else { $currentValues[$key] = $defaultValues[$key] }
        }
    } else { $currentValues[$key] = $rawValue }
}
#endregion Chargement des Valeurs Initiales

#region Création des Contrôles de l'UI

# --- Définition des variables de mise en page ---
# Ces variables contrôlent le positionnement et la taille des éléments dans le formulaire.
[int]$xPadding = 20          # Marge horizontale depuis le bord du formulaire.
[int]$yCurrent = 20          # Coordonnée Y de départ, qui sera incrémentée pour chaque nouveau contrôle.
[int]$lblWidth = 230         # Largeur standard pour les étiquettes (Labels).
[int]$ctrlWidth = 270        # Largeur standard pour les contrôles (TextBox, etc.).
[int]$ctrlHeight = 20        # Hauteur standard pour les contrôles.
[int]$itemSpacing = 5        # Espace horizontal entre un label et son contrôle, ou vertical entre les éléments.
[int]$sectionSpacing = 10    # Espace vertical supplémentaire pour séparer les groupes de contrôles.
[int]$itemTotalHeight = $ctrlHeight + $itemSpacing # Hauteur totale d'un contrôle + son espacement vertical.


# --- Contrôle : Nom d'utilisateur pour l'AutoLogin (Label + TextBox) ---

# 1. Création de l'étiquette (Label)
$lblAutoLoginUsername = New-Object System.Windows.Forms.Label
$lblAutoLoginUsername.Text = $lang.ConfigForm_AutoLoginUsernameLabel
$lblAutoLoginUsername.Location = New-Object System.Drawing.Point($xPadding, $yCurrent)
$lblAutoLoginUsername.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight)
$form.Controls.Add($lblAutoLoginUsername)

# 2. Création de la zone de texte (TextBox)
$txtAutoLoginUsername = New-Object System.Windows.Forms.TextBox
$txtAutoLoginUsername.Text = $currentValues.AutoLoginUsername
$txtAutoLoginUsername.Location = New-Object System.Drawing.Point(($xPadding + $lblWidth + $itemSpacing), $yCurrent)
$txtAutoLoginUsername.Size = New-Object System.Drawing.Size($ctrlWidth, $ctrlHeight)
$form.Controls.Add($txtAutoLoginUsername)

# 3. Mise à jour de la position verticale pour le prochain contrôle
$yCurrent += $itemTotalHeight

#endregion Création des Contrôles de l'UI

$checkboxes = @(
    @{Name="DisableFastStartup"; Label=$lang.ConfigForm_DisableFastStartupCheckbox; Initial=$currentValues.DisableFastStartup},
    @{Name="DisableSleep"; Label=$lang.ConfigForm_DisableSleepCheckbox; Initial=$currentValues.DisableSleep},
    @{Name="DisableScreenSleep"; Label=$lang.ConfigForm_DisableScreenSleepCheckbox; Initial=$currentValues.DisableScreenSleep},
    @{Name="EnableAutoLogin"; Label=$lang.ConfigForm_EnableAutoLoginCheckbox; Initial=$currentValues.EnableAutoLogin},
    @{Name="DisableWindowsUpdate"; Label=$lang.ConfigForm_DisableWindowsUpdateCheckbox; Initial=$currentValues.DisableWindowsUpdate},
    @{Name="DisableAutoReboot"; Label=$lang.ConfigForm_DisableAutoRebootCheckbox; Initial=$currentValues.DisableAutoReboot},
    @{Name="DisableOneDrive"; Label=$lang.ConfigForm_DisableOneDriveCheckbox; Initial=$currentValues.DisableOneDrive}
)
# --- Boucle pour les cases à cocher (déjà bien structurée) ---
foreach ($cbInfo in $checkboxes) {
    Create-And-Add-Checkbox -FormInst $form -KeyName $cbInfo.Name -LabelText $cbInfo.Label -YPos_ref ([ref]$yCurrent) -InitialValue $cbInfo.Initial -LocalXPadding $xPadding -LocalItemSpacing $itemSpacing
}

$yCurrent += $sectionSpacing

# --- Contrôle : Heure de l'action pré-redémarrage (Label + TextBox) ---
$lblPreRebootActionTime = New-Object System.Windows.Forms.Label
$lblPreRebootActionTime.Text = $lang.ConfigForm_PreRebootActionTimeLabel
$lblPreRebootActionTime.Location = New-Object System.Drawing.Point($xPadding, $yCurrent)
$lblPreRebootActionTime.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight)
$form.Controls.Add($lblPreRebootActionTime)

$txtPreRebootActionTime = New-Object System.Windows.Forms.TextBox
$txtPreRebootActionTime.Text = $currentValues.PreRebootActionTime
$txtPreRebootActionTime.Location = New-Object System.Drawing.Point(($xPadding + $lblWidth + $itemSpacing), $yCurrent)
$txtPreRebootActionTime.Size = New-Object System.Drawing.Size(100, $ctrlHeight)
$form.Controls.Add($txtPreRebootActionTime)

$yCurrent += $itemTotalHeight

# --- Contrôle : Commande de l'action pré-redémarrage (Label + TextBox) ---
$lblPreRebootActionCommand = New-Object System.Windows.Forms.Label
$lblPreRebootActionCommand.Text = $lang.ConfigForm_PreRebootActionCommandLabel
$lblPreRebootActionCommand.Location = New-Object System.Drawing.Point($xPadding, $yCurrent)
$lblPreRebootActionCommand.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight)
$form.Controls.Add($lblPreRebootActionCommand)

$txtPreRebootActionCommand = New-Object System.Windows.Forms.TextBox
$txtPreRebootActionCommand.Text = $currentValues.PreRebootActionCommand
$txtPreRebootActionCommand.Location = New-Object System.Drawing.Point(($xPadding + $lblWidth + $itemSpacing), $yCurrent)
$txtPreRebootActionCommand.Size = New-Object System.Drawing.Size($ctrlWidth, $ctrlHeight)
$form.Controls.Add($txtPreRebootActionCommand)

$yCurrent += $itemTotalHeight

# --- Contrôle : Arguments de l'action pré-redémarrage (Label + TextBox) ---
$lblPreRebootActionArguments = New-Object System.Windows.Forms.Label
$lblPreRebootActionArguments.Text = $lang.ConfigForm_PreRebootActionArgumentsLabel
$lblPreRebootActionArguments.Location = New-Object System.Drawing.Point($xPadding, $yCurrent)
$lblPreRebootActionArguments.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight)
$form.Controls.Add($lblPreRebootActionArguments)

$txtPreRebootActionArguments = New-Object System.Windows.Forms.TextBox
$txtPreRebootActionArguments.Text = $currentValues.PreRebootActionArguments
$txtPreRebootActionArguments.Location = New-Object System.Drawing.Point(($xPadding + $lblWidth + $itemSpacing), $yCurrent)
$txtPreRebootActionArguments.Size = New-Object System.Drawing.Size($ctrlWidth, $ctrlHeight)
$form.Controls.Add($txtPreRebootActionArguments)

$yCurrent += $itemTotalHeight

# --- Contrôle : Méthode de lancement de l'action (Label + ComboBox) ---
$lblPreRebootActionLaunchMethod = New-Object System.Windows.Forms.Label
$lblPreRebootActionLaunchMethod.Text = $lang.ConfigForm_PreRebootActionLaunchMethodLabel
$lblPreRebootActionLaunchMethod.Location = New-Object System.Drawing.Point($xPadding, $yCurrent)
$lblPreRebootActionLaunchMethod.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight)
$form.Controls.Add($lblPreRebootActionLaunchMethod)

$cmbPreRebootActionLaunchMethod = New-Object System.Windows.Forms.ComboBox
$cmbPreRebootActionLaunchMethod.Items.AddRange(@("direct", "powershell", "cmd"))
$cmbPreRebootActionLaunchMethod.Text = $currentValues.PreRebootActionLaunchMethod
$cmbPreRebootActionLaunchMethod.DropDownStyle = "DropDownList"
$cmbPreRebootActionLaunchMethod.Location = New-Object System.Drawing.Point(($xPadding + $lblWidth + $itemSpacing), $yCurrent)
$cmbPreRebootActionLaunchMethod.Size = New-Object System.Drawing.Size(100, $ctrlHeight)
$form.Controls.Add($cmbPreRebootActionLaunchMethod)

$yCurrent += $itemTotalHeight + $sectionSpacing

# --- Contrôle : Heure du redémarrage planifié (Label + TextBox) ---
$lblScheduledRebootTime = New-Object System.Windows.Forms.Label
$lblScheduledRebootTime.Text = $lang.ConfigForm_ScheduledRebootTimeLabel
$lblScheduledRebootTime.Location = New-Object System.Drawing.Point($xPadding, $yCurrent)
$lblScheduledRebootTime.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight)
$form.Controls.Add($lblScheduledRebootTime)

$txtScheduledRebootTime = New-Object System.Windows.Forms.TextBox
$txtScheduledRebootTime.Text = $currentValues.ScheduledRebootTime
$txtScheduledRebootTime.Location = New-Object System.Drawing.Point(($xPadding + $lblWidth + $itemSpacing), $yCurrent)
$txtScheduledRebootTime.Size = New-Object System.Drawing.Size(100, $ctrlHeight)
$form.Controls.Add($txtScheduledRebootTime)

$yCurrent += $itemTotalHeight + $sectionSpacing

# --- Contrôle : Nom du processus (Label + TextBox) ---
$lblProcessName = New-Object System.Windows.Forms.Label
$lblProcessName.Text = $lang.ConfigForm_ProcessNameLabel
$lblProcessName.Location = New-Object System.Drawing.Point($xPadding, $yCurrent)
$lblProcessName.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight)
$form.Controls.Add($lblProcessName)

$txtProcessName = New-Object System.Windows.Forms.TextBox
$txtProcessName.Text = $currentValues.ProcessName
$txtProcessName.Location = New-Object System.Drawing.Point(($xPadding + $lblWidth + $itemSpacing), $yCurrent)
$txtProcessName.Size = New-Object System.Drawing.Size($ctrlWidth, $ctrlHeight)
$form.Controls.Add($txtProcessName)

$yCurrent += $itemTotalHeight

# --- Contrôle : Arguments du processus (Label + TextBox) ---
$lblProcessArguments = New-Object System.Windows.Forms.Label
$lblProcessArguments.Text = $lang.ConfigForm_ProcessArgumentsLabel
$lblProcessArguments.Location = New-Object System.Drawing.Point($xPadding, $yCurrent)
$lblProcessArguments.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight)
$form.Controls.Add($lblProcessArguments)

$txtProcessArguments = New-Object System.Windows.Forms.TextBox
$txtProcessArguments.Text = $currentValues.ProcessArguments
$txtProcessArguments.Location = New-Object System.Drawing.Point(($xPadding + $lblWidth + $itemSpacing), $yCurrent)
$txtProcessArguments.Size = New-Object System.Drawing.Size($ctrlWidth, $ctrlHeight)
$form.Controls.Add($txtProcessArguments)

$yCurrent += $itemTotalHeight

# --- Contrôle : Méthode de lancement du processus (Label + ComboBox) ---
$lblLaunchMethod = New-Object System.Windows.Forms.Label
$lblLaunchMethod.Text = $lang.ConfigForm_LaunchMethodLabel
$lblLaunchMethod.Location = New-Object System.Drawing.Point($xPadding, $yCurrent)
$lblLaunchMethod.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight)
$form.Controls.Add($lblLaunchMethod)

$cmbLaunchMethod = New-Object System.Windows.Forms.ComboBox
$cmbLaunchMethod.Items.AddRange(@("direct", "powershell", "cmd"))
$cmbLaunchMethod.Text = $currentValues.LaunchMethod
$cmbLaunchMethod.DropDownStyle = "DropDownList"
$cmbLaunchMethod.Location = New-Object System.Drawing.Point(($xPadding + $lblWidth + $itemSpacing), $yCurrent)
$cmbLaunchMethod.Size = New-Object System.Drawing.Size(100, $ctrlHeight)
$form.Controls.Add($cmbLaunchMethod)

$yCurrent += $itemTotalHeight
#endregion Création des Contrôles

#region Création des Boutons

# --- Bouton Enregistrer ---

# Calcul de la position du bouton "Enregistrer"
$buttonY = $yCurrent + $sectionSpacing # Ajoute un espacement au-dessus des boutons
$buttonSaveX = $xPadding + ($lblWidth / 2)

$btnSave = New-Object System.Windows.Forms.Button
$btnSave.Text = $lang.ConfigForm_SaveButton
$btnSave.Size = New-Object System.Drawing.Size(150, 30)
$btnSave.Location = New-Object System.Drawing.Point($buttonSaveX, $buttonY)
$btnSave.DialogResult = [System.Windows.Forms.DialogResult]::OK

# Définit ce bouton comme celui qui est activé par la touche "Entrée"
$form.AcceptButton = $btnSave
$form.Controls.Add($btnSave)


# --- Bouton Annuler ---

# Calcule la position du bouton "Annuler" par rapport au bouton "Enregistrer"
$buttonCancelX = $buttonSaveX + $btnSave.Width + $itemSpacing

$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Text = $lang.ConfigForm_CancelButton
$btnCancel.Size = New-Object System.Drawing.Size(100, 30)
$btnCancel.Location = New-Object System.Drawing.Point($buttonCancelX, $buttonY) # Même hauteur (Y) que le bouton Enregistrer
$btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

# Définit ce bouton comme celui qui est activé par la touche "Échap"
$form.CancelButton = $btnCancel
$form.Controls.Add($btnCancel)


# --- Ajustement final de la taille du formulaire ---

# Redimensionne la hauteur du formulaire pour s'adapter parfaitement aux boutons,
# en ajoutant une marge en dessous égale au padding initial.
$newFormHeight = $buttonY + $btnSave.Height + $xPadding
$form.ClientSize = New-Object System.Drawing.Size($form.ClientSize.Width, $newFormHeight)
#endregion Création des Boutons

#region Gestionnaires d'Événements du Formulaire
$btnSave.Add_Click({
    if (($txtPreRebootActionTime.Text -ne "" -and $txtPreRebootActionTime.Text -notmatch "^\d{2}:\d{2}$") -or ($txtScheduledRebootTime.Text -ne "" -and $txtScheduledRebootTime.Text -notmatch "^\d{2}:\d{2}$")) {
        [System.Windows.Forms.MessageBox]::Show($lang.ConfigForm_InvalidTimeFormat, $lang.ConfigForm_InvalidTimeFormatCaption, "OK", "Warning")
        $form.DialogResult = [System.Windows.Forms.DialogResult]::None; return
    }
    Set-IniValue $ConfigIniPath "SystemConfig" "AutoLoginUsername" $txtAutoLoginUsername.Text
    Set-IniValue $ConfigIniPath "SystemConfig" "EnableAutoLogin" $form.Controls["cbEnableAutoLogin"].Checked.ToString().ToLower()
    Set-IniValue $ConfigIniPath "SystemConfig" "DisableFastStartup" $form.Controls["cbDisableFastStartup"].Checked.ToString().ToLower()
    Set-IniValue $ConfigIniPath "SystemConfig" "DisableSleep" $form.Controls["cbDisableSleep"].Checked.ToString().ToLower()
    Set-IniValue $ConfigIniPath "SystemConfig" "DisableScreenSleep" $form.Controls["cbDisableScreenSleep"].Checked.ToString().ToLower()
    Set-IniValue $ConfigIniPath "SystemConfig" "DisableWindowsUpdate" $form.Controls["cbDisableWindowsUpdate"].Checked.ToString().ToLower()
    Set-IniValue $ConfigIniPath "SystemConfig" "DisableAutoReboot" $form.Controls["cbDisableAutoReboot"].Checked.ToString().ToLower()
    Set-IniValue $ConfigIniPath "SystemConfig" "ScheduledRebootTime" $txtScheduledRebootTime.Text
    Set-IniValue $ConfigIniPath "SystemConfig" "PreRebootActionTime" $txtPreRebootActionTime.Text
    Set-IniValue $ConfigIniPath "SystemConfig" "PreRebootActionCommand" $txtPreRebootActionCommand.Text
    Set-IniValue $ConfigIniPath "SystemConfig" "PreRebootActionArguments" $txtPreRebootActionArguments.Text
    Set-IniValue $ConfigIniPath "SystemConfig" "PreRebootActionLaunchMethod" $cmbPreRebootActionLaunchMethod.Text
    Set-IniValue $ConfigIniPath "SystemConfig" "DisableOneDrive" $form.Controls["cbDisableOneDrive"].Checked.ToString().ToLower()
    Set-IniValue $ConfigIniPath "Process" "ProcessName" $txtProcessName.Text
    Set-IniValue $ConfigIniPath "Process" "ProcessArguments" $txtProcessArguments.Text
    Set-IniValue $ConfigIniPath "Process" "LaunchMethod" $cmbLaunchMethod.Text

    $detectedLanguageShort = ($cultureName.Split('-'))[0]
    Set-IniValue $ConfigIniPath "Logging" "Language" $detectedLanguageShort

    [System.Windows.Forms.MessageBox]::Show(($lang.ConfigForm_SaveSuccessMessage -f $ConfigIniPath), $lang.ConfigForm_SaveSuccessCaption, "OK", "Information")
})
$form.Add_FormClosing({ param($sender, $e)
    if ($form.DialogResult -ne [System.Windows.Forms.DialogResult]::OK) {}
})
#endregion Gestionnaires d'Événements

#region Affichage du Formulaire
[System.Windows.Forms.Application]::EnableVisualStyles()
$DialogResult = $form.ShowDialog()

if ($DialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
    exit 0
} else {
    Write-Host $lang.ConfigForm_ConfigWizardCancelled -ForegroundColor Yellow
    exit 1
}
#endregion Affichage du Formulaire
