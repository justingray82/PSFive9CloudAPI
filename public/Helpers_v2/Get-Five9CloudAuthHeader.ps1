function Get-Five9CloudAuthHeader {
   @{ Authorization = "Bearer $($global:Five9.AccessToken)"; 'Content-Type' = 'application/json' }
}