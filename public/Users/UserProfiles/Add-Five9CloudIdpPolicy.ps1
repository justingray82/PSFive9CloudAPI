# Five9Cloud PowerShell Module
# Function: Add-Five9CloudIdpPolicy
# Category: UserProfiles

function Add-Five9CloudIdpPolicy {
    [CmdletBinding()]
    param (

        [string]$Name,
        [string]$Description,
        [string]$OrganizationId,
        [hashtable]$Saml,
        [string]$Certificate
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/idp-policies/saml"
    
    $body = @{}
    if ($Name) { $body['name'] = $Name }
    if ($Description) { $body['description'] = $Description }
    if ($OrganizationId) { $body['organizationId'] = $OrganizationId }
    if ($Saml) { $body['saml'] = $Saml }
    if ($Certificate) { $body['certificate'] = $Certificate }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json)
    } catch {
        Write-Error "Failed to create IDP policy: $_"
    }
}
