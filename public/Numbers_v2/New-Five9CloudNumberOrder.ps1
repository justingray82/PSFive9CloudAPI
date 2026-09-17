function New-Five9CloudNumberOrder {
    # Requests numbers from Five9 for area codes that have no (or not enough) inventory.
    # This opens an order (e.g. TS-79962) that Five9 fulfills; it does not claim numbers immediately.
    #   New-Five9CloudNumberOrder -AreaCode 954 -Quantity 5
    #   New-Five9CloudNumberOrder -AreaCode 954,305 -Quantity 2
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string[]]$AreaCode,
        [ValidateRange(1, 1000)][int]$Quantity = 1,            # per area code
        [ValidateSet('DID', 'TFN')][string]$NumberType = 'DID',
        [string]$Country = 'US'
    )

    $codes = @($AreaCode | ForEach-Object { $_ -replace '\D', '' } | Where-Object { $_ } | Select-Object -Unique)
    $bad = @($codes | Where-Object { $_ -notmatch '^\d{3}$' })
    if ($bad) { Write-Error "Invalid area code(s): $($bad -join ', '). Expected 3 digits."; return }
    if (-not $codes) { Write-Error "No valid area codes to order."; return }

    $prefixes = foreach ($code in $codes) { @{ prefix = $code; quantity = $Quantity } }
    $body = @{ country = $Country; numberType = $NumberType; prefixes = @($prefixes) }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/numbers-svc/v1/domains/$($global:Five9.DomainId)/number-orders" -Method Post -Body $body
    if ($result -eq $false -or -not $result.numberOrderId) { Write-Host "Failed to submit number order."; return $false }

    Write-Host "Number order $($result.numberOrderId) submitted ($($result.status)) for $(($codes | ForEach-Object { "$_ x$Quantity" }) -join ', ')."
    [PSCustomObject]@{
        NumberOrderId = $result.numberOrderId
        Status        = $result.status
        NumberType    = $result.numberType
        Country       = $result.country
        Prefixes      = @($result.prefixes)
    }
}