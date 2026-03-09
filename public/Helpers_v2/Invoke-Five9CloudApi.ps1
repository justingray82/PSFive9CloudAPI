function Invoke-Five9CloudApi ([string]$Uri, [string]$Method = 'Get', $Body) {
   if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
   $splat = @{ Uri = $Uri; Method = $Method; Headers = (Get-Five9CloudAuthHeader) }
   if ($Body) { $splat.Body = ($Body | ConvertTo-Json -Depth 10) }
   try { Invoke-RestMethod @splat }
   catch { Write-Host "API call failed [$Method $Uri]: $_"; return $false }
   Start-Sleep -Milliseconds 250
}