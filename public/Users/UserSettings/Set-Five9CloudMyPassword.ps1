# Five9Cloud PowerShell Module
# Function: Set-Five9CloudMyPassword
# Category: UserSettings

function Set-Five9CloudMyPassword {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [string]$OldPassword,
        [string]$NewPassword,
        [bool]$RevokeSessions
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/my-password:change"
    
    $body = @{}
    if ($OldPassword) { $body['oldPassword'] = $OldPassword }
    if ($NewPassword) { $body['newPassword'] = $NewPassword }
    if ($PSBoundParameters.ContainsKey('RevokeSessions')) { $body['revokeSessions'] = $RevokeSessions }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to change password: $_"
    }
}
