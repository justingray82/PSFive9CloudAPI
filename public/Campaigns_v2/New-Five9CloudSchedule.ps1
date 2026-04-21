function New-Five9CloudSchedule {
    param([Parameter(Mandatory)][hashtable]$ScheduleDetails)
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/schedules" -Method Post -Body $ScheduleDetails
    if ($result -ne $false) { Write-Host "Schedule '$($ScheduleDetails.name)' created successfully."; return $result } else { Write-Host "Failed to create schedule '$($ScheduleDetails.name)'."; return $false }
}
