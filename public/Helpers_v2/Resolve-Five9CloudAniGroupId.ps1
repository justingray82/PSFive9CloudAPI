function Resolve-Five9CloudAniGroupId ([string]$AniGroupName) {
    $result = Get-Five9CloudAniGroups
    $filteredResult = $result | ? { $_.name -eq "$($AniGroupName)" }
    if ($filteredResult.name -ne $null) { return $filteredResult.aniGroup.aniGroupId }
    Write-Host "ANI group '$AniGroupName' not found." -ForegroundColor Red; return $null
}