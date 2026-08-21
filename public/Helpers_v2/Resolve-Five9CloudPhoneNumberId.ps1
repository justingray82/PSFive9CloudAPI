function Resolve-Five9CloudPhoneNumberId ([string]$PhoneNumberId, [string]$PhoneNumber) {
    if ($PhoneNumberId) { return $PhoneNumberId }
    # Normalize to +1E.164 to match the list's 'number' field, then return the numberUUID
    # (the tag-association URL uses numberUUID, not the dialable number or numberId).
    $cleanNumber = $PhoneNumber -replace '\D', ''
    if ($cleanNumber -notmatch '^\+') { $cleanNumber = "1$cleanNumber" -replace '^1{2,}', '1' }; $PhoneNumber = "+$cleanNumber"
    $result = Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "numbers/v1/domains/$($global:Five9.DomainId)/phone-numbers" @{ filter = 'type==PHONE_NUMBER' })
    $match  = $result.items | Where-Object { $_.numberId -eq $PhoneNumber }
    if ($match) { return $match.numberUUID }
    Write-Error "Phone number '$PhoneNumber' not found."; return $null
}