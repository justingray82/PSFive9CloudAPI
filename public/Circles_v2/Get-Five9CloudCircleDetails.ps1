function Get-Five9CloudCircleDetails {
   param([string]$Fields, [string]$Sort, [long]$Offset, [long]$Limit,
         [string]$PageCursor, [int]$PageLimit, [string]$Filter)

   $q = @{}
   if ($Fields)    { $q.fields    = $Fields }
   if ($Sort)      { $q.sort      = $Sort }
   if ($PSBoundParameters.ContainsKey('Offset')) { $q.offset = $Offset }
   if ($PSBoundParameters.ContainsKey('Limit')) { $q.limit = $Limit }
   if ($PageCursor) { $q.pageCursor = $PageCursor }
   if ($PageLimit) { $q.pageLimit = $PageLimit }
   if ($Filter)    { $q.filter    = $Filter }

   Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "circles/v1/domains/$($global:Five9.DomainId)/circles" $q)
}