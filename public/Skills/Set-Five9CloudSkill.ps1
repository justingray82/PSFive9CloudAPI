function Set-Five9CloudSkill {
    [CmdletBinding()]
    param(

        [Parameter(Mandatory = $false)]
        [string]$SkillName,
        
        [Parameter(Mandatory = $false)]
        [string]$Name,
        
        [Parameter(Mandatory = $false)]
        [string]$Description,
        
        [Parameter(Mandatory = $false)]
        [string]$MessageOfTheDay,
        
        [Parameter(Mandatory = $false)]
        [bool]$RouteVoiceMails,
        
        [Parameter(Mandatory = $false)]
        $SkillUserLevels,
        
        [Parameter(Mandatory = $false)]
        $Prompts,

        [Parameter(Mandatory = $false)]
        [string]$WhisperPromptName,
        
        [Parameter(Mandatory = $false)]
        [bool]$OverrideGlobal,
        
        [Parameter(Mandatory = $false)]
        [int]$SpeedOfAnswerSec,
        
        [Parameter(Mandatory = $false)]
        [int]$MinTimeOfResponseSec
    )

    if (-not (Test-Five9CloudConnection -AuthType RestApi)) { return }

    Write-Verbose "Resolving skill name '$SkillName' to skill ID..."
            
    try {
        $domainSkills = Get-Five9CloudSkills -Filter "name=='$($SkillName)'" -Fields "id,name"
            if ($domainSkills.resultsCount -gt 0) {
                $SkillId = $domainSkills.entities[0].id
                Write-Verbose "Found skill with ID: $SkillId"
                }
        } catch {
            Write-Verbose "No skill found with name '$SkillName'"
        }    
    
    $uri = "$($global:Five9CloudToken.RestBaseUrl)/v1/domains/$($global:Five9CloudToken.DomainId)/skills/$skillId"
    
    $headers = @{
        Authorization = "Basic $($global:Five9CloudToken.RestBasicAuth)"
    }
    
    if ($IfMatch) {
        $headers['If-Match'] = $IfMatch
    }
    
    $body = @{}
            
            if ($PSBoundParameters.ContainsKey('Name')) {
                $body['name'] = $Name
            }
            
            if ($PSBoundParameters.ContainsKey('Description')) {
                $body['description'] = $Description
            }
            
            if ($PSBoundParameters.ContainsKey('MessageOfTheDay')) {
                $body['messageOfTheDay'] = $MessageOfTheDay
            }
            
            if ($PSBoundParameters.ContainsKey('RouteVoiceMails')) {
                $body['routeVoiceMails'] = $RouteVoiceMails
            }
            
            # Process SkillUserLevels
            if ($PSBoundParameters.ContainsKey('SkillUserLevels')) {
                $processedUserLevels = @()
                
                if ($SkillUserLevels -is [string]) {
                    # Process CSV format: "1,user123|2,user456"
                    $entries = $SkillUserLevels -split '\|'
                    foreach ($entry in $entries) {
                        $parts = $entry -split ','
                        if ($parts.Count -eq 2) {
                            $processedUserLevels += @{
                                level = [int]$parts[0]
                                user = @{ id = $parts[1].Trim() }
                            }
                        }
                    }
                }
                elseif ($SkillUserLevels -is [array]) {
                    foreach ($item in $SkillUserLevels) {
                        if ($item -is [hashtable] -or $item -is [PSCustomObject]) {
                            # Already structured data
                            $userLevel = @{
                                level = [int]$item.level
                                user = @{ id = $item.userId }
                            }
                            $processedUserLevels += $userLevel
                        }
                        elseif ($item -is [string]) {
                            # String format within array
                            $parts = $item -split ','
                            if ($parts.Count -eq 2) {
                                $processedUserLevels += @{
                                    level = [int]$parts[0]
                                    user = @{ id = $parts[1].Trim() }
                                }
                            }
                        }
                    }
                }
                
                if ($processedUserLevels.Count -gt 0) {
                    $body['skillUserLevels'] = $processedUserLevels
                }
            }
            
            # Process Prompts
            if ($PSBoundParameters.ContainsKey('Prompts')) {
                $processedPrompts = @()
                
                if ($Prompts -is [string]) {
                    # Process CSV format: "prompt1,prompt2"
                    $promptIds = $Prompts -split ','
                    foreach ($promptId in $promptIds) {
                        $processedPrompts += @{ id = $promptId.Trim() }
                    }
                }
                elseif ($Prompts -is [array]) {
                    foreach ($promptId in $Prompts) {
                        if ($promptId -is [string]) {
                            $processedPrompts += @{ id = $promptId.Trim() }
                        }
                        elseif ($promptId -is [hashtable] -or $promptId -is [PSCustomObject]) {
                            # Already structured
                            $processedPrompts += @{ id = $promptId.id }
                        }
                    }
                }
                
                if ($processedPrompts.Count -gt 0) {
                    $body['prompts'] = $processedPrompts
                }
            }
            
            # Process WhisperPrompt
            if ($PSBoundParameters.ContainsKey('WhisperPromptName')) {
                # If PromptName is provided, resolve it to PromptId
                Write-Verbose "Resolving prompt name '$WhisperPromptName' to prompt ID..."
                    
                try {
                    $domainPrompts = Get-Five9CloudPrompts -Filter "name=='$($WhisperPromptName)'" -Fields "id,name"
                    if ($domainPrompts.resultsCount -gt 0) {
                        $WhisperPromptId = $domainPrompts.entities[0].id
                        Write-Verbose "Found prompt with ID: $WhisperPromptId"
                    }
                } catch {
                    Write-Verbose "No prompt found with name '$WhisperPromptName'"
                }
 
                $body['whisperPrompt'] = @{ id = $WhisperPromptId }
            }
            
            if ($PSBoundParameters.ContainsKey('OverrideGlobal')) {
                $body['overrideGlobal'] = $OverrideGlobal
            }
            
            if ($PSBoundParameters.ContainsKey('SpeedOfAnswerSec')) {
                $body['speedOfAnswerSec'] = $SpeedOfAnswerSec
            }
            
            if ($PSBoundParameters.ContainsKey('MinTimeOfResponseSec')) {
                $body['minTimeOfResponseSec'] = $MinTimeOfResponseSec
            }
            
            # Convert body to JSON
            $jsonBody = $body | ConvertTo-Json -Depth 10
            
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body ($body | ConvertTo-Json -Depth 10)
    } catch {
        Write-Error "Failed to update skill: $_"
    }

}