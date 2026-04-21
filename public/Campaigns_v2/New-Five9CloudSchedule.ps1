function New-Five9CloudSchedule {
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Description,
        [Parameter(Mandatory)][string]$DefaultScriptId,
        [Parameter(Mandatory)][hashtable]$Action,
        [hashtable[]]$Events,
        [hashtable[]]$ScriptParameters
    )
    $body = @{
        name          = $Name
        defaultScript = @{ ewScriptId = $DefaultScriptId }
        action        = $Action
    }
    if ($Description)      { $body.description      = $Description }
    if ($Events)           { $body.events            = $Events }
    if ($ScriptParameters) { $body.scriptParameters  = $ScriptParameters }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/schedules" -Method Post -Body $body
    if ($result -ne $false) { Write-Host "Schedule '$Name' created successfully."; return $result } else { Write-Host "Failed to create schedule '$Name'."; return $false }
}
