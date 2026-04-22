function Set-Five9CloudInternalCallsSettings {
    param(
        [bool]$TransferTimedOutInternalCalls,
        [ValidateRange(0,3599)][int]$InternalCallTimeout
    )
    $body = @{}
    if ($PSBoundParameters.ContainsKey('TransferTimedOutInternalCalls')) { $body.transferTimedOutInternalCalls = $TransferTimedOutInternalCalls }
    if ($PSBoundParameters.ContainsKey('InternalCallTimeout'))           { $body.internalCallTimeout           = $InternalCallTimeout }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/internal-calls-settings" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Internal calls settings updated successfully."; return $result } else { Write-Host "Failed to update internal calls settings."; return $false }
}
