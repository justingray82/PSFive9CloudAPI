function Add-Five9CloudReasonCodeSetToUser {
    param([Parameter(Mandatory = $true)][string]$Username,[string]$UserUID,[Parameter(Mandatory = $true)][string]$ReasonCodeSet,[string]$SetID)
    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }
    if (-not $SetID) { $SetID = Resolve-Five9CloudReasonCodeSetID $ReasonCodeSet } ; if (-not $SetID) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/agent-sessions/v1/domains/$($global:Five9.DomainId)/reason-code-sets/$SetID/users/$UserUID" -Method Post
    if ($result -ne $false) { Write-Host "Reason Code Set $SetID added to user $UserUID" } else { Write-Host "Failed to add Reason Code Set $SetID to $UserUID" }
}