<#
    Bulk create Five9 users by copying a template user
    Generated for PSFive9CloudAPI. Unsupported sample code; test in a
    non-production domain first when you can.

    INPUT CSV (input\new-users.csv), one row per new user:
      Username,FirstName,LastName,Email,TemplateUsername
    TemplateUsername is optional; blank rows use $DefaultTemplate.
    The new user gets the template's applications, permissions, roles, agent
    groups, media types, skills, circles, and reason codes.

    HOW TO RUN
      1. Leave $DryRun = $true and run. Review the plan.
      2. Copy the domain ID it prints into $ExpectedDomainId.
      3. Set $DryRun = $false and run again.
#>

$BaseDir = if ($PSScriptRoot) { Split-Path $PSScriptRoot -Parent } else { (Get-Location).Path }

# ============================== CONFIG ==============================
$Region           = 'us'     # us | uk | eu | ca
$Environment      = 'prod'
$ExpectedDomainId = ''       # required for a live run
$DefaultTemplate  = ''       # template username used when a row leaves it blank
$Status           = 'ACTIVE' # ACTIVE | INACTIVE for the new users
$InputCsv         = Join-Path $BaseDir 'input\new-users.csv'
$LogDir           = Join-Path $BaseDir 'logs'
$DryRun           = $true
# ====================================================================

Import-Module PSFive9CloudAPI -ErrorAction Stop

function Get-UserUidOrNull ([string]$Name) {
    # Direct query instead of Resolve-Five9CloudUserUID, which prints "not found" in red.
    $r = Get-Five9CloudUserDetails -Filter "username=='$Name'" -Fields 'useruid,name'
    $hit = @($r.items) | Select-Object -First 1
    if ($hit) { return $hit.userUID } else { return $null }
}

# ---- Connect -------------------------------------------------------
$cred = Get-Credential -Message 'Five9 admin login (stays on this computer)'
if (-not $cred) { Write-Host 'Cancelled.'; return }
Connect-Five9Cloud -Region $Region -Environment $Environment -SkipUpdateCheck `
    -Username $cred.UserName -Password $cred.GetNetworkCredential().Password
$cred = $null
if (-not $global:Five9 -or -not $global:Five9.AccessToken) { Write-Host 'Login failed. Check region and credentials.' -ForegroundColor Red; return }
$domainId = $global:Five9.DomainId
Write-Host "Connected to domain ID: $domainId" -ForegroundColor Cyan
if (-not $DryRun) {
    if (-not $ExpectedDomainId) { Write-Host 'Set $ExpectedDomainId before a live run.' -ForegroundColor Yellow; return }
    if ($domainId -ne $ExpectedDomainId) { Write-Host "Domain mismatch ($domainId vs $ExpectedDomainId). Nothing changed." -ForegroundColor Red; return }
}

# ---- 1. Validate ---------------------------------------------------
if (-not (Test-Path $InputCsv)) { Write-Host "Input file not found: $InputCsv" -ForegroundColor Red; return }
$rows = @(Import-Csv -Path $InputCsv)
if ($rows.Count -eq 0) { Write-Host 'The CSV has no rows.'; return }
$cols = $rows[0].PSObject.Properties.Name
$missing = @('Username','FirstName','LastName','Email' | Where-Object { $cols -notcontains $_ })
if ($missing) { Write-Host "Missing column(s): $($missing -join ', ')" -ForegroundColor Red; return }

$problems = @()
$line = 1
foreach ($r in $rows) {
    $line++
    foreach ($c in 'Username','FirstName','LastName','Email') {
        if ([string]::IsNullOrWhiteSpace($r.$c)) { $problems += "Line ${line}: $c is blank." }
    }
    if ($r.Email -and $r.Email -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$') { $problems += "Line ${line}: email '$($r.Email)' looks invalid." }
    $tpl = if ($cols -contains 'TemplateUsername' -and $r.TemplateUsername) { $r.TemplateUsername } else { $DefaultTemplate }
    if (-not $tpl) { $problems += "Line ${line}: no TemplateUsername and `$DefaultTemplate is empty." }
}
$dupes = $rows | Group-Object { $_.Username.Trim().ToLower() } | Where-Object Count -gt 1
foreach ($d in $dupes) { $problems += "Username '$($d.Name)' appears $($d.Count) times." }
if ($problems) { $problems | ForEach-Object { Write-Host $_ -ForegroundColor Red }; Write-Host 'Fix the CSV and run again. Nothing changed.'; return }

# ---- 2. Plan (reads only) -----------------------------------------
$templateCache = @{}
$plan = foreach ($r in $rows) {
    $tpl = if ($cols -contains 'TemplateUsername' -and $r.TemplateUsername) { $r.TemplateUsername.Trim() } else { $DefaultTemplate }
    if (-not $templateCache.ContainsKey($tpl)) { $templateCache[$tpl] = Get-UserUidOrNull $tpl }
    $action = 'Create'; $reason = ''
    if (-not $templateCache[$tpl])                 { $action = 'Skip'; $reason = "template '$tpl' not found" }
    elseif (Get-UserUidOrNull $r.Username.Trim()) { $action = 'Skip'; $reason = 'username already exists' }
    [pscustomobject]@{
        Username = $r.Username.Trim(); FirstName = $r.FirstName.Trim(); LastName = $r.LastName.Trim()
        Email = $r.Email.Trim(); Template = $tpl; TemplateUID = $templateCache[$tpl]; Action = $action; Reason = $reason
    }
}

Write-Host ''
Write-Host "PLAN for domain $domainId" -ForegroundColor Cyan
$plan | Group-Object Action | ForEach-Object { Write-Host ("  {0,-8} {1}" -f $_.Name, $_.Count) }
$plan | Select-Object Username, Template, Action, Reason -First 15 | Format-Table -AutoSize | Out-String -Width 200 | Write-Host
if ($DryRun) { Write-Host 'DRY RUN: nothing changed.' -ForegroundColor Yellow; return }

# ---- 3. Execute ---------------------------------------------------
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }
$logPath = Join-Path $LogDir ("bulk-copy-users-{0}.csv" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
$results = @()
foreach ($p in $plan | Where-Object Action -eq 'Create') {
    $null = Copy-Five9CloudUser -UserUID $p.TemplateUID -NewUsername $p.Username `
        -FirstName $p.FirstName -LastName $p.LastName -Email $p.Email -Status $Status
    $newUid = Get-UserUidOrNull $p.Username          # verify: Copy returns nothing on success
    $results += [pscustomobject]@{ Username = $p.Username; Template = $p.Template; NewUID = $newUid; Result = $(if ($newUid) { 'OK' } else { 'FAILED' }) }
}
$plan | Where-Object Action -eq 'Skip' | ForEach-Object {
    $results += [pscustomobject]@{ Username = $_.Username; Template = $_.Template; NewUID = ''; Result = "SKIPPED: $($_.Reason)" }
}
$results | Export-Csv -Path $logPath -NoTypeInformation

# ---- 4. Verify ----------------------------------------------------
$failed = @($results | Where-Object Result -eq 'FAILED')
Write-Host ''
Write-Host ("Created: {0}  Failed: {1}  Skipped: {2}  Log: {3}" -f @($results | Where-Object Result -eq 'OK').Count, $failed.Count, @($results | Where-Object { $_.Result -like 'SKIPPED*' }).Count, $logPath) -ForegroundColor Cyan
Write-Host 'Lines above that start with "  Failed to copy" mean the user exists but that part of the template was not copied.'
if ($failed) { $failed | Format-Table -AutoSize | Out-String -Width 200 | Write-Host }

Remove-Variable Five9 -Scope Global -ErrorAction SilentlyContinue
