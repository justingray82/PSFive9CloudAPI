function Set-Five9CloudDigitalAssistance {
    param(
        [Parameter(Mandatory)][string]$AssistanceName,
        [Parameter(Mandatory)][string]$Response,
        [Parameter(Mandatory)][ValidateSet('RichTextEmailOnly','RichControlsMessaging','NoRichText')][string]$RichTextOption
    )
    $assistance = Get-Five9CloudDigitalAssistance -Name $AssistanceName
    if (-not $assistance) { Write-Error "Digital assistance '$AssistanceName' not found."; return }
    $enableRichTextEmailOnly = $false; $enableRichControlsMessaging = $false
    switch ($RichTextOption) {
        'RichTextEmailOnly'     { $enableRichTextEmailOnly     = $true }
        'RichControlsMessaging' { $enableRichControlsMessaging = $true }
    }
    $body = @{
        name                        = $AssistanceName
        response                    = $Response
        enableRichTextEmailOnly     = $enableRichTextEmailOnly
        enableRichControlsMessaging = $enableRichControlsMessaging
    }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/digital-config-svc/v1/domains/$($global:Five9.DomainId)/assistances/$($assistance.assistanceId)" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Digital assistance '$AssistanceName' updated successfully." } else { Write-Host "Failed to update digital assistance '$AssistanceName'."; return $false }
}