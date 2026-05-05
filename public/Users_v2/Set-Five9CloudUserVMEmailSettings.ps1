function Set-Five9CloudUserVMEmailSettings {
    param(
        [string]$Username,
        [string]$UserUID,
        [string[]]$CcEmailAddresses,
        [bool]$AttachVoicemail,
        [bool]$EmbedCampaignProfileLayoutFields,
        [switch]$Remove
    )

    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }

    if ($Remove) {
        $body = @{ email = $null }
    } else {
        # Seed from current settings so unspecified fields are preserved
        $current = Get-Five9CloudUserVMEmailSettings -UserUID $UserUID
        $email = if ($current -and $current.email) {
            @{
                attachVoicemail                  = $current.email.attachVoicemail
                embedCampaignProfileLayoutFields = $current.email.embedCampaignProfileLayoutFields
                ccEmailAddresses                 = $current.email.ccEmailAddresses
            }
        } else {
            @{ attachVoicemail = $false; embedCampaignProfileLayoutFields = $false; ccEmailAddresses = @() }
        }

        if ($PSBoundParameters.ContainsKey('AttachVoicemail'))                  { $email.attachVoicemail                  = $AttachVoicemail }
        if ($PSBoundParameters.ContainsKey('EmbedCampaignProfileLayoutFields')) { $email.embedCampaignProfileLayoutFields = $EmbedCampaignProfileLayoutFields }
        if ($PSBoundParameters.ContainsKey('CcEmailAddresses'))                 { $email.ccEmailAddresses                 = $CcEmailAddresses }

        $body = @{ email = $email }
    }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/voicemails/v1/domains/$($global:Five9.DomainId)/users/$UserUID/voicemail-notification-settings/email" -Method Put -Body $body
    $displayName = if ($Username) { $Username } else { $UserUID }
    if ($result -ne $false) {
        if ($Remove) { Write-Host "Voicemail email notification settings removed for $displayName." }
        else         { Write-Host "Voicemail email notification settings updated for $displayName." }
    } else {
        Write-Host "Failed to update voicemail email notification settings for $displayName."
        return $false
    }
}