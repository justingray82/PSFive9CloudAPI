function Resolve-Five9CloudScriptId ([string]$ScriptName) {
    $result = Get-Five9CloudScripts -Filter "name=='$ScriptName'" -Fields 'id,name'
    if ($result.items.Count -gt 0) { return $result.items.id }
    Write-Host "Script '$ScriptName' not found." -ForegroundColor Red; return $null
}
