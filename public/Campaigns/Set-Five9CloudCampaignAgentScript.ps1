function Set-Five9CloudCampaignAgentScript {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$CampaignId,
        [Parameter(Mandatory = $true)][string]$InputFilePath,
        [string]$IfMatch = '*'
    )
    
    if (-not (Test-Five9CloudConnection -AuthType RestApi)) { return }
    
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