function Set-Five9CloudUserSecurity {
    param([Parameter(Mandatory, ParameterSetName = "SSO")][Parameter(Mandatory, ParameterSetName = "Password")][string]$Username,[Parameter(Mandatory, ParameterSetName = "SSO")][string]$IdPPolicy,[Parameter(Mandatory, ParameterSetName = "SSO")][string]$FederationID)
    $UserUID = Resolve-Five9CloudUserUID $Username; if (-not $UserUID) { return }
    switch ($PSCmdlet.ParameterSetName) {
        "SSO" {
            $PolicyID = Resolve-Five9CloudIdpPolicyID $IdPPolicy; if (-not $PolicyID) { return }
            $body   = @{idpFederationId = "$($FederationID)"}
            $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/users/v1/domains/$($global:Five9.DomainId)/users/$($UserUID)/idp-policies/$($PolicyID)" -Method Put -Body $body
            if ($result -ne $false) { Write-Host "$IdPPolicy set for $Username"} else { Write-Host "Failed to set $IdPPolicy to $Username"; return $false }
        }

        "Password" {
            $PolicyID = Resolve-Five9CloudUserIDPPolicy $Username
            $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/users/v1/domains/$($global:Five9.DomainId)/users/$($UserUID)/idp-policies/$($PolicyID)" -Method Delete
            if ($result -ne $false) { Write-Host "$Username set to password authentication"} else { Write-Host "Failed to assign password authentication to $Username"; return $false }
            $pass_body   = @{sendEmail = $true}
            $pass_result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/users/v1/domains/$($global:Five9.DomainId)/users/$($UserUID)/password:reset" -Method Put -Body $pass_body
            if ($pass_result -ne $false) { Write-Host "Password reset email sent to $Username"} else { Write-Host "Failed to send password reset email to $Username"; return $false }
        }
    }
}