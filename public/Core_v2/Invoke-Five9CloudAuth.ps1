function Invoke-Five9CloudAuth ([string]$Base, [string]$User, [string]$Pass) {
   try {
       $encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${User}:${Pass}"))
       $r = Invoke-RestMethod -Uri "$Base/cloudauthsvcs/v1/admin/login" -Method Post `
           -Headers @{ Authorization = "Basic $encoded"; 'Content-Type' = 'application/json' } `
           -Body '{"grant_type":"client_credentials"}'
       Set-Five9CloudToken $r
       Write-Verbose "Connected to domain $($global:Five9.DomainId)"; return $true
   } catch { Write-Host "Authentication failed. Check the following:`n  * Credentials: Ensure the username and password are correct.`n  * Account status: Ensure the user account is not locked.`n  * Permissions: Ensure the user has access to the Admin Console application.`n  * Region: Specify '-Region ca', '-Region uk', or '-Region eu' if not a US domain.`n  * Environment: Specify '-Environment alpha' if not targeting production." -ForegroundColor Red; return $false }
}