function Add-Five9CloudAniGroupNumber {
    param([string]$AniGroupId, [string]$AniGroupName,
          [Parameter(Mandatory)][string]$Ani,
          [string]$AreaCode,
          [switch]$NoNormalize)

    if (-not $AniGroupId) { $AniGroupId = Resolve-Five9CloudAniGroupId $AniGroupName } ; if (-not $AniGroupId) { return }

    if (-not $NoNormalize) {
        $cleanAni = $Ani -replace '\D', ''
        $cleanAni = "1$cleanAni" -replace '^1{2,}', '1'
        $Ani = "+$cleanAni"
    
        if ($AreaCode) {
            $cleanArea = $AreaCode -replace '\D', ''
            $cleanArea = "1$cleanArea" -replace '^1{2,}', '1'
            $AreaCode = "+$cleanArea"
        }
    }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/routes/v1/domains/$($global:Five9.DomainId)/ani-groups/$AniGroupId/prefixes/$AreaCode/anis/$Ani" -Method Post
    if ($result -ne $false) { Write-Host "ANI $Ani added to ANI group '$AniGroupName'."; return $result } else { Write-Host "Failed to add ANI $Ani to ANI group '$AniGroupName'."; return $false }
}