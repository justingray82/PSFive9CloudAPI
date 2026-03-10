function Set-Five9CloudUserDID {
    param([string]$UserUID, [string]$Username, [string]$DID)
    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }
    $cleanDID = $DID -replace '\D', ''
    if ($cleanDID -notmatch '^\+') { $cleanDID = "1$cleanDID" -replace '^1{2,}', '1' }; $DID = "+$cleanDID"
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/users/v1/domains/$($global:Five9.DomainId)/users/$userUID/numbers/$DID" -Method Post
    if ($result -ne $false) { Write-Host "$DID assigned to $Username" } else { Write-Host "Failed to assign $DID to $Username"; return $false }
}