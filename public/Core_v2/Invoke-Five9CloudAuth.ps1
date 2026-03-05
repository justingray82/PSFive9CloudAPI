function Invoke-Five9CloudAuth ([string]$Base, [string]$User, [string]$Pass) {
   try {
       $encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${User}:${Pass}"))
       $r = Invoke-RestMethod -Uri "$Base/cloudauthsvcs/v1/admin/login" -Method Post `
           -Headers @{ Authorization = "Basic $encoded"; 'Content-Type' = 'application/json' } `
           -Body '{"grant_type":"client_credentials"}'
       Set-Five9CloudToken $r
       Write-Verbose "Connected to domain $($global:Five9.DomainId)"
   } catch { Write-Error "CloudAuth failed: $_"; return $false }
}