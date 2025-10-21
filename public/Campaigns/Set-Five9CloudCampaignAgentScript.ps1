function Set-Five9CloudCampaignAgentScript {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
        [string]$CampaignId,
        [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
        [string]$CampaignName,
        [Parameter(Mandatory = $true)][string]$InputFilePath,
        [string]$IfMatch = '*'
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
    
    # Verify file exists
    if (-not (Test-Path -Path $InputFilePath)) {
        Write-Error "File not found: $InputFilePath"
        return
    }
    
    try {
        # Read file content
        $fileContent = Get-Content -Path $InputFilePath -Raw -Encoding UTF8
        
        # Encode to base64
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($fileContent)
        $base64Content = [System.Convert]::ToBase64String($bytes)
        
        $uri = "$($global:Five9CloudToken.RestBaseUrl)/v1/domains/$($global:Five9CloudToken.DomainId)/campaigns/$CampaignId/agent-script"
        
        $headers = @{
            Authorization = "Basic $($global:Five9CloudToken.RestBasicAuth)"
            'Content-Type' = 'application/json'
        }
        
        if ($IfMatch) {
            $headers['If-Match'] = $IfMatch
        }
        
        $body = @{
            contentsBase64 = $base64Content
        }
        
        $response = Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body ($body | ConvertTo-Json)
        
    } catch {
        Write-Error "Failed to update agent script: $_"
    }
}