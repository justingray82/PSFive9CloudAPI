function Set-Five9CloudUserVMGreeting {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
        [string]$UserID,
        [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
        [string]$UserName,
        [Parameter()]
        [string]$GreetingFile
    )

    if (-not (Test-Five9CloudConnection -AuthType RestApi)) { return }

    $fileBytes = [System.IO.File]::ReadAllBytes($GreetingFile)
    $fileBase64 = [Convert]::ToBase64String($fileBytes)

    # Create the JSON body
    $body = @{
        file = $fileBase64
    } | ConvertTo-Json

    # If CampaignName is provided, resolve it to CampaignId
    if ($PSCmdlet.ParameterSetName -eq 'ByName') {
        Write-Verbose "Resolving user name '$ByName' to UserUID..."
        
        try {
            $UserLists = Get-Five9CloudUserList -Filter "username=='$($UserName)'"
            if ($UserLists.items.count -gt 0) {
                $UserID = $UserLists.items.vcc.userId
                Write-Verbose "Found user with ID: $UserName"
            }
        } catch {
            Write-Verbose "No user found with name '$UserName'"
        }
        
        # If still not found, throw error
        if (-not $UserID) {
            Write-Error "User with name '$UserName' not found."
            return
        }
    }
    
    $uri = "$($global:Five9CloudToken.RestBaseUrl)/v1/domains/$($global:Five9CloudToken.DomainId)/users/$($UserID)/greeting"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Basic $($global:Five9CloudToken.RestBasicAuth)"
            'Content-Type' = 'application/json'
        } -Body $body | Out-Null
    } catch {
        Write-Error "Failed to set greeting: $_"
    }
}