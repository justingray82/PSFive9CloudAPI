function Get-Five9CloudCampaignAgentScript {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
        [string]$CampaignId,
        [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
        [string]$CampaignName,
        [Parameter(Mandatory = $false)][string]$OutputFilePath
    )
    
    if (-not (Test-Five9CloudConnection -AuthType RestApi)) { return }

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
    
    $uri = "$($global:Five9CloudToken.RestBaseUrl)/v1/domains/$($global:Five9CloudToken.DomainId)/campaigns/$CampaignId/agent-script"
    
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Basic $($global:Five9CloudToken.RestBasicAuth)"
            'Content-Type' = 'application/json'
        }
        
        # If OutputFilePath is provided, decode and save the file
        if ($OutputFilePath -and $response.contentsBase64) {
            try {
                # Decode base64 content
                $decodedBytes = [System.Convert]::FromBase64String($response.contentsBase64)
                $decodedContent = [System.Text.Encoding]::UTF8.GetString($decodedBytes)
                
                # Create directory if it doesn't exist
                $directory = Split-Path -Path $OutputFilePath -Parent
                if ($directory -and -not (Test-Path -Path $directory)) {
                    New-Item -Path $directory -ItemType Directory -Force | Out-Null
                }
                
                # Save to file
                Set-Content -Path $OutputFilePath -Value $decodedContent -Encoding UTF8

            } catch {
                Write-Error "Failed to decode and save agent script: $_"
            }
        }
    } catch {
        Write-Error "Failed to get agent script: $_"
    }
}