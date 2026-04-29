function Resolve-Five9CloudScheduleId ([string]$ScheduleName) {
    $result = Get-Five9CloudSchedules -Filter "name=='$ScheduleName'"
    if ($result.items.Count -gt 0) { return $result.items.id }
    Write-Host "Schedule '$ScheduleName' not found." -ForegroundColor Red; return $null
}
