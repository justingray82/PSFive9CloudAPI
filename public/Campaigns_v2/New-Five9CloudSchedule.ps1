function New-Five9CloudSchedule {
    [CmdletBinding(DefaultParameterSetName = 'EwScript')]
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Description,
        [Parameter(Mandatory)][string]$DefaultScriptId,

        # ── Action: EW_SCRIPT (default) ─────────────────────────────────────────
        [Parameter(Mandatory, ParameterSetName = 'EwScript')]
        [string]$ActionScriptId,

        # ── Action: FORWARD_TO ──────────────────────────────────────────────────
        [Parameter(Mandatory, ParameterSetName = 'ForwardTo')]
        [string]$ActionDestination,

        # ── Action: REJECT ──────────────────────────────────────────────────────
        [Parameter(Mandatory, ParameterSetName = 'Reject')]
        [switch]$ActionReject,

        # ── Events & script params ───────────────────────────────────────────────
        [pscustomobject[]]$Events,
        [string[]]$ScriptParameterNames,
        [string[]]$ScriptParameterValues
    )

    $action = switch ($PSCmdlet.ParameterSetName) {
        'EwScript'  { @{ type = 'EW_SCRIPT';  ewScriptId  = $ActionScriptId } }
        'ForwardTo' { @{ type = 'FORWARD_TO'; destination = $ActionDestination } }
        'Reject'    { @{ type = 'REJECT' } }
    }

    $body = @{
        name          = $Name
        defaultScript = @{ ewScriptId = $DefaultScriptId }
        action        = $action
    }
    if ($Description) { $body.description = $Description }
    if ($Events)      { $body.events       = $Events }

    if ($ScriptParameterNames -and $ScriptParameterValues) {
        if ($ScriptParameterNames.Count -ne $ScriptParameterValues.Count) {
            Write-Error "ScriptParameterNames and ScriptParameterValues must have the same number of elements."; return
        }
        $body.scriptParameters = @(for ($i = 0; $i -lt $ScriptParameterNames.Count; $i++) {
            @{ name = $ScriptParameterNames[$i]; value = $ScriptParameterValues[$i] }
        })
    }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/schedules" -Method Post -Body $body
    if ($result -ne $false) { Write-Host "Schedule '$Name' created successfully."; return $result } else { Write-Host "Failed to create schedule '$Name'."; return $false }
}
