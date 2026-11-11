# Function templates for PSFive9CloudAPI. One function per file; file name = function name.
# Windows PowerShell 5.1 syntax. Replace 'Example', <service>, <path>, and field names
# with what the HAR capture shows.

# ---------------------------------------------------------------- GET (paged list)
function Get-Five9CloudExampleList {
    param([string]$Fields, [string]$Sort, [string]$PageCursor, [int]$PageLimit = 100, [string]$Filter)

    $q = @{}
    if ($Fields)     { $q.fields     = $Fields }
    if ($Sort)       { $q.sort       = $Sort }
    if ($PageCursor) { $q.pageCursor = $PageCursor }
    if ($PageLimit)  { $q.pageLimit  = $PageLimit }
    if ($Filter)     { $q.filter     = $Filter }

    Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "<service>/v1/domains/$($global:Five9.DomainId)/<path>" $q)
}

# ---------------------------------------------------------------- Resolver (name or ID)
function Resolve-Five9CloudExampleId ([string]$ExampleId, [string]$ExampleName) {
    if ($ExampleId) { return $ExampleId }                     # ID passthrough skips the lookup
    $result = Get-Five9CloudExampleList -Filter "name=='$ExampleName'"
    $match  = @($result.items) | Where-Object { $_.name -eq $ExampleName } | Select-Object -First 1
    if ($match) { return $match.id }
    Write-Host "Example '$ExampleName' not found." -ForegroundColor Red; return $null
}

# ---------------------------------------------------------------- GET-then-PUT update
function Set-Five9CloudExample {
    param(
        [string]$ExampleId,
        [string]$ExampleName,
        [string]$Description,
        [bool]$Enabled                                        # [bool], not [switch], so callers can pass $false
    )

    if (-not $ExampleId) { $ExampleId = Resolve-Five9CloudExampleId $ExampleId $ExampleName } ; if (-not $ExampleId) { return }
    $uri = "$($global:Five9.ApiBaseUrl)/<service>/v1/domains/$($global:Five9.DomainId)/<path>/$ExampleId"

    # 1. GET the full object (PUT requires all of it)
    $current = Invoke-Five9CloudApi $uri
    if (-not $current) { return }
    $obj = if ($current.PSObject.Properties.Name -contains 'items') { $current.items[0] } else { $current }

    # 2. Convert to a mutable hashtable (null fields on PSCustomObject are read-only)
    $body = @{}
    foreach ($p in $obj.PSObject.Properties) { $body[$p.Name] = $p.Value }

    # 3. Apply only what the caller passed
    if ($PSBoundParameters.ContainsKey('Description')) { $body.description = $Description }
    if ($PSBoundParameters.ContainsKey('Enabled'))     { $body.enabled     = $Enabled }

    # 4. Strip read-only fields the PUT rejects (confirm the list from the HAR)
    foreach ($ro in @('id','createdAt','updatedAt')) { $body.Remove($ro) }

    # 5. PUT
    $result = Invoke-Five9CloudApi $uri -Method Put -Body $body
    $label  = if ($ExampleName) { $ExampleName } else { $ExampleId }
    if ($result -ne $false) { Write-Host "Example '$label' updated."; return $result }
    else { Write-Host "Failed to update Example '$label'."; return $false }
}
