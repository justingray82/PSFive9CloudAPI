<#
    <TASK TITLE>
    Generated for PSFive9CloudAPI. Unsupported sample code; test in a
    non-production domain first when you can.

    HOW TO RUN
      1. Leave $DryRun = $true and run the script (F5 in ISE, or .\<name>.ps1).
      2. Review the plan it prints. Copy the domain ID it shows into
         $ExpectedDomainId.
      3. Set $DryRun = $false and run again to apply the changes.
    A log of every row's result is written to the logs folder.
#>

$BaseDir = if ($PSScriptRoot) { Split-Path $PSScriptRoot -Parent } else { (Get-Location).Path }   # Five9-Admin folder (script lives in scripts\)

# ============================== CONFIG ==============================
$Region           = 'us'     # us | uk | eu | ca
$Environment      = 'prod'   # prod | alpha
$ExpectedDomainId = ''       # required for a live run; copy from the dry run
$InputCsv         = Join-Path $BaseDir 'input\<input>.csv'
$LogDir           = Join-Path $BaseDir 'logs'
$DryRun           = $true    # $false applies changes
# ====================================================================

Import-Module PSFive9CloudAPI -ErrorAction Stop

# ---- Connect (password is masked and never written to disk) --------
$cred = Get-Credential -Message 'Five9 admin login (stays on this computer)'
if (-not $cred) { Write-Host 'Cancelled.'; return }
Connect-Five9Cloud -Region $Region -Environment $Environment -SkipUpdateCheck `
    -Username $cred.UserName -Password $cred.GetNetworkCredential().Password
$cred = $null
if (-not $global:Five9 -or -not $global:Five9.AccessToken) { Write-Host 'Login failed. Check region and credentials.' -ForegroundColor Red; return }

$domainId = $global:Five9.DomainId
Write-Host "Connected to domain ID: $domainId" -ForegroundColor Cyan

if (-not $DryRun) {
    if (-not $ExpectedDomainId) { Write-Host 'Set $ExpectedDomainId (from the dry run) before a live run.' -ForegroundColor Yellow; return }
    if ($domainId -ne $ExpectedDomainId) { Write-Host "Domain mismatch: connected to $domainId, expected $ExpectedDomainId. Nothing changed." -ForegroundColor Red; return }
}

# ---- 1. Validate input --------------------------------------------
if (-not (Test-Path $InputCsv)) { Write-Host "Input file not found: $InputCsv" -ForegroundColor Red; return }
$rows = @(Import-Csv -Path $InputCsv)
$required = @('Col1','Col2')   # TODO: required CSV columns
$missingCols = @($required | Where-Object { $rows.Count -gt 0 -and $rows[0].PSObject.Properties.Name -notcontains $_ })
if ($missingCols) { Write-Host "Missing column(s): $($missingCols -join ', ')" -ForegroundColor Red; return }

$problems = @()
# <row-level checks: blanks, duplicates, formats>
if ($problems) { $problems | ForEach-Object { Write-Host $_ -ForegroundColor Red }; Write-Host 'Fix the input and run again. Nothing changed.'; return }

# ---- 2. Plan (reads only) -----------------------------------------
$plan = foreach ($r in $rows) {
    # Read current state with Get-/Resolve- functions and decide the action.
    # Action: Create | Update | Skip ; Reason explains Skip.
    [pscustomobject]@{ Key = $r.Col1; Action = 'Create'; Reason = '' }   # TODO: Create | Update | Skip
}

Write-Host ''
Write-Host "PLAN for domain $domainId" -ForegroundColor Cyan
$plan | Group-Object Action | ForEach-Object { Write-Host ("  {0,-8} {1}" -f $_.Name, $_.Count) }
$plan | Select-Object -First 10 | Format-Table -AutoSize | Out-String -Width 200 | Write-Host

if ($DryRun) { Write-Host 'DRY RUN: nothing changed. Review the plan, set $ExpectedDomainId and $DryRun = $false to apply.' -ForegroundColor Yellow; return }

# ---- 3. Execute ---------------------------------------------------
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }
$stamp   = Get-Date -Format 'yyyyMMdd-HHmmss'
$logPath = Join-Path $LogDir "task-$stamp.csv"   # TODO: name after the task
$results = @()

foreach ($p in $plan | Where-Object { $_.Action -ne 'Skip' }) {
    # TODO: call the module function, for example:
    #   $null = Add-Five9CloudCampaignSkill -CampaignName $p.Key -SkillId $skillId
    # Many functions return nothing on success, so verify by re-reading:
    $ok = $false   # TODO: set from a Get-/Resolve- call that shows the change is present
    $results += [pscustomobject]@{ Key = $p.Key; Action = $p.Action; Result = $(if ($ok) { 'OK' } else { 'FAILED' }) }
}
$results | Export-Csv -Path $logPath -NoTypeInformation

# ---- 4. Verify ----------------------------------------------------
$failed = @($results | Where-Object Result -ne 'OK')
Write-Host ''
Write-Host ("Done. OK: {0}  Failed: {1}  Log: {2}" -f ($results.Count - $failed.Count), $failed.Count, $logPath) -ForegroundColor Cyan
if ($failed) { $failed | Format-Table -AutoSize | Out-String -Width 200 | Write-Host }

# ---- Clean up: removes the stored login from this session ----------
Remove-Variable Five9 -Scope Global -ErrorAction SilentlyContinue
