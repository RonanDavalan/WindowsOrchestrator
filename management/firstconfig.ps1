$OutputEncoding = [System.Text.UTF8Encoding]::new($true)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($true)

<#
.SYNOPSIS
    Graphical configuration wizard for WindowsAutoConfig.
.DESCRIPTION
    Allows the user to configure essential options in the config.ini file.
.NOTES
    Author: Ronan Davalan & Gemini 2.5-pro
    Version: See the project's global configuration (config.ini or documentation)
    IMPORTANT: For special characters, if this script is saved as UTF-8, it must be WITH BOM.
               Alternatively, saving it as ANSI (Windows-1252 for French) may work with Windows PowerShell.
#>

#region Setup Form and Assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

try {
    $PSScriptRootCorrected = $PSScriptRoot
    if (-not $PSScriptRootCorrected) {
        $PSScriptRootCorrected = Split-Path -Parent $MyInvocation.MyCommand.Definition
    }
    $ProjectRootDir = Split-Path -Parent $PSScriptRootCorrected -ErrorAction Stop
    $ConfigIniPath = Join-Path $ProjectRootDir "config.ini"
    # Add a check here that $ConfigIniPath can be found, otherwise show an error MessageBox and exit.
    if (-not (Test-Path $ConfigIniPath -PathType Leaf -ErrorAction SilentlyContinue) -and -not (Test-Path (Join-Path $PSScriptRootCorrected "config.ini") -PathType Leaf)) {
         # Also try to find it next to the script just in case.
         $TestAlternativeConfigPath = Join-Path $PSScriptRootCorrected "config.ini"
         if(Test-Path $TestAlternativeConfigPath -PathType Leaf){
            $ConfigIniPath = $TestAlternativeConfigPath
            $ProjectRootDir = $PSScriptRootCorrected
         } else {
            throw "config.ini file not found at '$ConfigIniPath' or at '$TestAlternativeConfigPath'"
         }
    }

} catch {
    [System.Windows.Forms.MessageBox]::Show("Could not determine the path to the config.ini file. Error: $($_.Exception.Message). The script will now close.", "Critical Path Error", "OK", "Error")
    exit 1
}
#endregion Setup Form and Assemblies

#region Helper Functions for INI
function Get-IniValue {
    param($FilePath, $Section, $Key, $DefaultValue = "")
    if (-not (Test-Path $FilePath -PathType Leaf)) { return $DefaultValue }
    # For now, assume UTF8 or ANSI compatible.
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
    $fileExists = Test-Path $FilePath -PathType Leaf # Added -PathType Leaf
    $iniContent = if ($fileExists) { Get-Content $FilePath -Encoding UTF8 -ErrorAction SilentlyContinue } else { [string[]]@() } # Read as UTF8, write as UTF8
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
    # Ensure the parent directory exists before writing
    $ParentDir = Split-Path -Path $FilePath -Parent
    if (-not (Test-Path $ParentDir -PathType Container)) {
        New-Item -Path $ParentDir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    }
    Out-File -FilePath $FilePath -InputObject $newContent -Encoding utf8 -Force # Write as UTF8 (defaults to with BOM in PS5.1)
}
#endregion Helper Functions for INI

#region Form Creation
$form = New-Object System.Windows.Forms.Form
$form.Text = "Configuration Wizard - WindowsAutoConfig"
# SIZE
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
    DisableAutoReboot = $true; PreRebootActionTime = "03:55"; PreRebootActionCommand = ""
    PreRebootActionArguments = ""; PreRebootActionLaunchMethod = "powershell"
    ScheduledRebootTime = "04:00"; DisableOneDrive = $true; ProcessName = ""
    ProcessArguments = ""; LaunchMethod = "cmd"
}
$currentValues = @{}
if (-not (Test-Path $ConfigIniPath -PathType Leaf)) {
    [System.Windows.Forms.MessageBox]::Show("config.ini file not found. Default values will be used. Please save to create the file.", "Information", "OK", "Information")
    $currentValues = $defaultValues.Clone()
} else {
    foreach ($key in $defaultValues.Keys) {
        $section = if ($key -in ("ProcessName", "ProcessArguments", "LaunchMethod")) { "Process" } else { "SystemConfig" }
        # DefaultValue in Get-IniValue is used if the key is not found
        $rawValue = Get-IniValue -FilePath $ConfigIniPath -Section $section -Key $key -DefaultValue $defaultValues[$key]
        if ($defaultValues[$key] -is [boolean]) {
            if ($rawValue -is [boolean]) { $currentValues[$key] = $rawValue }
            elseif ([string]::IsNullOrWhiteSpace($rawValue.ToString())) { $currentValues[$key] = $defaultValues[$key] }
            else {
                # Try a more permissive conversion
                if ($rawValue.ToString().ToLower() -eq "true" -or $rawValue.ToString() -eq "1") { $currentValues[$key] = $true }
                elseif ($rawValue.ToString().ToLower() -eq "false" -or $rawValue.ToString() -eq "0") { $currentValues[$key] = $false }
                else { $currentValues[$key] = $defaultValues[$key] } # Fallback
            }
        } else { $currentValues[$key] = $rawValue }
    }
}
#endregion Load Initial Values

#region Controls Creation
# Using your original variable names ($yCurrent, $itemSpacing, etc.)
[int]$xPadding = 20
[int]$yCurrent = 20
[int]$lblWidth = 230
[int]$ctrlWidth = 270
[int]$ctrlHeight = 20
[int]$itemSpacing = 5
[int]$sectionSpacing = 10
[int]$itemTotalHeight = $ctrlHeight + $itemSpacing

# --- AutoLoginUsername ---
$lblAutoLoginUsername = New-Object System.Windows.Forms.Label
$lblAutoLoginUsername.Text = "Username for Auto-Login (optional):"
$lblAutoLoginUsername.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent)
$lblAutoLoginUsername.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight)
$form.Controls.Add($lblAutoLoginUsername)

$txtAutoLoginUsername = New-Object System.Windows.Forms.TextBox
$txtAutoLoginUsername.Text = $currentValues.AutoLoginUsername
$txtAutoLoginUsername.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent)
$txtAutoLoginUsername.Size = New-Object System.Drawing.Size([int]$ctrlWidth, [int]$ctrlHeight)
$form.Controls.Add($txtAutoLoginUsername)
$yCurrent += $itemTotalHeight

# --- Checkboxes for SystemConfig ---
function Create-And-Add-Checkbox {
    param($FormInst, $KeyName, $LabelText, [ref]$YPos_ref, $InitialValue, [int]$LocalXPadding, [int]$LocalItemSpacing)
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Name = "cb$KeyName"; $cb.Text = $LabelText; $cb.Checked = $InitialValue
    $cb.Location = New-Object System.Drawing.Point([int]$LocalXPadding, [int]$YPos_ref.Value)
    $cb.AutoSize = $true
    $FormInst.Controls.Add($cb)
    $YPos_ref.Value += [int]($cb.Height + $LocalItemSpacing)
}
$checkboxes = @(
    @{Name="DisableFastStartup"; Label="Disable Fast Startup (recommended)"; Initial=$currentValues.DisableFastStartup},
    @{Name="DisableSleep"; Label="Disable machine sleep"; Initial=$currentValues.DisableSleep},
    @{Name="DisableScreenSleep"; Label="Disable screen sleep"; Initial=$currentValues.DisableScreenSleep},
    @{Name="EnableAutoLogin"; Label="Enable Auto-Login management (via script)"; Initial=$currentValues.EnableAutoLogin},
    @{Name="DisableWindowsUpdate"; Label="Disable Windows Updates (via script)"; Initial=$currentValues.DisableWindowsUpdate},
    @{Name="DisableAutoReboot"; Label="Prevent WU from auto-rebooting (if session active)"; Initial=$currentValues.DisableAutoReboot},
    @{Name="DisableOneDrive"; Label="Disable OneDrive (system policy)"; Initial=$currentValues.DisableOneDrive}
)
foreach ($cbInfo in $checkboxes) {
    Create-And-Add-Checkbox $form $cbInfo.Name $cbInfo.Label ([ref]$yCurrent) $cbInfo.Initial $xPadding $itemSpacing
}
$yCurrent += $sectionSpacing

# --- Series of Label + Control ---
# Keeping your repetitive structure for now to minimize changes from the original.
# All Location/Size calculations are explicitly cast to [int] for safety.

# PreRebootActionTime
$lblPreRebootActionTime = New-Object System.Windows.Forms.Label; $lblPreRebootActionTime.Text = "Pre-Reboot Action Time (HH:MM):"
$lblPreRebootActionTime.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent); $lblPreRebootActionTime.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight); $form.Controls.Add($lblPreRebootActionTime)
$txtPreRebootActionTime = New-Object System.Windows.Forms.TextBox; $txtPreRebootActionTime.Text = $currentValues.PreRebootActionTime
$txtPreRebootActionTime.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent); $txtPreRebootActionTime.Size = New-Object System.Drawing.Size(100, [int]$ctrlHeight); $form.Controls.Add($txtPreRebootActionTime)
$yCurrent += $itemTotalHeight

# PreRebootActionCommand
$lblPreRebootActionCommand = New-Object System.Windows.Forms.Label; $lblPreRebootActionCommand.Text = "Pre-Reboot Command (path):"
$lblPreRebootActionCommand.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent); $lblPreRebootActionCommand.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight); $form.Controls.Add($lblPreRebootActionCommand)
$txtPreRebootActionCommand = New-Object System.Windows.Forms.TextBox; $txtPreRebootActionCommand.Text = $currentValues.PreRebootActionCommand
$txtPreRebootActionCommand.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent); $txtPreRebootActionCommand.Size = New-Object System.Drawing.Size([int]$ctrlWidth, [int]$ctrlHeight); $form.Controls.Add($txtPreRebootActionCommand)
$yCurrent += $itemTotalHeight

# PreRebootActionArguments
$lblPreRebootActionArguments = New-Object System.Windows.Forms.Label; $lblPreRebootActionArguments.Text = "Pre-Reboot Command Arguments:"
$lblPreRebootActionArguments.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent); $lblPreRebootActionArguments.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight); $form.Controls.Add($lblPreRebootActionArguments)
$txtPreRebootActionArguments = New-Object System.Windows.Forms.TextBox; $txtPreRebootActionArguments.Text = $currentValues.PreRebootActionArguments
$txtPreRebootActionArguments.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent); $txtPreRebootActionArguments.Size = New-Object System.Drawing.Size([int]$ctrlWidth, [int]$ctrlHeight); $form.Controls.Add($txtPreRebootActionArguments)
$yCurrent += $itemTotalHeight

# PreRebootActionLaunchMethod
$lblPreRebootActionLaunchMethod = New-Object System.Windows.Forms.Label; $lblPreRebootActionLaunchMethod.Text = "Pre-Reboot Launch Method:"
$lblPreRebootActionLaunchMethod.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent); $lblPreRebootActionLaunchMethod.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight); $form.Controls.Add($lblPreRebootActionLaunchMethod)
$cmbPreRebootActionLaunchMethod = New-Object System.Windows.Forms.ComboBox; $cmbPreRebootActionLaunchMethod.Items.AddRange(@("direct", "powershell", "cmd")); $cmbPreRebootActionLaunchMethod.SelectedItem = $currentValues.PreRebootActionLaunchMethod; $cmbPreRebootActionLaunchMethod.DropDownStyle = "DropDownList"
$cmbPreRebootActionLaunchMethod.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent); $cmbPreRebootActionLaunchMethod.Size = New-Object System.Drawing.Size(100, [int]$ctrlHeight); $form.Controls.Add($cmbPreRebootActionLaunchMethod)
$yCurrent += $itemTotalHeight + $sectionSpacing

# ScheduledRebootTime
$lblScheduledRebootTime = New-Object System.Windows.Forms.Label; $lblScheduledRebootTime.Text = "Daily Reboot Time (HH:MM):"
$lblScheduledRebootTime.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent); $lblScheduledRebootTime.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight); $form.Controls.Add($lblScheduledRebootTime)
$txtScheduledRebootTime = New-Object System.Windows.Forms.TextBox; $txtScheduledRebootTime.Text = $currentValues.ScheduledRebootTime
$txtScheduledRebootTime.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent); $txtScheduledRebootTime.Size = New-Object System.Drawing.Size(100, [int]$ctrlHeight); $form.Controls.Add($txtScheduledRebootTime)
$yCurrent += $itemTotalHeight + $sectionSpacing

# ProcessName
$lblProcessName = New-Object System.Windows.Forms.Label; $lblProcessName.Text = "Application to Launch (ProcessName):" # Accent
$lblProcessName.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent); $lblProcessName.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight); $form.Controls.Add($lblProcessName)
$txtProcessName = New-Object System.Windows.Forms.TextBox; $txtProcessName.Text = $currentValues.ProcessName
$txtProcessName.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent); $txtProcessName.Size = New-Object System.Drawing.Size([int]$ctrlWidth, [int]$ctrlHeight); $form.Controls.Add($txtProcessName)
$yCurrent += $itemTotalHeight

# ProcessArguments
$lblProcessArguments = New-Object System.Windows.Forms.Label; $lblProcessArguments.Text = "Main Application Arguments:"
$lblProcessArguments.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent); $lblProcessArguments.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight); $form.Controls.Add($lblProcessArguments)
$txtProcessArguments = New-Object System.Windows.Forms.TextBox; $txtProcessArguments.Text = $currentValues.ProcessArguments
$txtProcessArguments.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent); $txtProcessArguments.Size = New-Object System.Drawing.Size([int]$ctrlWidth, [int]$ctrlHeight); $form.Controls.Add($txtProcessArguments)
$yCurrent += $itemTotalHeight

# LaunchMethod
$lblLaunchMethod = New-Object System.Windows.Forms.Label; $lblLaunchMethod.Text = "Main Application Launch Method:"
$lblLaunchMethod.Location = New-Object System.Drawing.Point([int]$xPadding, [int]$yCurrent); $lblLaunchMethod.Size = New-Object System.Drawing.Size([int]$lblWidth, [int]$ctrlHeight); $form.Controls.Add($lblLaunchMethod)
$cmbLaunchMethod = New-Object System.Windows.Forms.ComboBox; $cmbLaunchMethod.Items.AddRange(@("direct", "powershell", "cmd")); $cmbLaunchMethod.SelectedItem = $currentValues.LaunchMethod; $cmbLaunchMethod.DropDownStyle = "DropDownList"
$cmbLaunchMethod.Location = New-Object System.Drawing.Point([int]($xPadding + $lblWidth + $itemSpacing), [int]$yCurrent); $cmbLaunchMethod.Size = New-Object System.Drawing.Size(100, [int]$ctrlHeight); $form.Controls.Add($cmbLaunchMethod)
$yCurrent += $itemTotalHeight

#endregion Controls Creation

#region Buttons
$btnSave = New-Object System.Windows.Forms.Button; $btnSave.Text = "Save and Close"
$calculatedX_ButtonSave = [int]($xPadding + ($lblWidth / 2))
$calculatedY_Button = [int]$yCurrent
$btnSave.Location = New-Object System.Drawing.Point($calculatedX_ButtonSave, $calculatedY_Button); $btnSave.Size = New-Object System.Drawing.Size(150, 30)
$btnSave.DialogResult = [System.Windows.Forms.DialogResult]::OK; $form.AcceptButton = $btnSave; $form.Controls.Add($btnSave)

$btnCancel = New-Object System.Windows.Forms.Button; $btnCancel.Text = "Cancel"
$calculatedX_ButtonCancel = [int]($calculatedX_ButtonSave + 150 + $itemSpacing)
$btnCancel.Location = New-Object System.Drawing.Point($calculatedX_ButtonCancel, $calculatedY_Button); $btnCancel.Size = New-Object System.Drawing.Size(100, 30)
$btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel; $form.CancelButton = $btnCancel; $form.Controls.Add($btnCancel)

# Adjust the form size to make sure everything is visible
# $yCurrent is now the Y position of the buttons. We add their height and a bit of margin.
$form.ClientSize = New-Object System.Drawing.Size($form.ClientSize.Width, [int]($yCurrent + 30 + $xPadding))
#endregion Buttons

#region Form Event Handlers
$btnSave.Add_Click({
    if (($txtPreRebootActionTime.Text -ne "" -and $txtPreRebootActionTime.Text -notmatch "^\d{2}:\d{2}$") -or `
        ($txtScheduledRebootTime.Text -ne "" -and $txtScheduledRebootTime.Text -notmatch "^\d{2}:\d{2}$")) {
        [System.Windows.Forms.MessageBox]::Show("The time format must be HH:MM (e.g., 03:55).", "Invalid Format", "OK", "Warning")
        $form.DialogResult = [System.Windows.Forms.DialogResult]::None; return # Prevents closing
    }
    Set-IniValue $ConfigIniPath "SystemConfig" "AutoLoginUsername" $txtAutoLoginUsername.Text
    Set-IniValue $ConfigIniPath "SystemConfig" "DisableFastStartup" $form.Controls["cbDisableFastStartup"].Checked.ToString().ToLower()
    Set-IniValue $ConfigIniPath "SystemConfig" "DisableSleep" $form.Controls["cbDisableSleep"].Checked.ToString().ToLower()
    Set-IniValue $ConfigIniPath "SystemConfig" "DisableScreenSleep" $form.Controls["cbDisableScreenSleep"].Checked.ToString().ToLower()
    Set-IniValue $ConfigIniPath "SystemConfig" "EnableAutoLogin" $form.Controls["cbEnableAutoLogin"].Checked.ToString().ToLower()
    Set-IniValue $ConfigIniPath "SystemConfig" "DisableWindowsUpdate" $form.Controls["cbDisableWindowsUpdate"].Checked.ToString().ToLower()
    Set-IniValue $ConfigIniPath "SystemConfig" "DisableAutoReboot" $form.Controls["cbDisableAutoReboot"].Checked.ToString().ToLower()
    Set-IniValue $ConfigIniPath "SystemConfig" "DisableOneDrive" $form.Controls["cbDisableOneDrive"].Checked.ToString().ToLower()
    Set-IniValue $ConfigIniPath "SystemConfig" "PreRebootActionTime" $txtPreRebootActionTime.Text
    Set-IniValue $ConfigIniPath "SystemConfig" "PreRebootActionCommand" $txtPreRebootActionCommand.Text
    Set-IniValue $ConfigIniPath "SystemConfig" "PreRebootActionArguments" $txtPreRebootActionArguments.Text
    Set-IniValue $ConfigIniPath "SystemConfig" "PreRebootActionLaunchMethod" $cmbPreRebootActionLaunchMethod.SelectedItem.ToString()
    Set-IniValue $ConfigIniPath "SystemConfig" "ScheduledRebootTime" $txtScheduledRebootTime.Text
    Set-IniValue $ConfigIniPath "Process" "ProcessName" $txtProcessName.Text
    Set-IniValue $ConfigIniPath "Process" "ProcessArguments" $txtProcessArguments.Text
    Set-IniValue $ConfigIniPath "Process" "LaunchMethod" $cmbLaunchMethod.SelectedItem.ToString()
    [System.Windows.Forms.MessageBox]::Show("Configuration saved to $ConfigIniPath", "Success", "OK", "Information")
    # The DialogResult is already OK, so the form will close.
})
# Adding event parameters
$form.Add_FormClosing({ param($sender, $e)
    if ($form.DialogResult -ne [System.Windows.Forms.DialogResult]::OK) {
        # Cancellation or closing via the 'X' button
    }
})
#endregion Form Event Handlers

#region Show Form
[System.Windows.Forms.Application]::EnableVisualStyles()
# Out-Null is implicit when assigning to a variable
$DialogResult = $form.ShowDialog()

# Handle script exit for 1_install.bat
if ($DialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
    exit 0 # Success
} else {
    Write-Host "Configuration wizard cancelled." -ForegroundColor Yellow # Message for the console if visible
    exit 1 # Cancelled or closed
}
#endregion Show Form