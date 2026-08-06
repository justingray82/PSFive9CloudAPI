function Resolve-Five9CloudContactFieldId ([string]$FieldId, [string]$FieldName) {
    if ($FieldId) { return $FieldId }
    # Contact-variable-to-ANI mapping only applies to PHONE-type contact fields.
    # Response is { items, pagination } (no cursor paging); the display name is .title, id is .id
    $uri = Set-Five9CloudQueryUri "contacts/v2/domains/$($global:Five9.DomainId)/fields" @{ filter = 'type==PHONE' }
    $result = Invoke-Five9CloudApi $uri
    if (-not $result) { Write-Error "Unable to retrieve contact fields."; return $null }
    $match = $result.items | Where-Object { $_.title -eq $FieldName }
    if ($match) { return $match.id }
    Write-Error "Contact field '$FieldName' not found (must be a PHONE-type field)."; return $null
}