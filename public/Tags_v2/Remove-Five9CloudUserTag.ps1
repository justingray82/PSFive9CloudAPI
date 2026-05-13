function Remove-Five9CloudUserTag {
    param([string]$UserUID, [Parameter(Mandatory)][string]$Username, [string]$Tag, [string]$TagId)
    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }
    if (-not $TagId) { $TagId = Resolve-Five9CloudDomainTag $Tag } ; if (-not $TagId) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/users/v1/domains/$($global:Five9.DomainId)/users/$UserUID/tags/$TagId" -Method Delete
    if ($result -ne $false) { Write-Host "Tag $TagId removed from user '$Username'." } else { Write-Host "Failed to remove tag $TagId from user '$Username'."; return $false }
}