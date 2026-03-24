function Get-Five9CloudUserACLDetails {
    param([string]$UserUID, [string]$Username, [ValidateSet("permissions","roles","applicationSets","applications")][Parameter(Mandatory)][string]$Scope)
    $UserUID = Resolve-Five9CloudUserUID $Username; if (-not $UserUID) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/acl/v1/domains/$($global:Five9.DomainId)/users?userUID=$($UserUID)"
    $result.items.$Scope
}