function Add-Five9CloudDigitalAssistance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Response,

        [Parameter(Mandatory = $true)]
        [ValidateSet('RichTextEmailOnly', 'RichControlsMessaging', 'NoRichText')]
        [string]$RichTextOption
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
  
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/digital-config-svc/v1/domains/$($global:Five9CloudToken.DomainId)/assistances"

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
        name = $Name
        enableRichTextEmailOnly = $enableRichTextEmailOnly
        enableRichControlsMessaging = $enableRichControlsMessaging
        response = $Response
    } | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body $body
        
        return $response
    } catch {
        Write-Error "Failed to create Digital Assistance: $_"
    }
}