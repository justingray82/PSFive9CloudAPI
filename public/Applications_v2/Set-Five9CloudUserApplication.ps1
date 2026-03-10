function Set-Five9CloudUserApplication {
    param([Parameter(Mandatory)][string]$Username, [ValidateSet("adt","web-java-admin","scc-admin","java-admin","plus-supervisor","admin-console","plus-agent","agent-assist","reporting")][Parameter(Mandatory)][string]$Application)
    $UserUID = Resolve-Five9CloudUserUID $Username; if (-not $UserUID) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/acl/v1/domains/$($global:Five9.DomainId)/users/$UserUID/applications/$Application" -Method Post
    if ($result -ne $false) { Write-Host "Application $Application assigned to $Username"} else { Write-Host "Failed to set application $Application to $Username"; return $false }
}