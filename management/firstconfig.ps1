param(
    # Accepte un argument de langue optionnel depuis la ligne de commande (ex: "en" ou "fr")
    [string]$LanguageOverride = ""
)

<#
.SYNOPSIS
    Assistant de configuration graphique pour WindowsAutoConfig.
.DESCRIPTION
    Gère la création du fichier config.ini à partir d'un modèle par défaut.
    Permet à l'utilisateur de configurer les options essentielles du fichier config.ini.
.NOTES
    Auteur: Ronan Davalan & Gemini
    Version: i18n - Logique de chargement modifiée
#>

#region Setup Form and Assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Bloc d'Internationalisation (i18n) - Méthode de chargement validée par le test ---
$lang = @{}
try {
    if ($MyInvocation.MyCommand.CommandType -eq 'ExternalScript') { $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition } 
    else { try { $PSScriptRoot = Split-Path -Parent $script:MyInvocation.MyCommand.Path -ErrorAction Stop } catch { $PSScriptRoot = Get-Location } }
    
    $projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\")).Path
    
    $cultureName = if (-not [string]::IsNullOrWhiteSpace($LanguageOverride)) {
        switch ($LanguageOverride.ToLower()) {
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

    # Recherche du fichier de langue le plus approprié (avec fallback vers l'anglais)
    $langFilePath = Join-Path $projectRoot "i18n\$cultureName\strings.psd1"
    if (-not (Test-Path $langFilePath)) {
        $langFilePath = Join-Path $projectRoot "i18n\en-US\strings.psd1"
    }

    # Utilisation de la méthode de chargement qui a été validée par le script de test
    if (Test-Path $langFilePath) {
        $langContent = Get-Content -Path $langFilePath -Raw
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
#endregion Setup Form and Assemblies


#region GESTION DU FICHIER DE CONFIGURATION PAR DÉFAUT
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
#endregion GESTION DU FICHIER DE CONFIGURATION PAR DÉFAUT


#region Helper Functions for INI
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
#endregion Helper Functions for INI


#region Form Creation
$form = New-Object System.Windows.Forms.Form
$form.Text = $lang.ConfigForm_Title
$form.Size = New-Object System.Drawing.Size(590, 530)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false
#endregion Form Creation


#region Load Initial Values from config.ini
$defaultValues = @{
    AutoLoginUsername = ""; DisableFastStartup = $true; DisableSleep = $true
    DisableScreenSleep = $false; EnableAutoLogin = $true; DisableWindowsUpdate = $true
    DisableAutoReboot = $true; PreRebootActionTime = "02:55"; PreRebootActionCommand = ""
    PreRebootActionArguments = ""; PreRebootActionLaunchMethod = "cmd"
    ScheduledRebootTime = "03:00"; DisableOneDrive = $true; ProcessName = ""
    ProcessArguments = ""; LaunchMethod = "cmd"
}
$currentValues = @{}
foreach ($key in $defaultValues.Keys) {
    $section = if ($key -in ("ProcessName", "ProcessArguments", "LaunchMethod")) { "Process" } else { "SystemConfig" }
    $rawValue = Get-IniValue -FilePath $ConfigIniPath -Section $section -Key $key -DefaultValue $defaultValues[$key]
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
#endregion Load Initial Values


#region Controls Creation
[int]$xPadding = 20;[int]$yCurrent = 20;[int]$lblWidth = 230;[int]$ctrlWidth = 270;[int]$ctrlHeight = 20;[int]$itemSpacing = 5;[int]$sectionSpacing = 10;[int]$itemTotalHeight = $ctrlHeight + $itemSpacing
$lblAutoLoginUsername = New-Object System.Windows.Forms.Label;$lblAutoLoginUsername.Text = $lang.ConfigForm_AutoLoginUsernameLabel;$lblAutoLoginUsername.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent);$lblAutoLoginUsername.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight);$form.Controls.Add($lblAutoLoginUsername)
$txtAutoLoginUsername = New-Object System.Windows.Forms.TextBox;$txtAutoLoginUsername.Text = $currentValues.AutoLoginUsername;$txtAutoLoginUsername.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent);$txtAutoLoginUsername.Size = New-Object System.Drawing.Size([int]$ctrlWidth, [int]$ctrlHeight);$form.Controls.Add($txtAutoLoginUsername);$yCurrent += $itemTotalHeight
function Create-And-Add-Checkbox {param($FormInst, $KeyName, $LabelText, [ref]$YPos_ref, $InitialValue, [int]$LocalXPadding, [int]$LocalItemSpacing)$cb = New-Object System.Windows.Forms.CheckBox;$cb.Name = "cb$KeyName"; $cb.Text = $LabelText; $cb.Checked = $InitialValue;$cb.Location = New-Object System.Drawing.Point([int]$LocalXPadding, [int]$YPos_ref.Value);$cb.AutoSize = $true;$FormInst.Controls.Add($cb);$YPos_ref.Value += [int]($cb.Height + $LocalItemSpacing)}
$checkboxes = @(
    @{Name="DisableFastStartup"; Label=$lang.ConfigForm_DisableFastStartupCheckbox; Initial=$currentValues.DisableFastStartup},
    @{Name="DisableSleep"; Label=$lang.ConfigForm_DisableSleepCheckbox; Initial=$currentValues.DisableSleep},
    @{Name="DisableScreenSleep"; Label=$lang.ConfigForm_DisableScreenSleepCheckbox; Initial=$currentValues.DisableScreenSleep},
    @{Name="EnableAutoLogin"; Label=$lang.ConfigForm_EnableAutoLoginCheckbox; Initial=$currentValues.EnableAutoLogin},
    @{Name="DisableWindowsUpdate"; Label=$lang.ConfigForm_DisableWindowsUpdateCheckbox; Initial=$currentValues.DisableWindowsUpdate},
    @{Name="DisableAutoReboot"; Label=$lang.ConfigForm_DisableAutoRebootCheckbox; Initial=$currentValues.DisableAutoReboot},
    @{Name="DisableOneDrive"; Label=$lang.ConfigForm_DisableOneDriveCheckbox; Initial=$currentValues.DisableOneDrive}
)
foreach ($cbInfo in $checkboxes) {Create-And-Add-Checkbox $form $cbInfo.Name $cbInfo.Label ([ref]$yCurrent) $cbInfo.Initial $xPadding $itemSpacing}
$yCurrent += $sectionSpacing
$lblPreRebootActionTime = New-Object System.Windows.Forms.Label; $lblPreRebootActionTime.Text = $lang.ConfigForm_PreRebootActionTimeLabel;$lblPreRebootActionTime.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent); $lblPreRebootActionTime.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight); $form.Controls.Add($lblPreRebootActionTime);$txtPreRebootActionTime = New-Object System.Windows.Forms.TextBox; $txtPreRebootActionTime.Text = $currentValues.PreRebootActionTime;$txtPreRebootActionTime.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent); $txtPreRebootActionTime.Size = New-Object System.Drawing.Size(100, [int]$ctrlHeight); $form.Controls.Add($txtPreRebootActionTime);$yCurrent += $itemTotalHeight
$lblPreRebootActionCommand = New-Object System.Windows.Forms.Label; $lblPreRebootActionCommand.Text = $lang.ConfigForm_PreRebootActionCommandLabel;$lblPreRebootActionCommand.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent); $lblPreRebootActionCommand.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight); $form.Controls.Add($lblPreRebootActionCommand);$txtPreRebootActionCommand = New-Object System.Windows.Forms.TextBox; $txtPreRebootActionCommand.Text = $currentValues.PreRebootActionCommand;$txtPreRebootActionCommand.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent); $txtPreRebootActionCommand.Size = New-Object System.Drawing.Size([int]$ctrlWidth, [int]$ctrlHeight); $form.Controls.Add($txtPreRebootActionCommand);$yCurrent += $itemTotalHeight
$lblPreRebootActionArguments = New-Object System.Windows.Forms.Label; $lblPreRebootActionArguments.Text = $lang.ConfigForm_PreRebootActionArgumentsLabel;$lblPreRebootActionArguments.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent); $lblPreRebootActionArguments.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight); $form.Controls.Add($lblPreRebootActionArguments);$txtPreRebootActionArguments = New-Object System.Windows.Forms.TextBox; $txtPreRebootActionArguments.Text = $currentValues.PreRebootActionArguments;$txtPreRebootActionArguments.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent); $txtPreRebootActionArguments.Size = New-Object System.Drawing.Size([int]$ctrlWidth, [int]$ctrlHeight); $form.Controls.Add($txtPreRebootActionArguments);$yCurrent += $itemTotalHeight
$lblPreRebootActionLaunchMethod = New-Object System.Windows.Forms.Label; $lblPreRebootActionLaunchMethod.Text = $lang.ConfigForm_PreRebootActionLaunchMethodLabel;$lblPreRebootActionLaunchMethod.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent); $lblPreRebootActionLaunchMethod.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight); $form.Controls.Add($lblPreRebootActionLaunchMethod);$cmbPreRebootActionLaunchMethod = New-Object System.Windows.Forms.ComboBox; $cmbPreRebootActionLaunchMethod.Items.AddRange(@("direct", "powershell", "cmd")); $cmbPreRebootActionLaunchMethod.Text = $currentValues.PreRebootActionLaunchMethod; $cmbPreRebootActionLaunchMethod.DropDownStyle = "DropDownList";$cmbPreRebootActionLaunchMethod.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent); $cmbPreRebootActionLaunchMethod.Size = New-Object System.Drawing.Size(100, [int]$ctrlHeight); $form.Controls.Add($cmbPreRebootActionLaunchMethod);$yCurrent += $itemTotalHeight + $sectionSpacing
$lblScheduledRebootTime = New-Object System.Windows.Forms.Label; $lblScheduledRebootTime.Text = $lang.ConfigForm_ScheduledRebootTimeLabel;$lblScheduledRebootTime.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent); $lblScheduledRebootTime.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight); $form.Controls.Add($lblScheduledRebootTime);$txtScheduledRebootTime = New-Object System.Windows.Forms.TextBox; $txtScheduledRebootTime.Text = $currentValues.ScheduledRebootTime;$txtScheduledRebootTime.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent); $txtScheduledRebootTime.Size = New-Object System.Drawing.Size(100, [int]$ctrlHeight); $form.Controls.Add($txtScheduledRebootTime);$yCurrent += $itemTotalHeight + $sectionSpacing
$lblProcessName = New-Object System.Windows.Forms.Label; $lblProcessName.Text = $lang.ConfigForm_ProcessNameLabel;$lblProcessName.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent); $lblProcessName.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight); $form.Controls.Add($lblProcessName);$txtProcessName = New-Object System.Windows.Forms.TextBox; $txtProcessName.Text = $currentValues.ProcessName;$txtProcessName.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent); $txtProcessName.Size = New-Object System.Drawing.Size([int]$ctrlWidth, [int]$ctrlHeight); $form.Controls.Add($txtProcessName);$yCurrent += $itemTotalHeight
$lblProcessArguments = New-Object System.Windows.Forms.Label; $lblProcessArguments.Text = $lang.ConfigForm_ProcessArgumentsLabel;$lblProcessArguments.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent); $lblProcessArguments.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight); $form.Controls.Add($lblProcessArguments);$txtProcessArguments = New-Object System.Windows.Forms.TextBox; $txtProcessArguments.Text = $currentValues.ProcessArguments;$txtProcessArguments.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent); $txtProcessArguments.Size = New-Object System.Drawing.Size([int]$ctrlWidth, [int]$ctrlHeight); $form.Controls.Add($txtProcessArguments);$yCurrent += $itemTotalHeight
$lblLaunchMethod = New-Object System.Windows.Forms.Label; $lblLaunchMethod.Text = $lang.ConfigForm_LaunchMethodLabel;$lblLaunchMethod.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent); $lblLaunchMethod.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight); $form.Controls.Add($lblLaunchMethod);$cmbLaunchMethod = New-Object System.Windows.Forms.ComboBox; $cmbLaunchMethod.Items.AddRange(@("direct", "powershell", "cmd")); $cmbLaunchMethod.Text = $currentValues.LaunchMethod; $cmbLaunchMethod.DropDownStyle = "DropDownList";$cmbLaunchMethod.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent); $cmbLaunchMethod.Size = New-Object System.Drawing.Size(100, [int]$ctrlHeight); $form.Controls.Add($cmbLaunchMethod);$yCurrent += $itemTotalHeight
#endregion Controls Creation


#region Buttons
$btnSave = New-Object System.Windows.Forms.Button; $btnSave.Text = $lang.ConfigForm_SaveButton;$calculatedX_ButtonSave = [int]($xPadding + ($lblWidth / 2));$calculatedY_Button = [int]$yCurrent;$btnSave.Location = New-Object System.Drawing.Point($calculatedX_ButtonSave, $calculatedY_Button); $btnSave.Size = New-Object System.Drawing.Size(150, 30);$btnSave.DialogResult = [System.Windows.Forms.DialogResult]::OK; $form.AcceptButton = $btnSave; $form.Controls.Add($btnSave)
$btnCancel = New-Object System.Windows.Forms.Button; $btnCancel.Text = $lang.ConfigForm_CancelButton;$calculatedX_ButtonCancel = [int]($calculatedX_ButtonSave + 150 + $itemSpacing);$btnCancel.Location = New-Object System.Drawing.Point($calculatedX_ButtonCancel, $calculatedY_Button); $btnCancel.Size = New-Object System.Drawing.Size(100, 30);$btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel; $form.CancelButton = $btnCancel; $form.Controls.Add($btnCancel)
$form.ClientSize = New-Object System.Drawing.Size($form.ClientSize.Width, [int]($yCurrent + 30 + $xPadding))
#endregion Buttons


#region Form Event Handlers
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
    [System.Windows.Forms.MessageBox]::Show(($lang.ConfigForm_SaveSuccessMessage -f $ConfigIniPath), $lang.ConfigForm_SaveSuccessCaption, "OK", "Information")
})
$form.Add_FormClosing({ param($sender, $e)
    if ($form.DialogResult -ne [System.Windows.Forms.DialogResult]::OK) {}
})
#endregion Form Event Handlers


#region Show Form
[System.Windows.Forms.Application]::EnableVisualStyles()
$DialogResult = $form.ShowDialog()

if ($DialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
    exit 0
} else {
    Write-Host $lang.ConfigForm_ConfigWizardCancelled -ForegroundColor Yellow
    exit 1
}
#endregion Show Form