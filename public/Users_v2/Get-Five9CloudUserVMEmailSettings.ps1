function Get-Five9CloudUserVMEmailSettings {
    param([string]$Username, [string]$UserUID)
    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }
    Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/voicemails/v1/domains/$($global:Five9.DomainId)/users/$UserUID/voicemail-notification-settings/email"
}