# Five9Cloud PowerShell Module
# Function: Add-Five9CloudProfile
# Category: UserProfiles

function Add-Five9CloudProfile {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$Name,
        [string]$Description,
        [string]$Timezone,
        [string]$Locale
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/user-profiles"
    
    $body = @{
        name = $Name
    }
    if ($Description) { $body['description'] = $Description }
    if ($Timezone) { $body['timezone'] = $Timezone }
    if ($Locale) { $body['locale'] = $Locale }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to create profile: $_"
    }
}
