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
   if ($global:Five9.AuthType -eq 'OAuth') {
       $ok = Invoke-Five9CloudOAuth $p.Base $p.ClientId $p.ClientSecret
   } else {
       $ok = Invoke-Five9CloudAuth $p.Base $p.Username $p.Password
   }
   if ($ok -ne $false) { Write-Verbose "Auto-reconnect succeeded."; return $true } else { Write-Host "Auto-reconnect failed." -ForegroundColor Red; return $false  }
}