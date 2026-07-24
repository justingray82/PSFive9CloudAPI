function Remove-Five9CloudAniGroupNumber {
    param([string]$AniGroupId, [string]$AniGroupName,
          [string]$Ani, [string]$AniId,
          [switch]$NoNormalize)

    if (-not $AniGroupId) { $AniGroupId = Resolve-Five9CloudAniGroupId $AniGroupName } ; if (-not $AniGroupId) { return }
    if (-not $AniId) { $AniId = Resolve-Five9CloudAniId $AniGroupId $Ani } ; if (-not $AniId) { return }

    if (-not $NoNormalize) {
        $cleanAni = $Ani -replace '\D', ''
        $cleanAni = "1$cleanAni" -replace '^1{2,}', '1'
        $Ani = "+$cleanAni"
    }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/routes/v1/domains/$($global:Five9.DomainId)/ani-groups/$AniGroupId/prefixes/$AniId/anis/$Ani" -Method Delete
    if ($result -ne $false) { Write-Host "ANI $Ani removed from ANI group '$AniGroupName'." } else { Write-Host "Failed to remove ANI $Ani from ANI group '$AniGroupName'." }
}