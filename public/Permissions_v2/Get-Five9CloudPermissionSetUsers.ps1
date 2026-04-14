function Get-Five9CloudPermissionSetUsers {
   param([string]$Fields, [string]$Sort, [long]$Offset, [long]$Limit,
         [string]$PageCursor, [int]$PageLimit = 200, [string]$Filter,
         [Parameter(Mandatory = $true)][string]$PermissionSet, [string]$SetID)

   $q = @{}
   if ($Fields)    { $q.fields    = $Fields }
   if ($Sort)      { $q.sort      = $Sort }
   if ($PSBoundParameters.ContainsKey('Offset')) { $q.offset = $Offset }
   if ($PSBoundParameters.ContainsKey('Limit')) { $q.limit = $Limit }
   if ($PageCursor) { $q.pageCursor = $PageCursor }
   if ($PageLimit) { $q.pageLimit = $PageLimit }
   if ($Filter)    { $q.filter    = $Filter }

   if (-not $SetID) { $SetID = Resolve-PermissionSetID $PermissionSet } ; if (-not $SetID) { return }
   Invoke-Five9PagedApi (Build-Five9QueryUri "acl/v1/domains/$($global:Five9.DomainId)/role-sets/$($SetID)/users" $q)

}