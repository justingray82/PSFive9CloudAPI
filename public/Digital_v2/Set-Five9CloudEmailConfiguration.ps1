function Set-Five9CloudEmailConfiguration {
    param(
        [string]$EmailConfigurationId,
        [string]$Email,                                    # lookup key - resolves the ID, not changed (use -NewEmail)
        [ValidateSet('INBOUND','OUTBOUND')][string]$Type,  # lookup disambiguator - an address usually has both

        # Connection
        [string]$NewEmail,
        [ValidateSet('IMAP','IMAPS','POP3','POP3S','EXCHANGE','EXCHANGE_WEBMAIL','GRAPH','SMTP')][string]$Protocol,
        [string]$ServerHost,                               # not -Host: $Host is a PowerShell automatic variable
        [int]$Port,
        [int]$Timeout,
        [int]$ConnectionTimeout,
        [bool]$CheckServerIdentity,

        # Processing
        [bool]$SaveProcessedEmail,
        [bool]$ReplyToHeaders,
        [bool]$AutoPushbackEmail,
        [bool]$AutoPushback4LoggedinUsers,
        [int]$AutoPushbackInterval,

        # Authentication - passing either switches auth to OAUTH2CLIENTCREDENTIALS
        [string]$ServiceAccountId,
        [string]$ServiceAccountName
    )

    if (-not $EmailConfigurationId) { $EmailConfigurationId = Resolve-Five9CloudEmailConfigurationId -Email $Email -Type $Type } ; if (-not $EmailConfigurationId) { return }

    $baseUri = "$($global:Five9.ApiBaseUrl)/digital-config-svc/v1/domains/$($global:Five9.DomainId)"

    # GET current state - the PUT takes the whole configuration, not a partial.
    $current = Invoke-Five9CloudApi "$baseUri/email-configurations/$EmailConfigurationId"
    if (-not $current) { return }
    $config = if ($current.PSObject.Properties.Name -contains 'items') { $current.items[0] } else { $current }
    if (-not $config) { Write-Error "Email configuration '$EmailConfigurationId' not found."; return }

    # PSCustomObject -> mutable hashtable (null fields on the object are read-only).
    $body = @{}
    $config.PSObject.Properties | ForEach-Object { $body[$_.Name] = $_.Value }

    # Server-managed fields - returned by GET, never sent by the admin console PUT.
    foreach ($f in 'emailConfigurationId','status','createdOn','lastActiveOn','timeout','connectionTimeout','replyToHeaders','autoPushbackInterval') { $body.Remove($f) }

    # Authentication: 'key' is server-generated from the service account; the PUT omits it.
    $auth = @{}
    if ($config.authentication) { $config.authentication.PSObject.Properties | ForEach-Object { $auth[$_.Name] = $_.Value } }
    $auth.Remove('key')

    # Apply only explicitly passed parameters.
    $fieldMap = [ordered]@{
        NewEmail                   = 'email'
        Protocol                   = 'protocol'
        ServerHost                 = 'host'
        Port                       = 'port'
#        Timeout                    = 'timeout'
#        ConnectionTimeout          = 'connectionTimeout'
        CheckServerIdentity        = 'checkServerIdentity'
        SaveProcessedEmail         = 'saveProcessedEmail'
#        ReplyToHeaders             = 'replyToHeaders'
        AutoPushbackEmail          = 'autoPushbackEmail'
        AutoPushback4LoggedinUsers = 'autoPushback4LoggedinUsers'
#        AutoPushbackInterval       = 'autoPushbackInterval'
    }
    foreach ($p in $fieldMap.Keys) {
        if ($PSBoundParameters.ContainsKey($p)) { $body[$fieldMap[$p]] = $PSBoundParameters[$p] }
    }

    # Service account (ID passthrough skips the lookup).
    if (-not $ServiceAccountId -and $PSBoundParameters.ContainsKey('ServiceAccountName')) {
        $ServiceAccountId = Resolve-Five9CloudServiceAccountId $ServiceAccountName ; if (-not $ServiceAccountId) { return }
    }
    if ($ServiceAccountId) { $auth = @{ type = 'OAUTH2CLIENTCREDENTIALS'; serviceAccountId = $ServiceAccountId } }

    # Protocol / auth changes: check against the mail-server catalog. The console swaps
    # the host when the protocol changes (EXCHANGE uses the EWS URL, GRAPH a bare host),
    # so do the same unless -ServerHost was given.
    $protocolChanged = $PSBoundParameters.ContainsKey('Protocol') -and $Protocol -ne $config.protocol
    if ($protocolChanged -or $ServiceAccountId) {
        $servers  = Invoke-Five9CloudApi "$baseUri/mail-servers"
        $provider = @($servers.items | Where-Object { $_.protocols.protocolHost -contains $config.host })
        if ($provider.Count -gt 0) {
            # A provider can be split across entries (Office 365 lists SMTP separately), so match by name.
            $names  = $provider.name | Select-Object -Unique
            $target = $servers.items | Where-Object { $names -contains $_.name } |
                      ForEach-Object { $_.protocols } |
                      Where-Object { $_.protocolType -eq $body.protocol } | Select-Object -First 1
            if (-not $target) { Write-Error "Protocol '$($body.protocol)' is not offered for $($names -join '/')."; return }
            if ($protocolChanged -and -not $PSBoundParameters.ContainsKey('ServerHost')) { $body.host = $target.protocolHost }
            if ($auth.type -and ($target.authenticationConfigurations.authenticationType -notcontains $auth.type)) {
                Write-Error "Authentication '$($auth.type)' is not supported for $($body.protocol). Supported: $($target.authenticationConfigurations.authenticationType -join ', ')."
                return
            }
        } elseif ($protocolChanged -and -not $PSBoundParameters.ContainsKey('ServerHost')) {
            Write-Warning "Host '$($config.host)' isn't in the mail-server catalog - host left unchanged. Pass -ServerHost if the new protocol needs a different one."
        }
    }

    if ($auth.Count -gt 0) { $body.authentication = $auth } else { $body.Remove('authentication') }

    # EWS/Graph report port 0; the console leaves it out of the PUT.
    if ($body.port -eq 0) { $body.Remove('port') }

    $label  = "$($body.email) ($($body.type))"
    $result = Invoke-Five9CloudApi "$baseUri/email-configurations/$EmailConfigurationId" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Email configuration '$label' updated successfully." } else { Write-Host "Failed to update email configuration '$label'." }
}