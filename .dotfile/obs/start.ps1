$obsPath   = (Join-Path $HOME, "scoop/apps/obs-studio/current/bin/64bit/obs64.exe")
$logPath   = (Join-Path $HOME, "cagelab_logs/obs-monitor.log")
$svcName   = "mediamtx"

# Ensure log directory exists
if (!(Test-Path (Split-Path $logPath))) {
    New-Item -Path (Split-Path $logPath) -ItemType Directory -Force | Out-Null
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp [$Level] $Message" | Tee-Object -FilePath $logPath -Append
}

function Wait-ForService {
    param([string]$Name)
    Write-Log "Waiting for service $Name to start..."
    while ((Get-Service -Name $Name).Status -ne "Running") {
        Start-Sleep -Seconds 5
    }
    Write-Log "Service $Name is running."
}

function Start-OBS {
    while ($true) {
        Write-Log "Starting OBS..."
        $proc = Start-Process -FilePath $obsPath -PassThru
        Wait-Process -Id $proc.Id
        Write-Log "OBS exited unexpectedly. Restarting in 5 seconds..." "WARN"
        Start-Sleep -Seconds 5
    }
}

# Main flow
Write-Log "========== Script started =========="
Wait-ForService -Name $svcName
Start-OBS
