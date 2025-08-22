# Five9Cloud PowerShell Module
# Function: Get-Five9CloudQRCodeImage
# Category: UserSettings

function Get-Five9CloudQRCodeImage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$EnrolledFactorId,
        [Parameter(Mandatory = $true)][string]$QrCodeId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/my-factors/mobile/$EnrolledFactorId/qr/$QrCodeId"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
        }
    } catch {
        Write-Error "Failed to get QR code image: $_"
    }
}
