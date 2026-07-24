function Resolve-Five9CloudAniId ([string]$AniGroupId, [string]$Ani) {
    $result = Get-Five9CloudAniGroupNumbers -AniGroupId $AniGroupId
    $filteredResult = $result.items | ? { $_.associatedAni -eq "$($Ani)" }
    if ($filteredResult.prefix -ne $null) { return $filteredResult.prefix }
    Write-Host "ANI prefix for '$Ani' not found." -ForegroundColor Red; return $null
}