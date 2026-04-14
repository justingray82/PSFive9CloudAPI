function Get-Five9CloudCircleAttributeDetails {
    param([string]$circleID, [string]$Circlename, [ValidateSet("users","roles","application-sets","skill-sets","media-type-sets","reason-code-sets")][Parameter(Mandatory)][string]$Scope)
    $circleID = Resolve-Five9CloudCircleID $Circlename; if (-not $circleID) { return }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/circles/v1/domains/$($global:Five9.DomainId)/circles/$circleID/$Scope"
    $result.items.name
}