function Set-Five9CloudSchedule {
    [CmdletBinding(DefaultParameterSetName = 'EwScript')]
    param(
        [string]$ScheduleId,
        [string]$ScheduleName,
        [string]$Name,
        [string]$Description,
        [string]$DefaultScriptId,

        # ── Action: EW_SCRIPT (default) ─────────────────────────────────────────
        [Parameter(ParameterSetName = 'EwScript')]
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

    if (-not $ScheduleId) { $ScheduleId = Resolve-Five9CloudScheduleId $ScheduleName } ; if (-not $ScheduleId) { return }

    # Seed from current state so PUT doesn't clobber unspecified fields
    $current = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/schedules/$ScheduleId"
    if (-not $current) { return }
    $body = $current

    if ($Name)            { $body.name          = $Name }
    if ($Description)     { $body.description   = $Description }
    if ($DefaultScriptId) { $body.defaultScript = @{ ewScriptId = $DefaultScriptId } }
    if ($Events)          { $body.events         = $Events }

    # Only update action if an action param was provided
    $actionProvided = $PSCmdlet.ParameterSetName -ne 'EwScript' -or $ActionScriptId
    if ($actionProvided) {
        $body.action = switch ($PSCmdlet.ParameterSetName) {
            'EwScript'  { @{ type = 'EW_SCRIPT';  ewScriptId  = $ActionScriptId } }
            'ForwardTo' { @{ type = 'FORWARD_TO'; destination = $ActionDestination } }
            'Reject'    { @{ type = 'REJECT' } }
        }
    }

    if ($ScriptParameterNames -and $ScriptParameterValues) {
        if ($ScriptParameterNames.Count -ne $ScriptParameterValues.Count) {
            Write-Error "ScriptParameterNames and ScriptParameterValues must have the same number of elements."; return
        }
        $body.scriptParameters = @(for ($i = 0; $i -lt $ScriptParameterNames.Count; $i++) {
            @{ name = $ScriptParameterNames[$i]; value = $ScriptParameterValues[$i] }
        })
    }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/schedules/$ScheduleId" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Schedule '$ScheduleName' updated successfully."; return $result } else { Write-Host "Failed to update schedule '$ScheduleName'."; return $false }
}
