function Add-Five9CloudDigitalAssistance {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Response,
        [Parameter(Mandatory)][ValidateSet('RichTextEmailOnly','RichControlsMessaging','NoRichText')][string]$RichTextOption
    )
    $enableRichTextEmailOnly = $false; $enableRichControlsMessaging = $false
    switch ($RichTextOption) {
        'RichTextEmailOnly'     { $enableRichTextEmailOnly     = $true }
        'RichControlsMessaging' { $enableRichControlsMessaging = $true }
    }
    $body = @{
        name                        = $Name
        response                    = $Response
        enableRichTextEmailOnly     = $enableRichTextEmailOnly
        enableRichControlsMessaging = $enableRichControlsMessaging
    }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/digital-config-svc/v1/domains/$($global:Five9.DomainId)/assistances" -Method Post -Body $body
    if ($result -ne $false) { Write-Host "Digital assistance '$Name' created successfully."; return $result } else { Write-Host "Failed to create digital assistance '$Name'."; return $false }
}