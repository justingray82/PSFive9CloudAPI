function Get-Five9CloudUserACLDetails {
    param([string]$UserUID, [string]$Username, [ValidateSet("permissions","roles","applicationSets","applications")][Parameter(Mandatory)][string]$Scope)
    if (-not $UserUID -and $Username) { $UserUID = Resolve-Five9CloudUserUID $Username; if (-not $UserUID) { return } }
    if ($UserUID) {
        $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/acl/v1/domains/$($global:Five9.DomainId)/users?userUID=$UserUID"
    } else {
        $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/acl/v1/domains/$($global:Five9.DomainId)/users"
    }

    if (-not $result) { return }
    if ($UserUID) { $result.items.$Scope } else { $result.items }
}