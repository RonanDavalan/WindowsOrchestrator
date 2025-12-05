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
    Projet      : WindowsOrchestrator
    Version     : 1.72
    Licence     : GNU GPLv3

    --- CRÉDITS & RÔLES ---
    Ce projet est le fruit d'une collaboration hybride Humain-IA :

    Architecte Principal & QA      : Ronan Davalan
    Architecte IA & Planification  : Google Gemini
    Développeur IA Principal       : Grok (xAI)
    Consultant Technique IA        : Claude (Anthropic)
#>



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
    $ScriptDir = $PSScriptRoot
    $ProjectRootDir = (Resolve-Path (Join-Path $ScriptDir "..\")).Path

    $cultureName = (Get-Culture).Name
    $langFilePath = Join-Path $ProjectRootDir "i18n\$cultureName\strings.psd1"
    if (-not (Test-Path $langFilePath)) {
        $langFilePath = Join-Path $ProjectRootDir "i18n\en-US\strings.psd1"
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

# --- Importation du Module Utilitaire Central ---
try {
    $modulePath = Join-Path $PSScriptRoot "modules\WindowsOrchestratorUtils\WindowsOrchestratorUtils.psm1"
    Import-Module $modulePath -Force
} catch {
    $errorMessage = "FATAL ERROR: Could not load the core module 'WindowsOrchestratorUtils.psm1'.`n`n"
    $errorMessage += "Technical Details: $($_.Exception.Message)"
    [System.Windows.Forms.MessageBox]::Show($errorMessage, "Module Error", "OK", "Error")
    exit 1
}

try {
    $ProjectRootDir = $ProjectRootDir
    $ConfigFile = Join-Path $ProjectRootDir "config.ini"
    $DefaultConfigPath = Join-Path $ScriptDir "defaults\default_config.ini"
} catch {
    $errorMsg = ($lang.ConfigForm_PathError -f $_.Exception.Message)
    $errorCaption = $lang.ConfigForm_PathErrorCaption
    [System.Windows.Forms.MessageBox]::Show($errorMsg, $errorCaption, "OK", "Error")
    exit 1
}
#endregion Initialisation et Prérequis

#region Gestion du Fichier de Configuration
$configWasCreated = $false  # Variable pour tracer si on a créé le fichier

if (-not (Test-Path $DefaultConfigPath -PathType Leaf)) {
    # Le modèle n'existe pas
    if (-not (Test-Path $ConfigFile -PathType Leaf)) {
        # Ni le modèle ni config.ini n'existent - ERREUR FATALE
        [System.Windows.Forms.MessageBox]::Show(
            $lang.ConfigForm_ModelFileNotFoundError, 
            $lang.ConfigForm_ModelFileNotFoundCaption, 
            "OK", 
            "Error"
        )
        exit 1
    }
    # Le modèle n'existe pas mais config.ini existe déjà - on continue normalement
} else {
    # Le modèle existe
    if (-not (Test-Path $ConfigFile -PathType Leaf)) {
        # config.ini n'existe pas - on le crée depuis le modèle
        try {
            Copy-Item -Path $DefaultConfigPath -Destination $ConfigFile -Force -ErrorAction Stop
            $configWasCreated = $true  # MARQUE que le fichier a été créé
            
            # AFFICHAGE IMMÉDIAT du message de création
            [System.Windows.Forms.MessageBox]::Show(
                ($lang.ConfigForm_SaveSuccessMessage -f $ConfigFile),
                $lang.ConfigForm_ResetSuccessCaption,
                "OK",
                "Information"
            )
        } catch {
            [System.Windows.Forms.MessageBox]::Show(
                ($lang.ConfigForm_CopyError -f $_.Exception.Message), 
                $lang.ConfigForm_CopyErrorCaption, 
                "OK", 
                "Error"
            )
            exit 1
        }
    } else {
        # Les deux existent - demander si on veut réinitialiser
        $message = $lang.ConfigForm_OverwritePrompt.Replace('\n', "`n")
        $caption = $lang.ConfigForm_OverwriteCaption
        $result = [System.Windows.Forms.MessageBox]::Show(
            $message, 
            $caption, 
            [System.Windows.Forms.MessageBoxButtons]::YesNo, 
            [System.Windows.Forms.MessageBoxIcon]::Warning, 
            [System.Windows.Forms.MessageBoxDefaultButton]::Button2
        )
        
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            try {
                Copy-Item -Path $DefaultConfigPath -Destination $ConfigFile -Force -ErrorAction Stop
                [System.Windows.Forms.MessageBox]::Show(
                    $lang.ConfigForm_ResetSuccess, 
                    $lang.ConfigForm_ResetSuccessCaption, 
                    "OK", 
                    "Information"
                )
            } catch {
                [System.Windows.Forms.MessageBox]::Show(
                    ($lang.ConfigForm_OverwriteError -f $_.Exception.Message), 
                    $lang.ConfigForm_OverwriteErrorCaption, 
                    "OK", 
                    "Error"
                )
                exit 1
            }
        }
    }
}
#endregion Gestion du Fichier de Configuration

#region Création du Formulaire
$form = New-Object System.Windows.Forms.Form
$form.Text = $lang.ConfigForm_Title
$form.Size = New-Object System.Drawing.Size(600, 520)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false
#endregion Création du Formulaire

# --- Pré-chargement du contenu du fichier INI pour le module ---
$Global:Config = Get-IniContent -FilePath $ConfigFile

#region Chargement des Valeurs Initiales depuis config.ini
$defaultValues = @{
    AutoLoginUsername = ""; DisableFastStartup = $true; DisableSleep = $true
    DisableScreenSleep = $false; DisableWindowsUpdate = $true
    DisableAutoReboot = $true; ScheduledCloseTime = "02:55"; ScheduledCloseCommand = ""
    ScheduledCloseArguments = ""
    ScheduledRebootTime = "03:00"; OneDriveManagementMode = "Block";     ProcessToLaunch = "LaunchApp.bat"
    ProcessArguments = ""
    ProcessToMonitor = ""; StartProcessMinimized = $false; SessionStartupMode = "Standard"
    EnableBackup = $false; DatabaseSourcePath = "..\..\AllUser"; DatabaseDestinationPath = "C:\Backup\AllSys"; DatabaseKeepDays = 30; ScheduledBackupTime = "02:59"
    UseAutologonAssistant = $true; SilentMode = $false; ShowContextMessages = $true
}
$currentValues = @{}
foreach ($key in $defaultValues.Keys) {
    $section = "SystemConfig" # Par défaut
    if ($key -in ("ScheduledCloseTime", "ScheduledCloseCommand", "ScheduledCloseArguments", "ScheduledRebootTime", "ProcessToLaunch", "ProcessArguments", "ProcessToMonitor", "StartProcessMinimized")) { $section = "Process" }
    if ($key -in ("EnableLogRotation", "MaxSystemLogsToKeep", "MaxUserLogsToKeep")) { $section = "Logging" }
    if ($key -in ("EnableBackup", "DatabaseSourcePath", "DatabaseDestinationPath", "DatabaseKeepDays", "ScheduledBackupTime")) { $section = "DatabaseBackup" }
    if ($key -in ("UseAutologonAssistant", "RebootOnCompletion", "RebootGracePeriod", "PowerShellExitMode", "PowerShellExitDelay", "SilentMode", "ShowContextMessages")) { $section = "Installation" }

    $rawValue = Get-ConfigValue -Section $section -Key $key -DefaultValue $defaultValues[$key]

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
[int]$itemSpacing = 8        # Espace horizontal entre un label et son contrôle, ou vertical entre les éléments.
[int]$sectionSpacing = 10    # Espace vertical supplémentaire pour séparer les groupes de contrôles.
[int]$itemTotalHeight = $ctrlHeight + $itemSpacing # Hauteur totale d'un contrôle + son espacement vertical.

# --- Création du TabControl principal ---
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Location = New-Object System.Drawing.Point(10, 10)
$tabControl.Size = New-Object System.Drawing.Size(580, 400)
$form.Controls.Add($tabControl)

# Onglet Basique
$tabBasique = New-Object System.Windows.Forms.TabPage
$tabBasique.Text = $lang.ConfigForm_Tab_Basic
$tabControl.Controls.Add($tabBasique)

# Onglet Avancées
$tabAvancees = New-Object System.Windows.Forms.TabPage
$tabAvancees.Text = $lang.ConfigForm_Tab_Advanced
$tabControl.Controls.Add($tabAvancees)

# Sous-TabControl pour Avancées
$subTabControl = New-Object System.Windows.Forms.TabControl
$subTabControl.Location = New-Object System.Drawing.Point(0, 0)
$subTabControl.Size = New-Object System.Drawing.Size(570, 370)
$tabAvancees.Controls.Add($subTabControl)

# Sous-onglets
$subTabPrincipal = New-Object System.Windows.Forms.TabPage
$subTabPrincipal.Text = $lang.ConfigForm_SubTabMain
$subTabControl.Controls.Add($subTabPrincipal)

$subTabSauvegarde = New-Object System.Windows.Forms.TabPage
$subTabSauvegarde.Text = $lang.ConfigForm_SubTabBackup
$subTabControl.Controls.Add($subTabSauvegarde)

$subTabAutreCompte = New-Object System.Windows.Forms.TabPage
$subTabAutreCompte.Text = $lang.ConfigForm_SubTabOtherAccount
$subTabControl.Controls.Add($subTabAutreCompte)

# --- Section : Compte Utilisateur Cible (dans Autre compte) ---
$gbTargetAccount = New-Object System.Windows.Forms.GroupBox
$gbTargetAccount.Text = $lang.ConfigForm_OtherAccountGroupTitle
$gbTargetAccount.Location = New-Object System.Drawing.Point($xPadding, 20)
$gbTargetAccount.Size = New-Object System.Drawing.Size(530, 110)
$subTabAutreCompte.Controls.Add($gbTargetAccount)

$lblDescription = New-Object System.Windows.Forms.Label
$lblDescription.Text = $lang.ConfigForm_OtherAccountDescription
$lblDescription.Location = New-Object System.Drawing.Point(10, 25)
$lblDescription.Size = New-Object System.Drawing.Size(510, 40)
$gbTargetAccount.Controls.Add($lblDescription)

$lblUsername = New-Object System.Windows.Forms.Label
$lblUsername.Text = $lang.ConfigForm_OtherAccountUsernameLabel
$lblUsername.Location = New-Object System.Drawing.Point(10, 75)
$lblUsername.AutoSize = $true
$gbTargetAccount.Controls.Add($lblUsername)

$usernameVal = Get-ConfigValue -Section "SystemConfig" -Key "AutoLoginUsername"
if ([string]::IsNullOrWhiteSpace($usernameVal)) { $usernameVal = $env:USERNAME }
$txtUsername = New-Object System.Windows.Forms.TextBox
$txtUsername.Name = "txtUsername"
$txtUsername.Text = $usernameVal
$txtUsername.Location = New-Object System.Drawing.Point(280, 72)
$txtUsername.Size = New-Object System.Drawing.Size(200, 20)
$gbTargetAccount.Controls.Add($txtUsername)

# --- Section : Gestion de la Session Automatique ---

# Ajout du Label AllSys (Position Absolue Haute) - AFFICHE AVANT TOUT AUTRE CONTRÔLE
$yBasique = 20 # Réinitialisation de la position Y
if ($currentValues.ProcessToMonitor -eq "MyApp" -and $currentValues.ShowContextMessages) {
    $lblAllSys = New-Object System.Windows.Forms.Label
    $lblAllSys.Text = $lang.ConfigForm_AllSysOptimizedNote
    $lblAllSys.ForeColor = [System.Drawing.Color]::FromArgb(0, 102, 204)
    $lblAllSys.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $lblAllSys.Size = New-Object System.Drawing.Size(510, 60) # Taille fixe pour multi-lignes
    $lblAllSys.AutoSize = $false
    $lblAllSys.Location = New-Object System.Drawing.Point($xPadding, $yBasique)
    $tabBasique.Controls.Add($lblAllSys)
    $yBasique += $lblAllSys.Height + $sectionSpacing # Mise à jour de Y
}

# 1. Case à cocher principale
$cbEnableSessionManagement = New-Object System.Windows.Forms.CheckBox
$cbEnableSessionManagement.Name = "cbEnableSessionManagement"
$cbEnableSessionManagement.Text = $lang.ConfigForm_EnableSessionManagementCheckbox
$cbEnableSessionManagement.Location = New-Object System.Drawing.Point($xPadding, $yBasique)
$cbEnableSessionManagement.AutoSize = $true

# État initial
$currentSessionMode = Get-ConfigValue -Section "SystemConfig" -Key "SessionStartupMode" -DefaultValue "Standard"
$cbEnableSessionManagement.Checked = ($currentSessionMode -eq "Autologon")

$tabBasique.Controls.Add($cbEnableSessionManagement)
$yBasique += $cbEnableSessionManagement.Height + 5

# 2. Note sur la licence
$lblSessionNote = New-Object System.Windows.Forms.Label
$lblSessionNote.Text = $lang.ConfigForm_SessionEulaNote
# Sécurisation du calcul de position pour éviter l'erreur op_Addition
$noteX = [int]$xPadding + 20
$noteY = [int]$yBasique
$lblSessionNote.Location = New-Object System.Drawing.Point($noteX, $noteY)
$lblSessionNote.AutoSize = $true
$lblSessionNote.ForeColor = [System.Drawing.Color]::Gray
$tabBasique.Controls.Add($lblSessionNote)

$yBasique += $lblSessionNote.Height + $sectionSpacing



# --- Section des autres Checkboxes ---
Create-And-Add-Checkbox -FormInst $tabBasique -KeyName "DisableFastStartup" -LabelText $lang.ConfigForm_DisableFastStartupCheckbox -YPos_ref ([ref]$yBasique) -InitialValue $currentValues.DisableFastStartup -LocalXPadding $xPadding -LocalItemSpacing $itemSpacing
Create-And-Add-Checkbox -FormInst $tabBasique -KeyName "DisableSleep" -LabelText $lang.ConfigForm_DisableSleepCheckbox -YPos_ref ([ref]$yBasique) -InitialValue $currentValues.DisableSleep -LocalXPadding $xPadding -LocalItemSpacing $itemSpacing
Create-And-Add-Checkbox -FormInst $tabBasique -KeyName "DisableScreenSleep" -LabelText $lang.ConfigForm_DisableScreenSleepCheckbox -YPos_ref ([ref]$yBasique) -InitialValue $currentValues.DisableScreenSleep -LocalXPadding $xPadding -LocalItemSpacing $itemSpacing

# --- Section : Gestion de Windows Update ---
Create-And-Add-Checkbox -FormInst $tabBasique -KeyName "DisableWindowsUpdate" -LabelText $lang.ConfigForm_DisableWindowsUpdateCheckbox -YPos_ref ([ref]$yBasique) -InitialValue $currentValues.DisableWindowsUpdate -LocalXPadding $xPadding -LocalItemSpacing $itemSpacing

$gbUpdateOptions = New-Object System.Windows.Forms.GroupBox
$gbUpdateOptions.Location = New-Object System.Drawing.Point($xPadding, $yBasique)
$gbUpdateOptions.Size = New-Object System.Drawing.Size(530, 45)
$gbUpdateOptions.Text = ""
$tabBasique.Controls.Add($gbUpdateOptions)

$gbUpdateY = 10
Create-And-Add-Checkbox -FormInst $gbUpdateOptions -KeyName "DisableAutoReboot" -LabelText $lang.ConfigForm_DisableAutoRebootCheckbox -YPos_ref ([ref]$gbUpdateY) -InitialValue $currentValues.DisableAutoReboot -LocalXPadding 10 -LocalItemSpacing $itemSpacing

$yBasique += $gbUpdateOptions.Height

# Logique d'activation du groupe Windows Update
$cbDisableWU = $tabBasique.Controls["cbDisableWindowsUpdate"]
$gbUpdateOptions.Enabled = -not $cbDisableWU.Checked
$cbDisableWU.Add_CheckedChanged({
    $gbUpdateOptions.Enabled = -not $cbDisableWU.Checked
})

# --- Contrôle : Gestion de OneDrive (Label + ComboBox) ---
$lblOneDriveMode = New-Object System.Windows.Forms.Label
$lblOneDriveMode.Text = $lang.ConfigForm_OneDriveModeLabel
$lblOneDriveMode.Location = New-Object System.Drawing.Point($xPadding, $yBasique)
$lblOneDriveMode.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight)
$tabBasique.Controls.Add($lblOneDriveMode)

$cmbOneDriveMode = New-Object System.Windows.Forms.ComboBox
$cmbOneDriveMode.Name = "cmbOneDriveMode"
$cmbOneDriveMode.Location = New-Object System.Drawing.Point(($xPadding + $lblWidth + $itemSpacing), $yBasique)
$cmbOneDriveMode.Size = New-Object System.Drawing.Size($ctrlWidth, $ctrlHeight)
$cmbOneDriveMode.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList # Force le choix depuis la liste

# Ajoute les options traduites
$cmbOneDriveMode.Items.AddRange(@(
    $lang.ConfigForm_OneDriveMode_Block,
    $lang.ConfigForm_OneDriveMode_Close,
    $lang.ConfigForm_OneDriveMode_Ignore
))
$tabBasique.Controls.Add($cmbOneDriveMode)

# Sélectionne l'élément initial en fonction de la configuration chargée
$currentOneDriveMode = Get-ConfigValue -Section "SystemConfig" -Key "OneDriveManagementMode" -DefaultValue "Block"
switch ($currentOneDriveMode) {
    "Block" { $cmbOneDriveMode.SelectedItem = $lang.ConfigForm_OneDriveMode_Block }
    "Close" { $cmbOneDriveMode.SelectedItem = $lang.ConfigForm_OneDriveMode_Close }
    "Ignore" { $cmbOneDriveMode.SelectedItem = $lang.ConfigForm_OneDriveMode_Ignore }
    default { $cmbOneDriveMode.SelectedIndex = 0 }
}

$yCurrent += $itemTotalHeight

# --- GroupBox : Action Fermeture (dans Principal) ---
$yPrincipal = 20
$gbPreReboot = New-Object System.Windows.Forms.GroupBox
$gbPreReboot.Text = $lang.ConfigForm_CloseAppGroupTitle
$gbPreReboot.Location = New-Object System.Drawing.Point($xPadding, $yPrincipal)
$gbPreReboot.Size = New-Object System.Drawing.Size(530, 110)
$subTabPrincipal.Controls.Add($gbPreReboot)

$gb1Y = 25 # Y de départ à l'intérieur du premier GroupBox

# Contrôles pour l'action de fermeture (Heure de Fermeture - EXISTANT)
$lblScheduledCloseTime = New-Object System.Windows.Forms.Label; $lblScheduledCloseTime.Text = $lang.ConfigForm_CloseTimeLabel; $lblScheduledCloseTime.Location = New-Object System.Drawing.Point(10, $gb1Y); $lblScheduledCloseTime.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight); $gbPreReboot.Controls.Add($lblScheduledCloseTime)
$txtScheduledCloseTime = New-Object System.Windows.Forms.TextBox; $txtScheduledCloseTime.Text = $currentValues.ScheduledCloseTime; $txtScheduledCloseTime.Location = New-Object System.Drawing.Point((10 + $lblWidth + $itemSpacing), $gb1Y); $txtScheduledCloseTime.Size = New-Object System.Drawing.Size(100, $ctrlHeight); $gbPreReboot.Controls.Add($txtScheduledCloseTime)
$gb1Y += $itemTotalHeight

# Commande de fermeture (MANQUANT - RESTAURÉ)
$lblScheduledCloseCommand = New-Object System.Windows.Forms.Label; $lblScheduledCloseCommand.Text = $lang.ConfigForm_CloseCommandLabel; $lblScheduledCloseCommand.Location = New-Object System.Drawing.Point(10, $gb1Y); $lblScheduledCloseCommand.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight); $gbPreReboot.Controls.Add($lblScheduledCloseCommand)
$txtScheduledCloseCommand = New-Object System.Windows.Forms.TextBox; $txtScheduledCloseCommand.Text = $currentValues.ScheduledCloseCommand; $txtScheduledCloseCommand.Location = New-Object System.Drawing.Point((10 + $lblWidth + $itemSpacing), $gb1Y); $txtScheduledCloseCommand.Size = New-Object System.Drawing.Size($ctrlWidth, $ctrlHeight); $gbPreReboot.Controls.Add($txtScheduledCloseCommand)
$gb1Y += $itemTotalHeight

# Arguments pour la commande (MANQUANT - RESTAURÉ)
$lblScheduledCloseArguments = New-Object System.Windows.Forms.Label; $lblScheduledCloseArguments.Text = $lang.ConfigForm_CloseArgumentsLabel; $lblScheduledCloseArguments.Location = New-Object System.Drawing.Point(10, $gb1Y); $lblScheduledCloseArguments.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight); $gbPreReboot.Controls.Add($lblScheduledCloseArguments)
$txtScheduledCloseArguments = New-Object System.Windows.Forms.TextBox; $txtScheduledCloseArguments.Text = $currentValues.ScheduledCloseArguments; $txtScheduledCloseArguments.Location = New-Object System.Drawing.Point((10 + $lblWidth + $itemSpacing), $gb1Y); $txtScheduledCloseArguments.Size = New-Object System.Drawing.Size($ctrlWidth, $ctrlHeight); $gbPreReboot.Controls.Add($txtScheduledCloseArguments)

$yPrincipal += $gbPreReboot.Height + $itemSpacing

# --- GroupBox : Application Principale et Cycle Quotidien ---
$gbMainApp = New-Object System.Windows.Forms.GroupBox
$gbMainApp.Text = $lang.ConfigForm_MainAppGroupTitle
$gbMainApp.Location = New-Object System.Drawing.Point($xPadding, $yPrincipal)
$gbMainApp.Size = New-Object System.Drawing.Size(530, 165)
$subTabPrincipal.Controls.Add($gbMainApp)

$gb2Y = 25 # Y de départ à l'intérieur du second GroupBox

# Contrôles pour le cycle quotidien et l'application (Heure du Redémarrage - EXISTANT)
$lblScheduledRebootTime = New-Object System.Windows.Forms.Label; $lblScheduledRebootTime.Text = $lang.ConfigForm_RebootTimeLabel; $lblScheduledRebootTime.Location = New-Object System.Drawing.Point(10, $gb2Y); $lblScheduledRebootTime.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight); $gbMainApp.Controls.Add($lblScheduledRebootTime)
$txtScheduledRebootTime = New-Object System.Windows.Forms.TextBox; $txtScheduledRebootTime.Text = $currentValues.ScheduledRebootTime; $txtScheduledRebootTime.Location = New-Object System.Drawing.Point((10 + $lblWidth + $itemSpacing), $gb2Y); $txtScheduledRebootTime.Size = New-Object System.Drawing.Size(100, $ctrlHeight); $gbMainApp.Controls.Add($txtScheduledRebootTime)
$gb2Y += $itemTotalHeight

# Application à Lancer (MANQUANT - RESTAURÉ)
$lblProcessToLaunch = New-Object System.Windows.Forms.Label; $lblProcessToLaunch.Text = $lang.ConfigForm_ProcessToLaunchLabel; $lblProcessToLaunch.Location = New-Object System.Drawing.Point(10, $gb2Y); $lblProcessToLaunch.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight); $gbMainApp.Controls.Add($lblProcessToLaunch)
$txtProcessToLaunch = New-Object System.Windows.Forms.TextBox; $txtProcessToLaunch.Text = $currentValues.ProcessToLaunch; $txtProcessToLaunch.Location = New-Object System.Drawing.Point((10 + $lblWidth + $itemSpacing), $gb2Y); $txtProcessToLaunch.Size = New-Object System.Drawing.Size($ctrlWidth, $ctrlHeight); $gbMainApp.Controls.Add($txtProcessToLaunch)
$gb2Y += $itemTotalHeight

# Arguments pour l'application (MANQUANT - RESTAURÉ)
$lblProcessArguments = New-Object System.Windows.Forms.Label; $lblProcessArguments.Text = $lang.ConfigForm_ProcessArgumentsLabel; $lblProcessArguments.Location = New-Object System.Drawing.Point(10, $gb2Y); $lblProcessArguments.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight); $gbMainApp.Controls.Add($lblProcessArguments)
$txtProcessArguments = New-Object System.Windows.Forms.TextBox; $txtProcessArguments.Text = $currentValues.ProcessArguments; $txtProcessArguments.Location = New-Object System.Drawing.Point((10 + $lblWidth + $itemSpacing), $gb2Y); $txtProcessArguments.Size = New-Object System.Drawing.Size($ctrlWidth, $ctrlHeight); $gbMainApp.Controls.Add($txtProcessArguments)
$gb2Y += $itemTotalHeight

# Nom du Processus à Surveiller (MANQUANT - RESTAURÉ)
$lblProcessToMonitor = New-Object System.Windows.Forms.Label; $lblProcessToMonitor.Text = $lang.ConfigForm_ProcessToMonitorLabel; $lblProcessToMonitor.Location = New-Object System.Drawing.Point(10, $gb2Y); $lblProcessToMonitor.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight); $gbMainApp.Controls.Add($lblProcessToMonitor)
$txtProcessToMonitor = New-Object System.Windows.Forms.TextBox; $txtProcessToMonitor.Text = (Get-ConfigValue -Section "Process" -Key "ProcessToMonitor"); $txtProcessToMonitor.Location = New-Object System.Drawing.Point((10 + $lblWidth + $itemSpacing), $gb2Y); $txtProcessToMonitor.Size = New-Object System.Drawing.Size($ctrlWidth, $ctrlHeight); $gbMainApp.Controls.Add($txtProcessToMonitor)
$gb2Y += $itemTotalHeight

# Mode de Lancement Console (MANQUANT - RESTAURÉ)
$lblLaunchConsoleMode = New-Object System.Windows.Forms.Label; $lblLaunchConsoleMode.Text = $lang.ConfigForm_LaunchConsoleModeLabel; $lblLaunchConsoleMode.Location = New-Object System.Drawing.Point(10, $gb2Y); $lblLaunchConsoleMode.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight); $gbMainApp.Controls.Add($lblLaunchConsoleMode)
$cmbLaunchConsoleMode = New-Object System.Windows.Forms.ComboBox; $cmbLaunchConsoleMode.Name = "cmbLaunchConsoleMode"; $cmbLaunchConsoleMode.Location = New-Object System.Drawing.Point((10 + $lblWidth + $itemSpacing), $gb2Y); $cmbLaunchConsoleMode.Size = New-Object System.Drawing.Size($ctrlWidth, $ctrlHeight); $cmbLaunchConsoleMode.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$cmbLaunchConsoleMode.Items.AddRange(@($lang.ConfigForm_LaunchConsoleMode_Standard, $lang.ConfigForm_LaunchConsoleMode_Legacy))
$currentConsoleMode = Get-ConfigValue -Section "Process" -Key "LaunchConsoleMode" -DefaultValue "Standard"
$cmbLaunchConsoleMode.SelectedItem = if ($currentConsoleMode -eq 'Legacy') { $lang.ConfigForm_LaunchConsoleMode_Legacy } else { $lang.ConfigForm_LaunchConsoleMode_Standard }
$gbMainApp.Controls.Add($cmbLaunchConsoleMode)
$gb2Y += $itemTotalHeight

# Case à cocher Minimized (EXISTANT)
$cbStartMinimized = New-Object System.Windows.Forms.CheckBox; $cbStartMinimized.Name = "cbStartProcessMinimized"; $cbStartMinimized.Text = $lang.ConfigForm_StartProcessMinimizedCheckbox; $cbStartMinimized.Checked = [bool]$currentValues.StartProcessMinimized; $cbStartMinimized.Location = New-Object System.Drawing.Point(10, $gb2Y); $cbStartMinimized.AutoSize = $true; $gbMainApp.Controls.Add($cbStartMinimized)

$yPrincipal += $gbMainApp.Height + $itemSpacing

# --- Section : Options d'Installation (Mode Silencieux) ---
$gbInstallOptions = New-Object System.Windows.Forms.GroupBox
$gbInstallOptions.Text = $lang.ConfigForm_InstallOptionsGroup
# Correction de la taille : 530px au lieu de 740px pour tenir dans le formulaire de 600px
$gbInstallOptions.Size = New-Object System.Drawing.Size(530, 80)

# Repositionnement dans subTabAutreCompte
$gbInstallOptions.Parent = $subTabAutreCompte
$gbInstallOptions.Location = New-Object System.Drawing.Point($xPadding, 140)

$cbSilentMode = New-Object System.Windows.Forms.CheckBox
$cbSilentMode.Text = $lang.ConfigForm_SilentModeCheckbox
$cbSilentMode.Location = New-Object System.Drawing.Point(10, 20)
# Correction de la taille : 510px pour tenir dans le groupe de 530px
$cbSilentMode.Size = New-Object System.Drawing.Size(510, 50)
$cbSilentMode.AutoSize = $false # Permet le wrap du texte sur plusieurs lignes si nécessaire
$silentModeVal = Get-ConfigValue -Section "Installation" -Key "SilentMode" -DefaultValue $false -Type ([bool])
$cbSilentMode.Checked = $silentModeVal
$gbInstallOptions.Controls.Add($cbSilentMode)
#endregion Création des Contrôles



# --- GroupBox : Sauvegarde des Bases de Données (dans Sauvegarde) ---
$ySauvegarde = 20
$gbDatabaseBackup = New-Object System.Windows.Forms.GroupBox
$gbDatabaseBackup.Text = $lang.ConfigForm_DatabaseBackupGroupTitle
$gbDatabaseBackup.Location = New-Object System.Drawing.Point($xPadding, $ySauvegarde)
$gbDatabaseBackup.Size = New-Object System.Drawing.Size(530, 210)
$subTabSauvegarde.Controls.Add($gbDatabaseBackup)

$gbDbY = 25 # Y de départ à l'intérieur de ce GroupBox

# Case à cocher pour activer la sauvegarde
$cbEnableBackup = New-Object System.Windows.Forms.CheckBox
$cbEnableBackup.Name = "cbEnableBackup" # Nommage explicite
$cbEnableBackup.Text = $lang.ConfigForm_EnableBackupCheckbox
$cbEnableBackup.Checked = [bool]$currentValues.EnableBackup
$cbEnableBackup.Location = New-Object System.Drawing.Point(10, $gbDbY)
$cbEnableBackup.AutoSize = $true
$gbDatabaseBackup.Controls.Add($cbEnableBackup)
$gbDbY += $itemTotalHeight

# Add Backup Time field
$lblBackupTime = New-Object System.Windows.Forms.Label
$lblBackupTime.Text = $lang.ConfigForm_BackupTimeLabel
$lblBackupTime.Location = New-Object System.Drawing.Point(10, $gbDbY)
$lblBackupTime.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight)
$gbDatabaseBackup.Controls.Add($lblBackupTime)

$txtBackupTime = New-Object System.Windows.Forms.TextBox
$txtBackupTime.Name = "txtBackupTime"
$txtBackupTime.Text = $currentValues.ScheduledBackupTime
$txtBackupTime.Location = New-Object System.Drawing.Point((10 + $lblWidth + $itemSpacing), $gbDbY)
$txtBackupTime.Size = New-Object System.Drawing.Size(100, $ctrlHeight)
$gbDatabaseBackup.Controls.Add($txtBackupTime)

$gbDbY += $itemTotalHeight
# Label et TextBox pour le chemin Source
$lblBackupSource = New-Object System.Windows.Forms.Label; $lblBackupSource.Text = $lang.ConfigForm_BackupSourceLabel; $lblBackupSource.Location = New-Object System.Drawing.Point(10, $gbDbY); $lblBackupSource.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight); $gbDatabaseBackup.Controls.Add($lblBackupSource)
$txtBackupSource = New-Object System.Windows.Forms.TextBox; $txtBackupSource.Name = "txtBackupSource"; $txtBackupSource.Text = $currentValues.DatabaseSourcePath; $txtBackupSource.Location = New-Object System.Drawing.Point((10 + $lblWidth + $itemSpacing), $gbDbY); $txtBackupSource.Size = New-Object System.Drawing.Size($ctrlWidth, $ctrlHeight); $gbDatabaseBackup.Controls.Add($txtBackupSource)
$gbDbY += $itemTotalHeight

# Label et TextBox pour le chemin Destination
$lblBackupDest = New-Object System.Windows.Forms.Label; $lblBackupDest.Text = $lang.ConfigForm_BackupDestinationLabel; $lblBackupDest.Location = New-Object System.Drawing.Point(10, $gbDbY); $lblBackupDest.Size = New-Object System.Drawing.Size($lblWidth, $ctrlHeight); $gbDatabaseBackup.Controls.Add($lblBackupDest)
$txtBackupDest = New-Object System.Windows.Forms.TextBox; $txtBackupDest.Name = "txtBackupDest"; $txtBackupDest.Text = $currentValues.DatabaseDestinationPath; $txtBackupDest.Location = New-Object System.Drawing.Point((10 + $lblWidth + $itemSpacing), $gbDbY); $txtBackupDest.Size = New-Object System.Drawing.Size($ctrlWidth, $ctrlHeight); $gbDatabaseBackup.Controls.Add($txtBackupDest)
$gbDbY += $itemTotalHeight

# Label et TextBox pour la durée de conservation
$lblBackupKeepDays = New-Object System.Windows.Forms.Label; $lblBackupKeepDays.Text = $lang.ConfigForm_BackupKeepDaysLabel; $lblBackupKeepDays.Location = New-Object System.Drawing.Point(10, $gbDbY); $lblBackupKeepDays.Size = New-Object System.Drawing.Size(280, $ctrlHeight); $gbDatabaseBackup.Controls.Add($lblBackupKeepDays)
$txtBackupKeepDays = New-Object System.Windows.Forms.TextBox; $txtBackupKeepDays.Name = "txtBackupKeepDays"; $txtBackupKeepDays.Text = $currentValues.DatabaseKeepDays; $txtBackupKeepDays.Location = New-Object System.Drawing.Point(300, $gbDbY); $txtBackupKeepDays.Size = New-Object System.Drawing.Size(100, $ctrlHeight); $gbDatabaseBackup.Controls.Add($txtBackupKeepDays)

# Définition de l'état initial des TextBox (avant d'attacher l'événement)
$txtBackupSource.Enabled = $cbEnableBackup.Checked
$txtBackupDest.Enabled = $cbEnableBackup.Checked
$txtBackupTime.Enabled = $cbEnableBackup.Checked
$txtBackupKeepDays.Enabled = $cbEnableBackup.Checked

# Gestionnaire d'événement
$cbEnableBackup.Add_CheckedChanged({
    param($sender, $e) # Utilisation des paramètres d'événement standards

    # On récupère l'état de la case qui a déclenché l'événement
    $isChecked = $sender.Checked

    # On recherche les contrôles de manière récursive DANS LE FORMULAIRE ENTIER au moment du clic
    # C'est la méthode la plus robuste.
    $sourceTextBox = $form.Controls.Find("txtBackupSource", $true)[0]
    $destTextBox = $form.Controls.Find("txtBackupDest", $true)[0]
    $timeTextBox = $form.Controls.Find("txtBackupTime", $true)[0]
    $keepDaysTextBox = $form.Controls.Find("txtBackupKeepDays", $true)[0]

    # On applique le nouvel état
    $sourceTextBox.Enabled = $isChecked
    $destTextBox.Enabled = $isChecked
    $timeTextBox.Enabled = $isChecked
    $keepDaysTextBox.Enabled = $isChecked
})

$yCurrent += $gbDatabaseBackup.Height + $itemSpacing
#region Création des Boutons

# --- Bouton Enregistrer ---

# Calcul de la position du bouton "Enregistrer"
    $buttonY = 420 # Position en bas du TabControl
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
    if (($txtScheduledCloseTime.Text -ne "" -and $txtScheduledCloseTime.Text -notmatch "^\d{2}:\d{2}$") -or ($txtScheduledRebootTime.Text -ne "" -and $txtScheduledRebootTime.Text -notmatch "^\d{2}:\d{2}$") -or ($txtBackupTime.Text -ne "" -and $txtBackupTime.Text -notmatch "^\d{2}:\d{2}$")) {
        [System.Windows.Forms.MessageBox]::Show($lang.ConfigForm_InvalidTimeFormat, $lang.ConfigForm_InvalidTimeFormatCaption, "OK", "Warning")
        $form.DialogResult = [System.Windows.Forms.DialogResult]::None; return
    }

    # --- NOUVEAU BLOC DE VALIDATION LOGIQUE ---
    if (-not [string]::IsNullOrWhiteSpace($txtScheduledCloseTime.Text) -and -not [string]::IsNullOrWhiteSpace($txtScheduledRebootTime.Text)) {
        try {
            $preRebootTime = [datetime]::ParseExact($txtScheduledCloseTime.Text, "HH:mm", $null)
            $rebootTime = [datetime]::ParseExact($txtScheduledRebootTime.Text, "HH:mm", $null)

            if ($preRebootTime -ge $rebootTime) {
                [System.Windows.Forms.MessageBox]::Show($lang.ConfigForm_InvalidTimeLogic, $lang.ConfigForm_InvalidTimeLogicCaption, "OK", "Warning")
                $form.DialogResult = [System.Windows.Forms.DialogResult]::None; return
            }
        } catch {
            # Géré par la validation de format précédente, ce bloc est une sécurité
        }
    }
    # --- FIN DU NOUVEAU BLOC ---

    # Sauvegarde du nom d'utilisateur depuis le champ de texte
    Set-IniValue $ConfigFile "SystemConfig" "AutoLoginUsername" $form.Controls.Find('txtUsername', $true)[0].Text

    # Détermination et sauvegarde du mode de session
    $sessionModeToSave = "Standard"
    if ($form.Controls.Find('cbEnableSessionManagement', $true)[0].Checked) {
        $sessionModeToSave = "Autologon"
    }
    Set-IniValue $ConfigFile "SystemConfig" "SessionStartupMode" $sessionModeToSave

    Set-IniValue $ConfigFile "SystemConfig" "DisableFastStartup" $form.Controls.Find("cbDisableFastStartup", $true)[0].Checked.ToString().ToLower()
    Set-IniValue $ConfigFile "SystemConfig" "DisableSleep" $form.Controls.Find("cbDisableSleep", $true)[0].Checked.ToString().ToLower()
    Set-IniValue $ConfigFile "SystemConfig" "DisableScreenSleep" $form.Controls.Find("cbDisableScreenSleep", $true)[0].Checked.ToString().ToLower()
    Set-IniValue $ConfigFile "SystemConfig" "DisableWindowsUpdate" $form.Controls.Find("cbDisableWindowsUpdate", $true)[0].Checked.ToString().ToLower()
    Set-IniValue $ConfigFile "SystemConfig" "DisableAutoReboot" $form.Controls.Find('cbDisableAutoReboot', $true)[0].Checked.ToString().ToLower()
    Set-IniValue $ConfigFile "Process" "ScheduledRebootTime" $txtScheduledRebootTime.Text
    Set-IniValue $ConfigFile "Process" "ScheduledCloseTime" $txtScheduledCloseTime.Text
    Set-IniValue $ConfigFile "Process" "ScheduledCloseCommand" $txtScheduledCloseCommand.Text
    Set-IniValue $ConfigFile "Process" "ScheduledCloseArguments" $txtScheduledCloseArguments.Text
    # Détermine la valeur technique à sauvegarder pour OneDrive
    $oneDriveValueToSave = "Ignore" # Valeur par défaut sécurisée
    switch ($cmbOneDriveMode.SelectedItem.ToString()) {
        $lang.ConfigForm_OneDriveMode_Block { $oneDriveValueToSave = "Block" }
        $lang.ConfigForm_OneDriveMode_Close { $oneDriveValueToSave = "Close" }
        $lang.ConfigForm_OneDriveMode_Ignore { $oneDriveValueToSave = "Ignore" }
    }
    Set-IniValue $ConfigFile "SystemConfig" "OneDriveManagementMode" $oneDriveValueToSave
    Set-IniValue $ConfigFile "Process" "ProcessToLaunch" $txtProcessToLaunch.Text
    Set-IniValue $ConfigFile "Process" "ProcessArguments" $txtProcessArguments.Text
    Set-IniValue $ConfigFile "Process" "ProcessToMonitor" $txtProcessToMonitor.Text
    $consoleModeToSave = if ($cmbLaunchConsoleMode.SelectedItem -eq $lang.ConfigForm_LaunchConsoleMode_Legacy) { "Legacy" } else { "Standard" }
    Set-IniValue $ConfigFile "Process" "LaunchConsoleMode" $consoleModeToSave
    Set-IniValue $ConfigFile "Process" "StartProcessMinimized" $form.Controls.Find('cbStartProcessMinimized', $true)[0].Checked.ToString().ToLower()
    Set-IniValue $ConfigFile "DatabaseBackup" "EnableBackup" $form.Controls.Find('cbEnableBackup', $true)[0].Checked.ToString().ToLower()
    Set-IniValue $ConfigFile "DatabaseBackup" "ScheduledBackupTime" $form.Controls.Find('txtBackupTime', $true)[0].Text
    Set-IniValue $ConfigFile "DatabaseBackup" "DatabaseSourcePath" $form.Controls.Find('txtBackupSource', $true)[0].Text
    Set-IniValue $ConfigFile "DatabaseBackup" "DatabaseDestinationPath" $form.Controls.Find('txtBackupDest', $true)[0].Text
    Set-IniValue $ConfigFile "DatabaseBackup" "DatabaseKeepDays" $form.Controls.Find('txtBackupKeepDays', $true)[0].Text
    Set-IniValue $ConfigFile "Installation" "SilentMode" $cbSilentMode.Checked.ToString().ToLower()

    [System.Windows.Forms.MessageBox]::Show(($lang.ConfigForm_SaveSuccessMessage -f $ConfigFile), $lang.ConfigForm_SaveSuccessCaption, "OK", "Information")
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
