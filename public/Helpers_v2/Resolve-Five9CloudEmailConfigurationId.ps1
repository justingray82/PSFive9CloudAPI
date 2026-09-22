function Resolve-Five9CloudEmailConfigurationId ([string]$Email, [string]$Type) {
    if (-not $Email) { Write-Host "Specify -EmailConfigurationId or -Email." -ForegroundColor Red; return $null }
    $found = @(Get-Five9CloudEmailConfigurations | Where-Object { $_.email -eq $Email -and (-not $Type -or $_.type -eq $Type) })
    if ($found.Count -eq 1) { return $found[0].emailConfigurationId }
    if ($found.Count -gt 1) { Write-Host "Multiple configurations match '$Email' ($($found.type -join ', ')) - add -Type to pick one." -ForegroundColor Red; return $null }
    Write-Host "Email configuration '$Email' not found." -ForegroundColor Red; return $null
}