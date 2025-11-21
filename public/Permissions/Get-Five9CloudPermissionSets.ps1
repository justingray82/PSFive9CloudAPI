function Get-Five9CloudPermissionSets {
    [CmdletBinding()]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
        [string]$UserUID,
        [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
        [string]$userName
    )
    
    if (-not (Test-Five9CloudConnection -AuthType CloudAuth -AutoReconnect)) { return }

    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/users/$($UserUID)/permissions-roles"
    
    $headers = @{
        Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
        'Content-Type' = 'application/json'
    }

    $body = @{}
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to retrieve permission(s): $_"
    }
}

$PermissionSets = Get-Five9CloudPermissionSets -UserUID "SJRVQZQBCLX47T2SWQWWW6UV7W5JDYNE"
$PermissionSets.items.roles | ? {$_.role -like 'system.*'}
