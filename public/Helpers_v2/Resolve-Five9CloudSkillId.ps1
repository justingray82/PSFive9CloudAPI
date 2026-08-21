function Resolve-Five9CloudSkillId ([string]$SkillId, [string]$SkillName) {
    if ($SkillId) { return $SkillId }
    $result = Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "skills/v1/domains/$($global:Five9.DomainId)/skills" @{ sort = 'name'; pageLimit = 1000 })
    $match  = $result.items | Where-Object { $_.name -eq $SkillName }
    if ($match) { return $match.skillId }
    Write-Error "Skill '$SkillName' not found."; return $null
}