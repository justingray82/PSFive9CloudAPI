function Get-Five9CloudSkillUsers {
    param([string]$SkillId, [string]$SkillName,
          [string]$Sort, [string]$PageCursor, [int]$PageLimit = 100, [string]$Filter)
    if (-not $SkillId) { $SkillId = Resolve-Five9CloudSkillId $SkillId $SkillName } ; if (-not $SkillId) { return }


    $q = @{}
    if ($Sort)       { $q.sort       = $Sort }
    if ($PageCursor) { $q.pageCursor = $PageCursor }
    if ($PageLimit)  { $q.pageLimit  = $PageLimit }
    if ($Filter)     { $q.filter     = $Filter }


    $result = Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "skills/v1/domains/$($global:Five9.DomainId)/skills/$SkillId/users" $q)
    $assignments = foreach ($page in $result) { foreach ($item in $page.items) { $item } }
    if (-not $assignments) { Write-Host "No users assigned to skill '$SkillId'." -ForegroundColor Yellow; return }


    # Skill assignments only carry userUID + level; look up user details in batches of 50 (same as Admin Console).
    # Built by hand so the commas stay literal - Set-Five9CloudQueryUri would encode them to %2C and the API returns no matches.
    $userIds = @($assignments | ForEach-Object { $_.user.userUID } | Select-Object -Unique)
    $users   = @{}
    for ($i = 0; $i -lt $userIds.Count; $i += 50) {
        $batch = $userIds[$i..([Math]::Min($i + 49, $userIds.Count - 1))] -join ','
        $uri   = "$($global:Five9.ApiBaseUrl)/users/v1/domains/$($global:Five9.DomainId)/users?userUID=$batch&pageLimit=100"
        $resp  = Invoke-Five9CloudPagedApi $uri
        foreach ($page in $resp) { foreach ($u in $page.items) { $users[$u.userUID] = $u } }
    }


    foreach ($a in $assignments) {
        $u = $users[$a.user.userUID]
        [PSCustomObject]@{
            Username = if ($u) { $u.username } else { $null }
            Name     = if ($u) { $u.name }     else { $null }
            Email    = if ($u) { $u.email }    else { $null }
            Status   = if ($u) { $u.status }   else { $null }
            Level    = $a.level
            UserUID  = $a.user.userUID
            SkillId  = $a.skill.skillId
        }
    }
}