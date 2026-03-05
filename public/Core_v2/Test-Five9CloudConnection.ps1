function Test-Five9CloudConnection ([switch]$AutoReconnect) {
   if (-not $global:Five9.AccessToken) {
       Write-Warning "Not connected. Run Connect-Five9Cloud first."; return $false
   }
   if ((Get-Date) -lt $global:Five9.ExpiresAt) { return $true }

   if (-not $AutoReconnect) {
       Write-Warning "Token expired. Run Connect-Five9Cloud or pass -AutoReconnect."; return $false
   }

   Write-Verbose "Token expired — reconnecting..."
   $p = $global:Five9.AuthParams
   $ok = if ($global:Five9.AuthType -eq 'OAuth') {
       Invoke-Five9CloudOAuth $p.Base $p.ClientId $p.ClientSecret
   } else {
       Invoke-Five9CloudAuth $p.Base $p.Username $p.Password
   }
   if (-not $ok) { Write-Error "Auto-reconnect failed." }
   return $ok
}