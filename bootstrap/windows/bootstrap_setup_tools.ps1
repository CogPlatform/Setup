#region setup mediamtx
nssm install mediamtx (Join-Path $HOME "scoop/shims/mediamtx.exe")
nssm set mediamtx AppDirectory (Join-Path $HOME "scoop/persist/mediamtx")
#endregion

#region setup obs-studio
$obsScript = Join-Path $HOME "cagelab\scripts\obs\start.ps1"
$obsSource = Join-Path $HOME "Code\Setup\.dotfile\obs\start.ps1"

New-Item -ItemType SymbolicLink -Path $obsScript -Target $obsSource -Force

# scheduled task
$action   = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument "-WindowStyle Hidden -File `"$obsScript`""
$trigger  = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName "OBS-StartupMonitor" -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest
#endregion

#region setup netbird
netbird service install
netbird service start
netbird up --setup-key $KEY
#endregion

#region setup cogmoteGO
cogmoteGO service
#endregion