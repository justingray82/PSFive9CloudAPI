function Set-Five9CloudQueryUri ([string]$BasePath, [hashtable]$Params) {
   $base = "$($global:Five9.ApiBaseUrl)/$BasePath"
   $qs = foreach ($k in $Params.Keys) {
       if ($null -ne $Params[$k] -and $Params[$k] -ne '') {
           "$k=$([Uri]::EscapeDataString($Params[$k]))"
       }
   }
   if ($qs) { "$base`?$($qs -join '&')" } else { $base }
}