function Resolve-Five9CloudDataTableId ([string]$DataTableId, [string]$DataTableName) {
    if ($DataTableId) { return $DataTableId }
    # data-tables uses its own ordering params (orderByName/orderByDirection), not the standard sort/filter.
    $result = Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "data-tables/v1/domains/$($global:Five9.DomainId)/data-tables" @{ pageLimit = 100; orderByName = 'dataTableName'; orderByDirection = 'ASCENDING' })
    $match  = $result.items | Where-Object { $_.dataTableName -eq $DataTableName }
    if ($match) { return $match.dataTableId }
    Write-Error "Data table '$DataTableName' not found."; return $null
}