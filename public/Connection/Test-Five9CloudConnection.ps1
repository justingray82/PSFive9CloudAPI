function Test-Five9CloudConnection {
    <#
    .SYNOPSIS
    Validates the Five9 Cloud connection and ensures the access token is still valid.

    .DESCRIPTION
    This function checks that $global:Five9CloudToken exists and that the token has not expired
    based on the ExpiresIn value returned at authentication.

    .OUTPUTS
    [bool] True if valid, otherwise throws a terminating error.

    .EXAMPLE
    Test-Five9CloudConnection
    # Returns true if the connection is valid
    # Throws an error if the token is expired or not initialized
    #>
    
    if (-not $global:Five9CloudToken) {
        Write-Host "You must connect first using Connect-Five9Cloud."
        return
    }

    # Ensure the token has an expiration timestamp
    if (-not $global:Five9CloudToken.ExpiresAt) {
        Write-Host "Your session token is missing an expiration timestamp. Please reconnect using Connect-Five9Cloud."
        return
    }

    # Check if the token is expired
    $now = Get-Date
    if ($now -ge $global:Five9CloudToken.ExpiresAt) {
        Write-Host "Your Five9 Cloud session token has expired. Please reconnect using Connect-Five9Cloud."
        return
    }

    return $true
}
