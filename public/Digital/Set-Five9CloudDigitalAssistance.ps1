function Set-Five9CloudDigitalAssistance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AssistanceName,

        [Parameter(Mandatory = $true)]
        [string]$Response,

        [Parameter(Mandatory = $true)]
        [ValidateSet('RichTextEmailOnly', 'RichControlsMessaging', 'NoRichText')]
        [string]$RichTextOption
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }

        Write-Verbose "Resolving assistance name '$AssistanceName' to assistance ID..."
        
        try {
            $assistances = Get-Five9CloudDigitalAssistance -Name "$($AssistanceName)"
            if ($assistances.assistanceId -ne $null) {
                $AssistanceID = $assistances.assistanceId
                Write-Verbose "Found assistance with ID: $AssistanceID"
            }
        } catch {
            Write-Error "Assistance with name '$AssistanceName' not found."
            return
        }
  
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/digital-config-svc/v1/domains/$($global:Five9CloudToken.DomainId)/assistances/$($AssistanceID)"

    # Set the boolean flags based on the selected option
    switch ($RichTextOption) {
        'RichTextEmailOnly' {
            $enableRichTextEmailOnly = $true
            $enableRichControlsMessaging = $false
        }
        'RichControlsMessaging' {
            $enableRichTextEmailOnly = $false
            $enableRichControlsMessaging = $true
        }
        'NoRichText' {
            $enableRichTextEmailOnly = $false
            $enableRichControlsMessaging = $false
        }
    }

    $body = @{
        name = $AssistanceName
        enableRichTextEmailOnly = $enableRichTextEmailOnly
        enableRichControlsMessaging = $enableRichControlsMessaging
        response = $Response
    } | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body $body
        
        return $response
    } catch {
        Write-Error "Failed to create Digital Assistance: $_"
    }
}