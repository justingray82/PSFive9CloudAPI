function Set-Five9CloudSchedule {
    param(
        [string]$ScheduleId,
        [string]$ScheduleName,
        [string]$Name,
        [string]$Description,
        [string]$DefaultScriptId,
        [hashtable]$Action,
        [hashtable[]]$Events,
        [hashtable[]]$ScriptParameters
    )
    if (-not $ScheduleId) { $ScheduleId = Resolve-Five9CloudScheduleId $ScheduleName } ; if (-not $ScheduleId) { return }

    # Seed from current state so PUT doesn't clobber unspecified fields
    $current = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/schedules/$ScheduleId"
    if (-not $current) { return }
    $body = $current

    if ($Name)             { $body.name             = $Name }
    if ($Description)      { $body.description      = $Description }
    if ($DefaultScriptId)  { $body.defaultScript    = @{ ewScriptId = $DefaultScriptId } }
    if ($Action)           { $body.action           = $Action }
    if ($Events)           { $body.events           = $Events }
    if ($ScriptParameters) { $body.scriptParameters = $ScriptParameters }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/schedules/$ScheduleId" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Schedule '$ScheduleName' updated successfully."; return $result } else { Write-Host "Failed to update schedule '$ScheduleName'."; return $false }
}
