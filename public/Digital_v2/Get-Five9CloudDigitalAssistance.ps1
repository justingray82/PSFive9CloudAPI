function Get-Five9CloudDigitalAssistance {
    param([string]$Name)
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/digital-config-svc/v1/domains/$($global:Five9.DomainId)/assistances?excludeResponseBody=true"
    if (-not $result) { return }
    if ($Name) { $result.assistances | Where-Object { $_.name -eq $Name } } else { $result.assistances }
}