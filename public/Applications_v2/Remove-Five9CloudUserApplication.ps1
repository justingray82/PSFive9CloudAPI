function Remove-Five9CloudUserApplication {
    param([string]$UserUID, [string]$Username, [ValidateSet("adt","web-java-admin","scc-admin","java-admin","plus-supervisor","admin-console","plus-agent","agent-assist","reporting")][Parameter(Mandatory)][string]$Application)
    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }
    Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/acl/v1/domains/$($global:Five9.DomainId)/users/$($UserUID)/applications/$Application" -Method DELETE
}