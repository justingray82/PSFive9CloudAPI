function Set-Five9CloudCampaignDisposition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$CampaignId,
        [Parameter(Mandatory = $true)][string]$DispositionId,
        [string]$CallCategory,
        [string]$DispositionIdOverride,
        
        # Custom Disposition Basic Settings
        [string]$Name,
        [string]$Description,
        [ValidateSet('FINAL', 'REDIAL', 'DO_NOT_DIAL', 'DO_NOT_CALL')]
        [string]$Type,
        
        # Agent Behavior Settings
        [bool]$AgentMustConfirm,
        [bool]$AgentMustCompleteWorksheet,
        [bool]$WorksheetForbidden,
        
        # Notification Settings
        [bool]$SendEmailNotification,
        [bool]$SendInstantMessageNotification,
        
        # Recording Settings
        [bool]$UploadRecordings,
        [ValidateSet('FTP', 'SFTP')]
        [string]$RecordingTransferType,
        [string]$RecordingFtpHost,
        [string]$RecordingFtpUserName,
        [string]$RecordingFtpPassword,
        [int]$RecordingFtpPort,
        [string]$RecordingSftpUserKey,
        [bool]$RecordingRewriteExistingFiles,
        
        # Additional Disposition Settings
        [bool]$TrackAsFirstCallResolution,
        [bool]$ResetAttemptsCounter,
        [bool]$OnlyAllowForTransfersOrConferences,
        [string]$ThirdPartyNumber,
        [bool]$NoPartyContact,
        [bool]$IsOpenDisposition,
        
        # Answering Machine Action Settings
        [ValidateSet('DO_NOT_LEAVE_MESSAGE', 'PLAY_PROMPT', 'PLAY_IVR_SCRIPT')]
        [string]$AnsweringMachineActionType,
        [string]$AnsweringMachinePromptId,
        [int]$AnsweringMachineMaxGreetingTimeSec,
        [string]$AnsweringMachineIvrScriptId,
        
        # Final Disposition Settings
        [bool]$FinalDispositionApplyToCampaigns,
        
        # Redial Disposition Settings
        [bool]$RedialUseRedialTimer,
        [long]$RedialAfterMs,
        [int]$RedialNumOfAttempts,
        [bool]$RedialAllowAgentsChangeRedialTime,
        
        # Do Not Dial Disposition Settings
        [bool]$DoNotDialApplyToAllNumbers,
        [bool]$DoNotDialUseTimerToReactivate,
        [long]$DoNotDialActivateAfterMs,
        [bool]$DoNotDialAgentsCanChangeReactivationTime,
        
        # Do Not Call Disposition Settings
        [string]$DoNotCallDncAction
    )
    
    if (-not (Test-Five9CloudConnection -AuthType RestApi)) { return }
    
    $uri = "$($global:Five9CloudToken.RestBaseUrl)/v1/domains/$($global:Five9CloudToken.DomainId)/campaigns/$CampaignId/dispositions/$DispositionId"
    
    $headers = @{
        Authorization = "$($global:Five9CloudToken.RestApi.Authorization)"
        'Content-Type' = 'application/json'
    }
    
    $body = @{}
    
    if ($CallCategory) { $body['callCategory'] = $CallCategory }
    if ($DispositionIdOverride) { $body['dispositionId'] = $DispositionIdOverride }
    
    # Build Custom Disposition object if any custom disposition parameters are provided
    $customDisposition = @{}
    
    # Basic Settings
    if ($Name) { $customDisposition['name'] = $Name }
    if ($Description) { $customDisposition['description'] = $Description }
    if ($Type) { $customDisposition['type'] = $Type }
    
    # Agent Behavior Settings
    if ($PSBoundParameters.ContainsKey('AgentMustConfirm')) { 
        $customDisposition['agentMustConfirm'] = $AgentMustConfirm 
    }
    if ($PSBoundParameters.ContainsKey('AgentMustCompleteWorksheet')) { 
        $customDisposition['agentMustCompleteWorksheet'] = $AgentMustCompleteWorksheet 
    }
    if ($PSBoundParameters.ContainsKey('WorksheetForbidden')) { 
        $customDisposition['worksheetForbidden'] = $WorksheetForbidden 
    }
    
    # Notification Settings
    if ($PSBoundParameters.ContainsKey('SendEmailNotification')) { 
        $customDisposition['sendEmailNotification'] = $SendEmailNotification 
    }
    if ($PSBoundParameters.ContainsKey('SendInstantMessageNotification')) { 
        $customDisposition['sendInstantMessageNotification'] = $SendInstantMessageNotification 
    }
    
    # Recording Settings
    if ($PSBoundParameters.ContainsKey('UploadRecordings')) { 
        $customDisposition['uploadRecordings'] = $UploadRecordings 
    }
    
    # Call Recording Transfer Settings
    if ($RecordingTransferType -or $RecordingFtpHost -or $RecordingFtpUserName) {
        $callRecordingTransfer = @{}
        
        if ($RecordingTransferType) { $callRecordingTransfer['type'] = $RecordingTransferType }
        
        if ($RecordingTransferType -eq 'FTP' -or -not $RecordingTransferType) {
            $ftp = @{}
            if ($RecordingFtpHost) { $ftp['host'] = $RecordingFtpHost }
            if ($RecordingFtpUserName) { $ftp['userName'] = $RecordingFtpUserName }
            if ($RecordingFtpPassword) { $ftp['password'] = $RecordingFtpPassword }
            if ($PSBoundParameters.ContainsKey('RecordingFtpPort')) { $ftp['port'] = $RecordingFtpPort }
            if ($ftp.Count -gt 0) { $callRecordingTransfer['ftp'] = $ftp }
        }
        
        if ($RecordingTransferType -eq 'SFTP') {
            $sftp = @{}
            if ($RecordingFtpHost) { $sftp['host'] = $RecordingFtpHost }
            if ($RecordingFtpUserName) { $sftp['userName'] = $RecordingFtpUserName }
            if ($RecordingFtpPassword) { $sftp['password'] = $RecordingFtpPassword }
            if ($PSBoundParameters.ContainsKey('RecordingFtpPort')) { $sftp['port'] = $RecordingFtpPort }
            if ($RecordingSftpUserKey) { $sftp['userKey'] = $RecordingSftpUserKey }
            if ($sftp.Count -gt 0) { $callRecordingTransfer['sftp'] = $sftp }
        }
        
        if ($PSBoundParameters.ContainsKey('RecordingRewriteExistingFiles')) { 
            $callRecordingTransfer['rewriteExistingFiles'] = $RecordingRewriteExistingFiles 
        }
        
        if ($callRecordingTransfer.Count -gt 0) { 
            $customDisposition['callRecordingTransfer'] = $callRecordingTransfer 
        }
    }
    
    # Additional Disposition Settings
    if ($PSBoundParameters.ContainsKey('TrackAsFirstCallResolution')) { 
        $customDisposition['trackAsFirstCallResolution'] = $TrackAsFirstCallResolution 
    }
    if ($PSBoundParameters.ContainsKey('ResetAttemptsCounter')) { 
        $customDisposition['resetAttemptsCounter'] = $ResetAttemptsCounter 
    }
    if ($PSBoundParameters.ContainsKey('OnlyAllowForTransfersOrConferences')) { 
        $customDisposition['onlyAllowForTransfersOrConferences'] = $OnlyAllowForTransfersOrConferences 
    }
    if ($ThirdPartyNumber) { $customDisposition['thirdPartyNumber'] = $ThirdPartyNumber }
    if ($PSBoundParameters.ContainsKey('NoPartyContact')) { 
        $customDisposition['noPartyContact'] = $NoPartyContact 
    }
    if ($PSBoundParameters.ContainsKey('IsOpenDisposition')) { 
        $customDisposition['isOpenDisposition'] = $IsOpenDisposition 
    }
    
    # Answering Machine Action
    if ($AnsweringMachineActionType -or $AnsweringMachinePromptId -or $AnsweringMachineIvrScriptId) {
        $answeringMachineAction = @{}
        
        if ($AnsweringMachineActionType) { $answeringMachineAction['type'] = $AnsweringMachineActionType }
        
        if ($AnsweringMachineActionType -eq 'PLAY_PROMPT' -and $AnsweringMachinePromptId) {
            $playPrompt = @{
                prompt = @{ id = $AnsweringMachinePromptId }
            }
            if ($PSBoundParameters.ContainsKey('AnsweringMachineMaxGreetingTimeSec')) { 
                $playPrompt['maxGreetingTimeSec'] = $AnsweringMachineMaxGreetingTimeSec 
            }
            $answeringMachineAction['playPrompt'] = $playPrompt
        }
        
        if ($AnsweringMachineActionType -eq 'PLAY_IVR_SCRIPT' -and $AnsweringMachineIvrScriptId) {
            $playIvrScript = @{
                ivrScript = @{ id = $AnsweringMachineIvrScriptId }
            }
            if ($PSBoundParameters.ContainsKey('AnsweringMachineMaxGreetingTimeSec')) { 
                $playIvrScript['maxGreetingTimeSec'] = $AnsweringMachineMaxGreetingTimeSec 
            }
            $answeringMachineAction['playIvrScript'] = $playIvrScript
        }
        
        if ($answeringMachineAction.Count -gt 0) { 
            $customDisposition['answeringMachineAction'] = $answeringMachineAction 
        }
    }
    
    # Final Disposition Settings
    if ($PSBoundParameters.ContainsKey('FinalDispositionApplyToCampaigns')) {
        $customDisposition['finalDisposition'] = @{
            applyToCampaigns = $FinalDispositionApplyToCampaigns
        }
    }
    
    # Redial Disposition Settings
    if ($PSBoundParameters.ContainsKey('RedialUseRedialTimer') -or 
        $PSBoundParameters.ContainsKey('RedialAfterMs') -or
        $PSBoundParameters.ContainsKey('RedialNumOfAttempts')) {
        
        $redialDisposition = @{}
        
        if ($PSBoundParameters.ContainsKey('RedialUseRedialTimer')) { 
            $redialDisposition['useRedialTimer'] = $RedialUseRedialTimer 
        }
        
        if ($PSBoundParameters.ContainsKey('RedialAfterMs') -or 
            $PSBoundParameters.ContainsKey('RedialNumOfAttempts') -or
            $PSBoundParameters.ContainsKey('RedialAllowAgentsChangeRedialTime')) {
            
            $redialTimerParams = @{}
            if ($PSBoundParameters.ContainsKey('RedialAfterMs')) { 
                $redialTimerParams['redialAfterMs'] = $RedialAfterMs 
            }
            if ($PSBoundParameters.ContainsKey('RedialNumOfAttempts')) { 
                $redialTimerParams['numOfAttempts'] = $RedialNumOfAttempts 
            }
            if ($PSBoundParameters.ContainsKey('RedialAllowAgentsChangeRedialTime')) { 
                $redialTimerParams['allowAgentsChangeRedialTime'] = $RedialAllowAgentsChangeRedialTime 
            }
            
            if ($redialTimerParams.Count -gt 0) { 
                $redialDisposition['redialTimerParams'] = $redialTimerParams 
            }
        }
        
        if ($redialDisposition.Count -gt 0) { 
            $customDisposition['redialDisposition'] = $redialDisposition 
        }
    }
    
    # Do Not Dial Disposition Settings
    if ($PSBoundParameters.ContainsKey('DoNotDialApplyToAllNumbers') -or 
        $PSBoundParameters.ContainsKey('DoNotDialUseTimerToReactivate') -or
        $PSBoundParameters.ContainsKey('DoNotDialActivateAfterMs')) {
        
        $doNotDialDisposition = @{}
        
        if ($PSBoundParameters.ContainsKey('DoNotDialApplyToAllNumbers')) { 
            $doNotDialDisposition['applyToAllNumbersInContactRecord'] = $DoNotDialApplyToAllNumbers 
        }
        if ($PSBoundParameters.ContainsKey('DoNotDialUseTimerToReactivate')) { 
            $doNotDialDisposition['useTimerToReactivateNumber'] = $DoNotDialUseTimerToReactivate 
        }
        
        if ($PSBoundParameters.ContainsKey('DoNotDialActivateAfterMs') -or 
            $PSBoundParameters.ContainsKey('DoNotDialAgentsCanChangeReactivationTime')) {
            
            $reactivationParams = @{}
            if ($PSBoundParameters.ContainsKey('DoNotDialActivateAfterMs')) { 
                $reactivationParams['activateAfterMs'] = $DoNotDialActivateAfterMs 
            }
            if ($PSBoundParameters.ContainsKey('DoNotDialAgentsCanChangeReactivationTime')) { 
                $reactivationParams['agentsCanChangeReactivationTime'] = $DoNotDialAgentsCanChangeReactivationTime 
            }
            
            if ($reactivationParams.Count -gt 0) { 
                $doNotDialDisposition['reactivationParams'] = $reactivationParams 
            }
        }
        
        if ($doNotDialDisposition.Count -gt 0) { 
            $customDisposition['doNotDialDisposition'] = $doNotDialDisposition 
        }
    }
    
    # Do Not Call Disposition Settings
    if ($DoNotCallDncAction) {
        $customDisposition['doNotCallDisposition'] = @{
            dncAction = $DoNotCallDncAction
        }
    }
    
    if ($customDisposition.Count -gt 0) { $body['customDisposition'] = $customDisposition }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body ($body | ConvertTo-Json -Depth 10)
    } catch {
        Write-Error "Failed to update campaign disposition: $_"
    }
}