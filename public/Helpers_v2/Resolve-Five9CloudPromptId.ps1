function Resolve-Five9CloudPromptId ([string]$PromptName) {
    $result = Get-Five9CloudPrompts -Filter "name=='$PromptName'" -Fields 'id,name'
    if ($result.items.Count -gt 0) { return $result.items.promptId }
    Write-Host "Prompt '$PromptName' not found." -ForegroundColor Red; return $null
}