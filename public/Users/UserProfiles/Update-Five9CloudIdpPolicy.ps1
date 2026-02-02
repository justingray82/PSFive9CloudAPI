# Five9Cloud PowerShell Module
# Function: Update-Five9CloudIdpPolicy
# Category: UserProfiles

function Update-Five9CloudIdpPolicy {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$IdpPolicyId,
        [string]$Name,
        [string]$Description,
        [hashtable]$Saml
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/idp-policies/$IdpPolicyId"
    
    $body = @{
        idpPolicyId = $IdpPolicyId
    }
    if ($Name) { $body['name'] = $Name }
    if ($Description) { $body['description'] = $Description }
    if ($Saml) { $body['saml'] = $Saml }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to update IDP policy: $_"
    }
}
