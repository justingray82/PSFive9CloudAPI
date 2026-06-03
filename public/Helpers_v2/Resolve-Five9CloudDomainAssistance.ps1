function Resolve-Five9CloudDomainAssistance ([string]$AssistanceName) {
    $result = Get-Five9CloudDigitalAssistance -Filter "name=='$AssistanceName'" -Fields 'assistanceId,name'
    if ($result.assistances.Count -gt 0) { return $result.assistances.assistanceId }
    Write-Host "Assistance '$AssistanceName' not found." -ForegroundColor Red; return $null
}