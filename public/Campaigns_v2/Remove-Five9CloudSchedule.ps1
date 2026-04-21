function Remove-Five9CloudSchedule {
    param([string]$ScheduleId, [string]$ScheduleName)
    if (-not $ScheduleId) { $ScheduleId = Resolve-Five9CloudScheduleId $ScheduleName } ; if (-not $ScheduleId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/schedules/$ScheduleId" -Method Delete
    if ($result -ne $false) { Write-Host "Schedule '$ScheduleName' deleted successfully." } else { Write-Host "Failed to delete schedule '$ScheduleName'."; return $false }
}
