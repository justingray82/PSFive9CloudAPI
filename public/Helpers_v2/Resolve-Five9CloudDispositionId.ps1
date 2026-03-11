function Resolve-Five9CloudDispositionId ([string]$DispositionId, [string]$DispositionName) {
    if ($DispositionId) { return $DispositionId }
    $result = Get-Five9CloudDispositionList -Filter "name=='$DispositionId'" -Fields 'id,name'
    if ($result.items.Count -gt 0) { return $result.items.dispositionId }
    Write-Error "Dispositon '$DispositionName' not found."; return $null
}