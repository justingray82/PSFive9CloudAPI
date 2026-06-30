function Get-Five9CloudDomainMFAPolicies {
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/users/v1/domains/$($global:Five9.DomainId)/mfa/policy"
    if ($result -ne $false) { return $result.policyId }
}