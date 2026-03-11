function Get-Five9CloudIdpPolicyDetails {
   param([string]$Sort, [long]$Offset, [long]$Limit,
         [string]$PageCursor, [string]$Filter)

   $q = @{}
   if ($Sort)      { $q.sort      = $Sort }
   if ($PSBoundParameters.ContainsKey('Offset')) { $q.offset = $Offset }
   if ($PSBoundParameters.ContainsKey('Limit')) { $q.limit = $Limit }
   if ($PageCursor) { $q.pageCursor = $PageCursor }
   if ($Filter)    { $q.filter    = $Filter }

   Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "users/v1/domains/$($global:Five9.DomainId)/idp-policies?includeOrgPolicies=true&fields=idp-certificates&pageLimit=100" $q)
}