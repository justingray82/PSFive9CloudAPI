function Add-Five9CloudCircleToUser {
    param([Parameter(Mandatory = $true)][string]$Username,[string]$UserUID,[Parameter(Mandatory = $true)][string]$CircleName,[string]$CircleID)
    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }
    if (-not $CircleID) { $CircleID = Resolve-Five9CloudCircleID $CircleName } ; if (-not $CircleID) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/circles/v1/domains/$($global:Five9.DomainId)/circles/$CircleID/users/$UserUID" -Method Post
    if ($result -ne $false) { Write-Host "CircleID $CircleID added to user $UserUID" } else { Write-Host "Failed to add CircleID $CircleID to user $UserUID" }
}