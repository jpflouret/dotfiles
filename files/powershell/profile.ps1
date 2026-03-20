# Install: Install-Module Terminal-Icons -Scope CurrentUser
if (Get-Module -ListAvailable Terminal-Icons) {
    Import-Module Terminal-Icons
}

# exit with Ctrl+D
Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit

# Install: winget install JanDeDobbeleer.OhMyPosh
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    function Set-MyPoshContext {
        if ($Global:WhatIfPreference) {
            $env:POSH_WHATIF = "What If"
        }
        else {
            $env:POSH_WHATIF = ""
        }
        if ($null -ne (Get-Module powerushell)) {
            Update-UShellEnvVars | Out-Null
        }
    }
    New-Alias -Name 'Set-PoshContext' -Value 'Set-MyPoshContext' -Scope Global -Force
    oh-my-posh init pwsh --config ~/.config.omp.json | Invoke-Expression
}

$EpicWorkspace = Join-Path $HOME "source" "repos" "EpicWorkspace"
if (Test-Path $EpicWorkspace) {
    Import-Module $EpicWorkspace
}
