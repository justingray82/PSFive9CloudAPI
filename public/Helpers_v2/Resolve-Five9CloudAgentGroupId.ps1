function Resolve-Five9CloudAgentGroupId ([string]$AgentGroupId, [string]$AgentGroupName) {
    if ($AgentGroupId) { return $AgentGroupId }
    # NOTE: list item exposes the id as 'groupId'; the tag-association URL segment is /agent-groups/{groupId}.
    $result = Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "agent-groups/v1/domains/$($global:Five9.DomainId)/agent-groups" @{})
    $match  = $result.items | Where-Object { $_.name -eq $AgentGroupName }
    if ($match) { return $match.groupId }
    Write-Error "Agent group '$AgentGroupName' not found."; return $null
}