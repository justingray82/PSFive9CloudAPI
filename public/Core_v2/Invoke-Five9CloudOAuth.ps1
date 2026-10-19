function Invoke-Five9CloudOAuth ([string]$Base, [string]$Id, [string]$Secret) {
   try {
       $encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${Id}:${Secret}"))
       $r = Invoke-RestMethod -Uri "$Base/oauth2/v1/token" -Method Post -Headers @{ Authorization = "Basic $encoded" } -ContentType 'application/x-www-form-urlencoded' -Body 'grant_type=client_credentials'
       Set-Five9CloudToken $r
       $claims = Get-Five9CloudJwtClaims $global:Five9.AccessToken
       $global:Five9.DomainId = $claims.domainId
       Write-Verbose "Connected to domain $($global:Five9.DomainId) (OAuth)"
   } catch { Write-Host "OAuth failed" -ForegroundColor Red; return $false }
}