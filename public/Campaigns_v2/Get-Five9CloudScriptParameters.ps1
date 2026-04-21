function Get-Five9CloudScriptParameters {
    param([string]$ScriptId, [string]$ScriptName)
    if (-not $ScriptId) { $ScriptId = Resolve-Five9CloudScriptId $ScriptName } ; if (-not $ScriptId) { return }
    Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/scripts/$ScriptId/parameters"
}
