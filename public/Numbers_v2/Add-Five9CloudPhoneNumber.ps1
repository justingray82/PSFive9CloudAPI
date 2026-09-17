function Add-Five9CloudPhoneNumber {

    [CmdletBinding(DefaultParameterSetName = 'AreaCode')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'AreaCode')][string[]]$AreaCode,
        [Parameter(Mandatory, ParameterSetName = 'Random')][switch]$Random,
        [ValidateRange(1, 1000)][int]$Quantity = 1,            # per area code
        [ValidateSet('DID', 'TFN')][string]$NumberType = 'DID',
        [string]$Country = 'US',
        [switch]$NoWait,                                       # return the bulkClaimId instead of polling
        [int]$TimeoutSeconds = 120
    )

    # Build claims
    $claims = @()
    if ($PSCmdlet.ParameterSetName -eq 'Random') {
        $claims += @{ claimType = 'RANDOM'; numberType = $NumberType; quantity = $Quantity }
    }
    else {
        $codes = @($AreaCode | ForEach-Object { $_ -replace '\D', '' } | Where-Object { $_ } | Select-Object -Unique)
        $bad = @($codes | Where-Object { $_ -notmatch '^\d{3}$' })
        if ($bad) { Write-Error "Invalid area code(s): $($bad -join ', '). Expected 3 digits."; return }

        # Inventory pre-check
        $inventory = Get-Five9CloudNumberInventory -AreaCode $codes -NumberType $NumberType -Country $Country
        $short = @($inventory | Where-Object { $_.Available -lt $Quantity })
        if ($short) {
            $detail = ($short | ForEach-Object { "$($.AreaCode) ($($.Available) available)" }) -join ', '
            Write-Error "Not enough inventory for: $detail. Use New-Five9CloudNumberOrder -AreaCode $(($short.AreaCode) -join ',') to request numbers."
            return
        }

        foreach ($code in $codes) {
            $claims += @{ claimType = 'PREFIX'; numberType = $NumberType; prefix = $code; quantity = $Quantity }
        }
    }

    # Credit pre-check (claims decrement <TYPE>_AVAILABLE)
    $totalRequested = $Quantity * $claims.Count
    $credits = Get-Five9CloudNumberCredits
    if ($credits) {
        $creditKey = "$($NumberType)_AVAILABLE"
        $availableCredits = [int]$credits.$creditKey
        if ($totalRequested -gt $availableCredits) {
            Write-Error "Requested $totalRequested $NumberType number(s) but only $availableCredits $NumberType credit(s) are available on the domain."
            return
        }
    }

    # Submit bulk claim
    $body = @{ countryCode = $Country; claims = @($claims) }
    $uri = "$($global:Five9.ApiBaseUrl)/numbers-svc/v1/domains/$($global:Five9.DomainId)/advanced-bulk-claims"
    $submit = Invoke-Five9CloudApi $uri -Method Post -Body $body
    if ($submit -eq $false -or -not $submit.bulkClaimId) { Write-Host "Failed to submit number claim."; return $false }

    $claimId = $submit.bulkClaimId
    if ($NoWait) { Write-Host "Number claim submitted. BulkClaimId: $claimId"; return $claimId }

    # Poll until the claim finishes
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    do {
        Start-Sleep -Seconds 2
        $status = Invoke-Five9CloudApi "$uri/$claimId"
        if ($status -eq $false) { Write-Host "Failed to retrieve claim status for $claimId."; return $false }
    } while ($status.status -in @('RUNNING', 'PENDING', 'QUEUED', 'IN_PROGRESS') -and (Get-Date) -lt $deadline)

    if ($status.status -ne 'COMPLETED') {
        Write-Host "Number claim $claimId ended with status '$($status.status)'."
        if ((Get-Date) -ge $deadline) { Write-Host "Timed out after $TimeoutSeconds seconds; the claim may still complete. Check Get-Five9CloudDomainNumbers." }
        return $false
    }

    $output = foreach ($c in $status.claims) {
        [PSCustomObject]@{
            ClaimType      = $c.claim.claimType
            AreaCode       = $c.claim.prefix
            NumberType     = $c.claim.numberType
            Requested      = [int]$c.claim.quantity
            Available      = [int]$c.claimResult.available
            Claimed        = [int]$c.claimResult.claimed
            Failed         = [int]$c.claimResult.failed
            ClaimedNumbers = @($c.claimResult.claimedNumbers)
            FailureReasons = @($c.claimResult.failureReasons)
        }
    }

    $claimedTotal = ($output | Measure-Object -Property Claimed -Sum).Sum
    if ($claimedTotal -eq $totalRequested) {
        Write-Host "Claimed $claimedTotal number(s): $((@($output.ClaimedNumbers) | Where-Object { $_ }) -join ', ')"
    }
    else {
        Write-Host "Claimed $claimedTotal of $totalRequested requested number(s). Review FailureReasons."
    }
    $output
}