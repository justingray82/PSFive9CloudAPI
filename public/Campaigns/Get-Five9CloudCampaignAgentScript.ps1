function Get-Five9CloudAgentScript {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$CampaignId,
        [string]$Fields,
        [Parameter(Mandatory = $false)][string]$OutputFilePath
    )
    
    if (-not (Test-Five9CloudConnection -AuthType RestApi)) { return }
    
    $uri = "$($global:Five9CloudToken.RestBaseUrl)/v1/domains/$($global:Five9CloudToken.DomainId)/campaigns/$CampaignId/agent-script"
    
    if ($Fields) {
        $uri += "?fields=$Fields"
    }
    
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