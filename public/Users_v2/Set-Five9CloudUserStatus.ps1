function Set-Five9CloudUserStatus {
    param(
        [string[]]$Username,
        [string[]]$UserUID,
        [Parameter(Mandatory)][ValidateSet('Activate', 'Deactivate')][string]$Action
    )


    if (-not $Username -and -not $UserUID) { Write-Error "Specify -Username or -UserUID."; return }


    $verb = $Action.ToLower()   # endpoint suffix: :activate / :deactivate


    # Build a list of UID/label pairs so name and ID input share one code path
    $targets = @()
    foreach ($u in $UserUID)  { $targets += @{ UID = $u; Label = $u } }
    foreach ($n in $Username) {
        $uid = Resolve-Five9CloudUserUID $n
        if ($uid) { $targets += @{ UID = $uid; Label = $n } }
    }


    foreach ($t in $targets) {
        # 204 No Content on success — $null result passes the -ne $false check
        $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/users/v1/domains/$($global:Five9.DomainId)/users/$($t.UID):$verb" -Method Put
        if ($result -ne $false) { Write-Host "$Action request submitted for '$($t.Label)'." }
        else { Write-Host "Failed to $verb '$($t.Label)'." -ForegroundColor Red }
    }
}