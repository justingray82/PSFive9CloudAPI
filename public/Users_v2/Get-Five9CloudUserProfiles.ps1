function Get-Five9CloudUserProfiles {
    param([string]$Sort = 'name', [string]$PageCursor, [int]$PageLimit = 100, [string]$UserProfileId)

    $q = @{}
    if ($Sort)          { $q.sort          = $Sort }
    if ($PageCursor)    { $q.pageCursor    = $PageCursor }
    if ($PageLimit)     { $q.pageLimit     = $PageLimit }
    if ($UserProfileId) { $q.userProfileId = $UserProfileId }

    Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "users/v1/domains/$($global:Five9.DomainId)/user-profiles" $q)
}