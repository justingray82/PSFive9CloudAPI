function Resolve-Five9CloudReasonCodeId ([string]$ReasonCodeId, [string]$ReasonCodeName) {
    if ($ReasonCodeId) { return $ReasonCodeId }
    $result = Get-Five9CloudReasonCodeList -Filter "name=='$ReasonCodeId'" -Fields 'id,name'
    if ($result.items.Count -gt 0) { return $result.items.ReasonCodeId }
    Write-Host "Reason Code '$ReasonCodeName' not found." -ForegroundColor Red; return $null
}