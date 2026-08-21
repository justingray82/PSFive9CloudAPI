function Resolve-Five9CloudSpeedDialId ([string]$SpeedDialId, [string]$SpeedDialCode) {
    if ($SpeedDialId) { return $SpeedDialId }
    # Speed dials have no name field; the human-facing identifier is the dial 'code' (e.g. '911').
    $result = Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "users/v1/domains/$($global:Five9.DomainId)/speed-dials" @{})
    $match  = $result.items | Where-Object { $_.code -eq $SpeedDialCode }
    if ($match) { return $match.speedDialId }
    Write-Error "Speed dial with code '$SpeedDialCode' not found."; return $null
}