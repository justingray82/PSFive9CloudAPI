function Resolve-Five9CloudReasonCodeSetID ([string]$ReasonCodeSet) {
    $result = Get-Five9CloudReasonCodeSetList -Filter "name=='$ReasonCodeSet'" -Fields 'reasonCodeSetId,name'
    if ($result.items.Count -gt 0) { return $result.items.reasonCodeSetId }
    Write-Host "Reason Code Set '$ReasonCodeSet' not found." -ForegroundColor Red; return $null
}