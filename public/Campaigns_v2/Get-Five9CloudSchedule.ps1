function Get-Five9CloudSchedule {
    param([string]$ScheduleId, [string]$ScheduleName)
    if (-not $ScheduleId) { $ScheduleId = Resolve-Five9CloudScheduleId $ScheduleName } ; if (-not $ScheduleId) { return }
    Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/schedules/$ScheduleId"
}
