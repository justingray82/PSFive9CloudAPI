function Get-Five9CloudUserACLDetails {
    param([string]$UserUID, [string]$Username, [ValidateSet("permissions","roles","applicationSets","applications","circles")][Parameter(Mandatory)][string]$Scope)
    if (-not $UserUID -and $Username) { $UserUID = Resolve-Five9CloudUserUID $Username; if (-not $UserUID) { return } }
    if($Scope -eq 'circles') {
        if ($UserUID) {
            $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/circles/v1/domains/$($global:Five9.DomainId)/circles/users/$UserUID"
            $result.items.name
        } else {
            Write-Host "Username must be supplied for Circles scope." -ForegroundColor Red; return $null
        }
    } else {
        if ($UserUID) {
            $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/acl/v1/domains/$($global:Five9.DomainId)/users?userUID=$UserUID"
        } else {
            $result = Invoke-Five9CloudPagedAPI "$($global:Five9.ApiBaseUrl)/acl/v1/domains/$($global:Five9.DomainId)/users"
        }
        if (-not $result) { return }
        if ($UserUID) { $result.items.$Scope } else { $result.items }
    }
}