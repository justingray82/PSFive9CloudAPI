function Invoke-Five9CloudPagedApi ([string]$Uri,[hashtable]$Params = @{},[string]$ResultProperty) {
    $allItems = [System.Collections.Generic.List[object]]::new()
    
    do {
        $response = Invoke-Five9CloudApi -Uri $Uri -Method 'Get'

        if (-not $response) { break }

        # Add results — use ResultProperty if specified, otherwise treat response as the collection
        $page = if ($ResultProperty) { $response.$ResultProperty } else { $response }
        if ($page) { $allItems.AddRange([object[]]$page) }

        # Advance to next page URI, or stop
        if ($response.paging.next -ne $null) { $uri = (Set-Five9CloudQueryUri $response.paging.next.TrimStart('/')) }

    } while ($response.paging.next -ne $null)

    return $allItems
}