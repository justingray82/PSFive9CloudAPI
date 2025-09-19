# Five9Cloud PowerShell Module
# Function: Update-Five9CloudProfile
# Category: UserProfiles

function Update-Five9CloudProfile {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$UserProfileId,
        [string]$Name,
        [string]$Description,
        [string]$Timezone,
        [string]$Locale
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/user-profiles/$UserProfileId"
    
    $body = @{
        userProfileId = $UserProfileId
    }
    if ($Name) { $body['name'] = $Name }
    if ($Description) { $body['description'] = $Description }
    if ($Timezone) { $body['timezone'] = $Timezone }
    if ($Locale) { $body['locale'] = $Locale }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to update profile: $_"
    }
}
