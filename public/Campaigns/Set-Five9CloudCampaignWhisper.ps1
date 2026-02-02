function Set-Five9CloudCampaignWhisper {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
        [string]$CampaignId,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
        [string]$CampaignName,
        
        [Parameter(Mandatory = $true)]
        [string]$WhisperName
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }

    # If CampaignName is provided, resolve it to CampaignId
    if ($PSCmdlet.ParameterSetName -eq 'ByName') {
        Write-Verbose "Resolving campaign name '$CampaignName' to campaign ID..."
        
        # Try inbound campaigns first
        try {
            $inboundCampaigns = Get-Five9CloudInboundCampaigns -Filter "name=='$($CampaignName)'" -Fields "id,name"
            if ($inboundCampaigns.resultsCount -gt 0) {
                $CampaignId = $inboundCampaigns.entities[0].id
                Write-Verbose "Found inbound campaign with ID: $CampaignId"
            }
        } catch {
            Write-Verbose "No inbound campaign found with name '$CampaignName'"
        }
        
        # If not found in inbound, try outbound campaigns
        if (-not $CampaignId) {
            try {
                $outboundCampaigns = Get-Five9CloudOutboundCampaigns -Filter "name=='$($CampaignName)'" -Fields "id,name"
                if ($outboundCampaigns.resultsCount -gt 0) {
                    $CampaignId = $outboundCampaigns.entities[0].id
                    Write-Verbose "Found outbound campaign with ID: $CampaignId"
                }
            } catch {
                Write-Verbose "No outbound campaign found with name '$CampaignName'"
            }
        }
        
        # If still not found, throw error
        if (-not $CampaignId) {
            Write-Error "Campaign with name '$CampaignName' not found in inbound or outbound campaigns."
            return
        }
    }

    $prompts = Get-Five9CloudPrompts -Filter "name=='$($WhisperName)'" -Fields "id,name"
    if ($prompts.resultsCount -gt 0) {
        $promptId = $prompts.entities[0].id
        Write-Verbose "Found prompt with ID: $promptId"
    }    
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/prompts/v1/domains/$($global:Five9CloudToken.DomainId)/campaigns/$($CampaignId)/connected/prompts/$($promptId)"
    
    try {
        Invoke-RestMethod -Uri $uri -Method POST -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body $body
    } catch {
        Write-Error "Failed to set whisper: $_"
    }
}