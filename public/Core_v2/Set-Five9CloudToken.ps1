function Set-Five9CloudToken ($Response) {
   $global:Five9.AccessToken = $Response.access_token
   $global:Five9.ExpiresAt  = (Get-Date).AddSeconds($Response.expires_in - 60)
}