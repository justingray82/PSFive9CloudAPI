function Invoke-Five9OAuth ([string]$Base, [string]$Id, [string]$Secret) {
   try {
       $r = Invoke-RestMethod -Uri "$Base/oauth2/v1/token" -Method Post `
           -ContentType 'application/x-www-form-urlencoded' `
           -Body @{ grant_type = 'client_credentials'; client_id = $Id; client_secret = $Secret; scope = 'api' }
       Set-Five9Token $r
       Write-Verbose "Connected to domain $($global:Five9.DomainId) (OAuth)"
   } catch { Write-Error "OAuth failed: $_"; return $false }
}