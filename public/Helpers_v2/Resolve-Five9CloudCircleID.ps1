function Resolve-Five9CloudCircleID ([string]$CircleName) {
    $result = Get-Five9CloudCircleDetails -Filter "name=='$CircleName'" -Fields 'id,name'
    if ($result.items.Count -gt 0) { return $result.items.id }
    Write-Error "Circle '$CircleName' not found."; return $null
}