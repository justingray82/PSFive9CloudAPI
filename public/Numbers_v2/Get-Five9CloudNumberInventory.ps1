function Get-Five9CloudNumberInventory {
    # Lists how many numbers Five9 has in inventory per area code (prefix).
    # Use this to see whether Add-Five9CloudPhoneNumber can fill a request, or
    # whether New-Five9CloudNumberOrder is needed.
    [CmdletBinding()]
    param(
        [string[]]$AreaCode,
        [ValidateSet('DID', 'TFN')][string]$NumberType = 'DID',
        [string]$Country = 'US'
    )

    $base = "numbers-svc/v2/domains/$($global:Five9.DomainId)/prefixes"

    $codes = if ($AreaCode) { $AreaCode | ForEach-Object { $_ -replace '\D', '' } } else { @($null) }

    foreach ($code in $codes) {
        $filter = "country==$Country;inventory==true"
        if ($code) { $filter += ";prefix==$code*" }
        $filter += ";type==$NumberType"

        $result = Invoke-Five9CloudApi (Set-Five9CloudQueryUri $base @{ filter = $filter })
        if ($result -eq $false) { Write-Error "Failed to retrieve inventory$(if ($code) { " for area code $code" })."; continue }

        $prefixes = @($result.prefixes | Where-Object { -not [string]::IsNullOrEmpty($_.prefix) })

        # The API does a starts-with match (prefix==330*); keep exact matches only when an area code was given
        if ($code) {
            $prefixes = @($prefixes | Where-Object { $_.prefix -eq $code })
            if (-not $prefixes) {
                [PSCustomObject]@{ AreaCode = $code; State = $null; StateCode = $null; Available = 0; NumberType = $NumberType; Country = $Country }
                continue
            }
        }

        foreach ($p in $prefixes) {
            [PSCustomObject]@{
                AreaCode   = $p.prefix
                State      = $p.state
                StateCode  = $p.stateCode
                Available  = [int]$p.count
                NumberType = $p.type
                Country    = $p.country
            }
        }
    }
}