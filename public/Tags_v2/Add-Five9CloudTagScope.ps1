function Add-Five9CloudTagScope {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('user','campaign','skill','data-table','agent-group','speed-dial','phone-number','permission')]
        [string]$Scope
    )

    DynamicParam {
        function New-DynParam ([string]$Name, [type]$Type = [string]) {
            $attrs = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
            $attrs.Add([System.Management.Automation.ParameterAttribute]::new())
            [System.Management.Automation.RuntimeDefinedParameter]::new($Name, $Type, $attrs)
        }

        $dict = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

        # Tag identity - required for every scope
        $dict.Add('TagId',   (New-DynParam 'TagId'))
        $dict.Add('TagName', (New-DynParam 'TagName'))

        switch ($PSBoundParameters['Scope']) {
            'user'         { $dict.Add('Username',       (New-DynParam 'Username'));       $dict.Add('UserUID',       (New-DynParam 'UserUID')) }
            'campaign'     { $dict.Add('CampaignName',   (New-DynParam 'CampaignName'));   $dict.Add('CampaignId',    (New-DynParam 'CampaignId')) }
            'skill'        { $dict.Add('SkillName',      (New-DynParam 'SkillName'));      $dict.Add('SkillId',       (New-DynParam 'SkillId')) }
            'data-table'   { $dict.Add('DataTableName',  (New-DynParam 'DataTableName'));  $dict.Add('DataTableId',   (New-DynParam 'DataTableId')) }
            'agent-group'  { $dict.Add('AgentGroupName', (New-DynParam 'AgentGroupName')); $dict.Add('AgentGroupId',  (New-DynParam 'AgentGroupId')) }
            'speed-dial'   { $dict.Add('SpeedDialCode',  (New-DynParam 'SpeedDialCode'));  $dict.Add('SpeedDialId',   (New-DynParam 'SpeedDialId')) }
            'phone-number' { $dict.Add('PhoneNumber',    (New-DynParam 'PhoneNumber'));    $dict.Add('PhoneNumberId', (New-DynParam 'PhoneNumberId')) }
            'permission'   { $dict.Add('Username',       (New-DynParam 'Username'));       $dict.Add('UserUID',       (New-DynParam 'UserUID')) }
        }

        return $dict
    }

    end {
        # Pull dynamic values into locals
        $TagId   = $PSBoundParameters['TagId']
        $TagName = $PSBoundParameters['TagName']

        # Resolve the tag (TagId is HAR-confirmed; TagName resolution is inferred - see Resolve-Five9CloudTagId)
        if (-not $TagId) { $TagId = Resolve-Five9CloudDomainTag -TagName $TagName } ; if (-not $TagId) { return }

        # Resolve the scope's resource id and build the scope-specific URI.
        # Observed tag-association POSTs carry no meaningful body, so an empty POST is used.
        switch ($Scope) {
            'user' {
                $Username = $PSBoundParameters['Username']; $UserUID = $PSBoundParameters['UserUID']
                if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }
                $label = if ($Username) { $Username } else { $UserUID }
                $uri   = "$($global:Five9.ApiBaseUrl)/users/v1/domains/$($global:Five9.DomainId)/users/$UserUID/tags/$TagId"
            }
            'campaign' {
                $CampaignName = $PSBoundParameters['CampaignName']; $CampaignId = $PSBoundParameters['CampaignId']
                if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
                $label = if ($CampaignName) { $CampaignName } else { $CampaignId }
                $uri   = "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/tags/$TagId"
            }
            'skill' {
                $SkillName = $PSBoundParameters['SkillName']; $SkillId = $PSBoundParameters['SkillId']
                $SkillId = Resolve-Five9CloudSkillId $SkillId $SkillName ; if (-not $SkillId) { return }
                $label = if ($SkillName) { $SkillName } else { $SkillId }
                $uri   = "$($global:Five9.ApiBaseUrl)/skills/v1/domains/$($global:Five9.DomainId)/skills/$SkillId/tags/$TagId"
            }
            'data-table' {
                $DataTableName = $PSBoundParameters['DataTableName']; $DataTableId = $PSBoundParameters['DataTableId']
                $DataTableId = Resolve-Five9CloudDataTableId $DataTableId $DataTableName ; if (-not $DataTableId) { return }
                $label = if ($DataTableName) { $DataTableName } else { $DataTableId }
                $uri   = "$($global:Five9.ApiBaseUrl)/data-tables/v1/domains/$($global:Five9.DomainId)/data-tables/$DataTableId/tags/$TagId"
            }
            'agent-group' {
                $AgentGroupName = $PSBoundParameters['AgentGroupName']; $AgentGroupId = $PSBoundParameters['AgentGroupId']
                $AgentGroupId = Resolve-Five9CloudAgentGroupId $AgentGroupId $AgentGroupName ; if (-not $AgentGroupId) { return }
                $label = if ($AgentGroupName) { $AgentGroupName } else { $AgentGroupId }
                $uri   = "$($global:Five9.ApiBaseUrl)/agent-groups/v1/domains/$($global:Five9.DomainId)/agent-groups/$AgentGroupId/tags/$TagId"
            }
            'speed-dial' {
                $SpeedDialCode = $PSBoundParameters['SpeedDialCode']; $SpeedDialId = $PSBoundParameters['SpeedDialId']
                $SpeedDialId = Resolve-Five9CloudSpeedDialId $SpeedDialId $SpeedDialCode ; if (-not $SpeedDialId) { return }
                $label = if ($SpeedDialCode) { $SpeedDialCode } else { $SpeedDialId }
                $uri   = "$($global:Five9.ApiBaseUrl)/users/v1/domains/$($global:Five9.DomainId)/speed-dials/$SpeedDialId/tags/$TagId"
            }
            'phone-number' {
                $PhoneNumber = $PSBoundParameters['PhoneNumber']; $PhoneNumberId = $PSBoundParameters['PhoneNumberId']
                $PhoneNumberId = Resolve-Five9CloudPhoneNumberId $PhoneNumberId $PhoneNumber ; if (-not $PhoneNumberId) { return }
                $label = if ($PhoneNumber) { $PhoneNumber } else { $PhoneNumberId }
                $uri   = "$($global:Five9.ApiBaseUrl)/numbers/v1/domains/$($global:Five9.DomainId)/phone-numbers/$PhoneNumberId/tags/$TagId"
            }
            'permission' {
                # Grants the user's permissions scope over the tag (ACL service), not a tag on the user record itself.
                # HAR-confirmed: POST /acl/v1/domains/{domainId}/users/{userUID}/tags/{tagId} -> 204
                $Username = $PSBoundParameters['Username']; $UserUID = $PSBoundParameters['UserUID']
                if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } ; if (-not $UserUID) { return }
                $label = if ($Username) { $Username } else { $UserUID }
                $uri   = "$($global:Five9.ApiBaseUrl)/acl/v1/domains/$($global:Five9.DomainId)/users/$UserUID/tags/$TagId"
            }
        }

        $result = Invoke-Five9CloudApi $uri -Method Post
        if ($result -ne $false) { Write-Host "Tag $TagId added to $Scope '$label'." } else { Write-Host "Failed to add tag $TagId to $Scope '$label'." }
    }
}