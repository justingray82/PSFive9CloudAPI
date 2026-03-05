function Connect-Five9Cloud {
   [CmdletBinding(DefaultParameterSetName = 'CloudAuth')]
   param(
       [Parameter(Mandatory)][string]$DomainId,
       [ValidateSet('us','uk','eu','ca')][string]$Region = 'us',
       [ValidateSet('prod','alpha')][string]$Environment = 'prod',

       [Parameter(ParameterSetName = 'CloudAuth')][string]$Username,
       [Parameter(ParameterSetName = 'CloudAuth')][string]$Password,

       [Parameter(ParameterSetName = 'OAuth', Mandatory)][string]$ClientId,
       [Parameter(ParameterSetName = 'OAuth', Mandatory)][string]$ClientSecret
   )

   $global:Five9 = @{ AccessToken = $null; ExpiresAt = $null; DomainId = $null; ApiBaseUrl = $null; AuthType = $null; AuthParams = @{} }

   $base = "https://api.$Environment.$Region.five9.net"
   $global:Five9.DomainId = $DomainId
   $global:Five9.ApiBaseUrl = $base
   $global:Five9.AuthType  = $PSCmdlet.ParameterSetName

   if ($PSCmdlet.ParameterSetName -eq 'OAuth') {
       $global:Five9.AuthParams = @{ ClientId = $ClientId; ClientSecret = $ClientSecret; Base = $base }
       Invoke-Five9OAuth $base $ClientId $ClientSecret
   }

   # CloudAuth
   if (-not $Username) { $Username = Read-Host 'Username' }
   if (-not $Password) { $Password = Read-Host 'Password' }
   $global:Five9.AuthParams = @{ Username = $Username; Password = $Password; Base = $base }
   Invoke-Five9CloudAuth $base $Username $Password
}