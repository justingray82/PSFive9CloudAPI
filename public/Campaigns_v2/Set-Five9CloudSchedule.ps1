function Set-Five9CloudSchedule {
    param([string]$ScheduleId, [string]$ScheduleName, [Parameter(Mandatory)][hashtable]$ScheduleDetails)
    if (-not $ScheduleId) { $ScheduleId = Resolve-Five9CloudScheduleId $ScheduleName } ; if (-not $ScheduleId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/schedules/$ScheduleId" -Method Put -Body $ScheduleDetails
    if ($result -ne $false) { Write-Host "Schedule '$ScheduleName' updated successfully."; return $result } else { Write-Host "Failed to update schedule '$ScheduleName'."; return $false }
}
