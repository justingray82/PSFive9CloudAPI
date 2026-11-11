# Patterns for scripts that use PSFive9CloudAPI

Copy-ready building blocks. All are Windows PowerShell 5.1 compatible. Swap in
the user's own names; check each function's parameters in `functions.md`.

Contents: 1 Connect · 2 Read lists · 3 Find one object · 4 Names vs IDs in loops ·
5 Write and verify · 6 Bulk from CSV with dry run · 7 Export to CSV/JSON ·
8 Back up before changing · 9 Campaign details · 10 Numbers · 11 Tags ·
12 Audit log · 13 Clean up

---

## 1. Connect

```powershell
Import-Module PSFive9CloudAPI -ErrorAction Stop

$cred = Get-Credential -Message 'Five9 admin login'
if (-not $cred) { return }
Connect-Five9Cloud -Region 'us' -SkipUpdateCheck `
    -Username $cred.UserName -Password $cred.GetNetworkCredential().Password
$cred = $null
if (-not $global:Five9 -or -not $global:Five9.AccessToken) { Write-Host 'Login failed.' -ForegroundColor Red; return }
Write-Host "Connected to domain $($global:Five9.DomainId)"
```

Service account (OAuth) instead of a user: put the client ID in the user name
box and the secret in the password box, then
`Connect-Five9Cloud -ClientId $cred.UserName -ClientSecret $cred.GetNetworkCredential().Password`.

Guard against the wrong domain before any write:
```powershell
$ExpectedDomainId = '123456'
if ($global:Five9.DomainId -ne $ExpectedDomainId) { Write-Host 'Wrong domain. Stopping.' -ForegroundColor Red; return }
```

## 2. Read lists (page envelopes)

```powershell
$users     = @((Get-Five9CloudUserDetails).items)
$campaigns = @((Get-Five9CloudCampaignList).items)
$inbound   = @($campaigns | Where-Object { $_.type -eq 'INBOUND' })
```
Wrapping in `@( )` keeps it an array even with zero or one result, so `.Count`
works. Inspect a record's fields before using them:
```powershell
$campaigns[0] | Format-List *
```

Functions whose Output says "list of items" return records directly:
```powershell
$configs = @(Get-Five9CloudEmailConfigurations)
```

## 3. Find one object

Server-side filter (fast, quiet when nothing matches):
```powershell
$u = @((Get-Five9CloudUserDetails -Filter "username=='jdoe@acme.com'").items) | Select-Object -First 1
if (-not $u) { Write-Host 'No such user.'; return }
```

Resolver (returns the ID or `$null`, prints "not found" when missing):
```powershell
$uid = Resolve-Five9CloudUserUID -Username 'jdoe@acme.com'
if (-not $uid) { return }
```

Several at once with `=in=` (the module uses this with IDs):
```powershell
$tagIds = @('101','102','103')
$tags = @((Get-Five9CloudDomainTags -Filter "tagId=in=($($tagIds -join ','))").items)
```

## 4. Names vs IDs in loops

Each name-based call does a lookup first. In a loop, resolve once:
```powershell
$skillId = Resolve-Five9CloudSkillId -SkillName 'Billing'
foreach ($c in $inbound) {
    $null = Add-Five9CloudCampaignSkill -CampaignId $c.campaignId -SkillId $skillId
}
```
Field names (`campaignId`, `userUID`, ...) differ per object type; check with
`Format-List *` (pattern 2).

## 5. Write and verify

```powershell
$r = Set-Five9CloudUserDetails -Username 'jdoe@acme.com' -Timezone 'America/New_York'
if ($r -eq $false) { Write-Host 'Update failed.' -ForegroundColor Red }

# Many writes return nothing on success, so confirm by re-reading:
$check = @((Get-Five9CloudUserDetails -Filter "username=='jdoe@acme.com'").items) | Select-Object -First 1
$check | Select-Object username, timezone
```
Do not use `try/catch` to detect API failures; the module prints and returns
`$false` instead of throwing.

To set a `[bool]` parameter to false, pass it explicitly:
`-MustChangePassword $false`. For a `[switch]`: `-NoWait:$false`.

## 6. Bulk from CSV with a dry run

```powershell
$DryRun = $true
$rows = @(Import-Csv '.\input\changes.csv')         # columns: Username,Timezone

$results = foreach ($row in $rows) {
    $u = @((Get-Five9CloudUserDetails -Filter "username=='$($row.Username)'").items) | Select-Object -First 1
    if (-not $u)                       { $status = 'SKIP: not found' }
    elseif ($u.timezone -eq $row.Timezone) { $status = 'SKIP: already set' }
    elseif ($DryRun)                   { $status = "WOULD CHANGE: $($u.timezone) -> $($row.Timezone)" }
    else {
        $r = Set-Five9CloudUserDetails -UserUID $u.userUID -Timezone $row.Timezone
        $status = if ($r -eq $false) { 'FAILED' } else { 'OK' }
    }
    [pscustomobject]@{ Username = $row.Username; Status = $status }
}
$results | Format-Table -AutoSize | Out-String -Width 200 | Write-Host
$results | Export-Csv ".\logs\changes-$(Get-Date -Format yyyyMMdd-HHmmss).csv" -NoTypeInformation
```
Field names such as `timezone` come from the API; confirm them with pattern 2.

## 7. Export to CSV or JSON

```powershell
$users = @((Get-Five9CloudUserDetails).items)
$users | Select-Object username, firstName, lastName, email, status |
    Export-Csv '.\exports\users.csv' -NoTypeInformation
$users | ConvertTo-Json -Depth 20 | Set-Content '.\exports\users.json' -Encoding UTF8
```
Nested properties don't flatten into CSV; pick fields with `Select-Object` or use
JSON. Exports hold customer data: keep them private.

## 8. Back up before changing or deleting

```powershell
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
Get-Five9CloudOutboundCampaignDetails -CampaignName 'Collections' |
    ConvertTo-Json -Depth 20 | Set-Content ".\backups\Collections-$stamp.json" -Encoding UTF8
```

## 9. Campaign details

```powershell
# Everything about one campaign, all tabs combined:
$d = Get-Five9CloudInboundCampaignDetails -CampaignName 'Support'
# Only some tabs:
$d = Get-Five9CloudInboundCampaignDetails -CampaignName 'Support' -Include Skills,Numbers
# Every inbound campaign (these functions accept pipeline input):
$all = $inbound | Get-Five9CloudInboundCampaignDetails
```
Use `-Raw` when you need the untouched API responses.

Dialing mode changes pick one mode switch per call:
```powershell
Set-Five9CloudCampaignDialingSettings -CampaignName 'Collections' -Progressive -DialingRatio 50
```
Check allowed values for each mode's options in `functions.md` or the source
before running; mixing options from different modes fails parameter binding.

## 10. Numbers

```powershell
Get-Five9CloudNumberCredits                     # e.g. DID_AVAILABLE
Get-Five9CloudNumberInventory -AreaCode 330,216 # Available per area code
# Uses credits: confirm with the user first. Quantity is per area code.
Add-Five9CloudPhoneNumber -AreaCode 330 -Quantity 2
Add-Five9CloudAniGroupNumber -AniGroupName 'Local Presence' -Ani '330-555-0100' -AreaCode 330
```
Any North American format works; the module normalizes to `+1XXXXXXXXXX`.
For non-+1 numbers use `-NoNormalize` where offered.

## 11. Tags

`Add-Five9CloudTagScope` shows its target parameters only after `-Scope`:
```powershell
Add-Five9CloudTagScope -Scope campaign -TagName 'Q4' -CampaignName 'Sales'
Add-Five9CloudTagScope -Scope user     -TagName 'Tier2' -Username 'jdoe@acme.com'
```

## 12. Audit log

```powershell
$events = @((Get-Five9CloudConfigEvents -StartDate (Get-Date).AddDays(-7) -TimeZoneOffset '-05:00').items)
$events | Select-Object -First 20 | Format-List *
```
Default window is the last 24 hours; set the offset to the user's timezone.
Useful for "who changed this" and for finding why a write failed.

## 13. Clean up

```powershell
Remove-Variable Five9 -Scope Global -ErrorAction SilentlyContinue
```
