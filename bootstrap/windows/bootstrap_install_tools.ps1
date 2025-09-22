#region by package manager
winget install Microsoft.PowerShell --accept-source-agreements --accept-package-agreements
winget install NoMachine.NoMachine --accept-source-agreements --accept-package-agreements

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

scoop install git
scoop bucket add extras
scoop bucket add nerd-fonts

scoop install netbird
scoop install starship
scoop install Maple-Mono-NF-CN

scoop install nssm
scoop install mediamtx
scoop install obs-studio
scoop install sunshine

Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/Ccccraz/cogmoteGO/main/install.ps1' | Invoke-Expression
#endregion

#region by git clone
# Set the parent directory for code repositories
$parentDir = Join-Path $HOME "Code"

# Check and create parent directory if it doesn't exist
if (!(Test-Path $parentDir)) {
    Write-Host "Creating code directory: $parentDir" -ForegroundColor Green
    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
}

# Define the list of repositories to clone
Write-Host "`nPreparing to clone the following repositories:" -ForegroundColor Cyan
$repos = @(
    "https://gitee.com/CogPlatform/Setup.git",
    "https://gitee.com/CogPlatform/Psychtoolbox.git",
    "https://gitee.com/CogPlatform/opticka.git",
    "https://gitee.com/CogPlatform/CageLab.git",
    "https://gitee.com/CogPlatform/matlab-jzmq.git",
    "https://gitee.com/CogPlatform/matmoteGO.git",
    "https://gitee.com/CogPlatform/PTBSimia.git"
)

# Display all repository names
foreach ($repo in $repos) {
    $repoName = [System.IO.Path]::GetFileNameWithoutExtension($repo)
    Write-Host "  - $repoName" -ForegroundColor White
}

Write-Host "`nStarting clone process..." -ForegroundColor Cyan

# Clone each repository
foreach ($repo in $repos) {
    $repoName = [System.IO.Path]::GetFileNameWithoutExtension($repo)
    $targetPath = Join-Path $parentDir $repoName

    if (Test-Path $targetPath) {
        Write-Host "`nSkipping $repoName (directory already exists)" -ForegroundColor Yellow
    }
    else {
        Write-Host "`nCloning $repoName..." -ForegroundColor Green
        git clone --recurse-submodules --depth 1 $repo $targetPath
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Successfully cloned $repoName" -ForegroundColor Green
        } else {
            Write-Host "Failed to clone $repoName" -ForegroundColor Red
        }
    }
}

Write-Host "`nClone process completed!" -ForegroundColor Cyan
#endregion
