function Resolve-Five9CloudDomainTag ([string]$TagName) {
    $result = Get-Five9CloudDomainTags -Filter "name=='$TagName'" -Fields 'tagId,name'
    if ($result.items.Count -gt 0) { return $result.items.tagId }
    Write-Host "Tag '$TagName' not found." -ForegroundColor Red; return $null
}