function Add-Five9CloudAceyusESS {
    [CmdletBinding()]
    param (
        [string]$authProfileUser,
        [string]$authProfilePassword,
        [string]$ESSAgentURL,
        [string]$ESSInteractionURL
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
  
    $profile_uri = "$($global:Five9CloudToken.ApiBaseUrl)/auth-profiles/v1/domains/$($global:Five9CloudToken.DomainId)/auth-profiles"
    $ess_uri = "$($global:Five9CloudToken.ApiBaseUrl)/events-subscription/v1/domains/$($global:Five9CloudToken.DomainId)/events/subscriptions"

    $profile_body = @{
        name = 'Aceyus OneVue API'
        type = 'BASIC'
        description = 'Aceyus OneVue API'
        basicType = @{
            userName = $authProfileUser
            password = $authProfilePassword
        }
    } | ConvertTo-Json -Depth 10
    
    #Create Auth Profile
    try {
        $profile_response = Invoke-RestMethod -Uri $profile_uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body $profile_body
    } catch {
        Write-Error "Failed to create Auth Profile: $_"
    }

    $ess_agent = @{
    name = 'Aceyus Agent Events'
    delivery = @{
        http = @{
            method = 'POST'
            url = $ESSAgentURL
            headers = @{}
            additionalAttributes = @{}
            authProfileId = $profile_response.authProfileId
        }
    }
    eventGroup = @{
        name = 'AgentEvent'
        fields = @('agentId', 'agentInfo', 'agentState', 'sequence_number')
        filters = @()
    }
    events = @(
        @{
            name = 'Login'
            fields = @()
            filters = @()
        },
        @{
            name = 'Logout'
            fields = @('reasonSince', 'reasonCode')
            filters = @()
        },
        @{
            name = 'MediaAvailabilityChange'
            fields = @('mediaAvailability')
            filters = @()
        },
        @{
            name = 'NextStateChange'
            fields = @('reasonCode', 'nextAgentState')
            filters = @()
        },
        @{
            name = 'NotReady'
            fields = @('reasonSince', 'reasonCode')
            filters = @()
        },
        @{
            name = 'OffAfterInteractionWork'
            fields = @('interactionId', 'media')
            filters = @()
        },
        @{
            name = 'OffMedia'
            fields = @('interactionId', 'media')
            filters = @()
        },
        @{
            name = 'OffPreview'
            fields = @('interactionId', 'media')
            filters = @()
        },
        @{
            name = 'OnAfterInteractionWork'
            fields = @('interactionId', 'media')
            filters = @()
        },
        @{
            name = 'OnMedia'
            fields = @('interactionId', 'media')
            filters = @()
        },
        @{
            name = 'OnPreview'
            fields = @('interactionId', 'media')
            filters = @()
        },
        @{
            name = 'Ready'
            fields = @()
            filters = @()
        },
        @{
            name = 'Ringing'
            fields = @('interactionId', 'media')
            filters = @()
        },
        @{
            name = 'SkillAvailabilityChange'
            fields = @('skillAvailability', 'activeSkills')
            filters = @()
        }
    )
    subGroups = @()
    }

    $body_agent = $ess_agent | ConvertTo-Json -Depth 10    

    #Create ESS Agent Subscription
    try {
        Invoke-RestMethod -Uri $ess_uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body $body_agent
    } catch {
        Write-Error "Failed to add Aceyus Agent Event Subscription: $_"
    }

    $ess_interaction = @{
    name = 'Aceyus Interaction Events'
    delivery = @{
        http = @{
            method = 'POST'
            url = $ESSInteractionURL
            headers = @{}
            additionalAttributes = @{}
            authProfileId = $profile_response.authProfileId
        }
    }
    eventGroup = @{
        name = 'InteractionEvent'
        fields = @('attached_variables', 'call_id', 'campaignInfo', 'campaign_id', 'externalTransactionId', 'interaction_id', 'media', 'sequence_number')
        filters = @()
    }
    events = @(
        @{
            name = 'Abandoned'
            fields = @('skillInfo', 'skill_id', 'taskId')
            filters = @()
        },
        @{
            name = 'Accepted'
            fields = @('agent', 'skillInfo', 'interaction', 'skill_id')
            filters = @()
        },
        @{
            name = 'AfterInteractionWorkEnded'
            fields = @('agent', 'skillInfo', 'interaction', 'skill_id')
            filters = @()
        },
        @{
            name = 'AfterInteractionWorkStarted'
            fields = @('agent', 'skillInfo', 'interaction', 'skill_id')
            filters = @()
        },
        @{
            name = 'AgentEnded'
            fields = @('agent', 'skillInfo', 'interaction', 'skill_id')
            filters = @()
        },
        @{
            name = 'AnsweringMachineDetectionEnded'
            fields = @('call', 'result')
            filters = @()
        },
        @{
            name = 'AnsweringMachineDetectionStarted'
            fields = @('call')
            filters = @()
        },
        @{
            name = 'AssignedToAgent'
            fields = @('agent', 'skillInfo', 'skill_id', 'acd_mode', 'routingService', 'taskId')
            filters = @()
        },
        @{
            name = 'CallConnected'
            fields = @('party')
            filters = @()
        },
        @{
            name = 'CallDisconnectedEvent'
            fields = @('task_id', 'dnis', 'state', 'contact_id', 'ani')
            filters = @()
        },
        @{
            name = 'CallEnded'
            fields = @('party')
            filters = @()
        },
        @{
            name = 'Callback'
            fields = @('skillInfo', 'interaction', 'skill_id', 'taskId')
            filters = @()
        },
        @{
            name = 'CallbackRequested'
            fields = @('skillInfo', 'callback_task', 'callbackExpireTime', 'skill_id', 'taskId')
            filters = @()
        },
        @{
            name = 'Canceled'
            fields = @('skillInfo', 'skill_id', 'taskId')
            filters = @()
        },
        @{
            name = 'ChatMessageSent'
            fields = @('agent', 'skillInfo', 'displayName', 'messageSource', 'externalId', 'message')
            filters = @()
        },
        @{
            name = 'ConferenceCompleted'
            fields = @('id')
            filters = @()
        },
        @{
            name = 'ConferenceInitiated'
            fields = @('agent', 'id')
            filters = @()
        },
        @{
            name = 'ConsultCompleted'
            fields = @('result', 'consultant', 'initiatorAgent')
            filters = @()
        },
        @{
            name = 'ConsultInitiated'
            fields = @('agent', 'consultant')
            filters = @()
        },
        @{
            name = 'ConsultantConnected'
            fields = @('agent', 'consultant')
            filters = @()
        },
        @{
            name = 'Created'
            fields = @('initiator', 'interaction')
            filters = @()
        },
        @{
            name = 'DialEnded'
            fields = @('result', 'destination')
            filters = @()
        },
        @{
            name = 'DialStarted'
            fields = @('destination')
            filters = @()
        },
        @{
            name = 'Dispositioned'
            fields = @('agent', 'worksheets', 'dispositionInfo', 'interactionCreationTime', 'disposition_id')
            filters = @()
        },
        @{
            name = 'Ended'
            fields = @('agent', 'skillInfo', 'skill_id')
            filters = @()
        },
        @{
            name = 'EnteredACD'
            fields = @('serial', 'timeouts', 'priority', 'subTaskId', 'taskId', 'capacity', 'target')
            filters = @()
        },
        @{
            name = 'EnteredIvr'
            fields = @('ivr', 'interaction')
            filters = @()
        },
        @{
            name = 'EnteredModule'
            fields = @('ivrModule', 'ivr', 'module_type', 'name', 'ivrSequenceId')
            filters = @()
        },
        @{
            name = 'EnteredQueue'
            fields = @('skillInfo', 'expiry_timeout', 'interaction', 'skill_id', 'taskId')
            filters = @()
        },
        @{
            name = 'ExitedACD'
            fields = @('serial', 'subTaskId', 'taskId')
            filters = @()
        },
        @{
            name = 'ExitedIvr'
            fields = @('ivr', 'cause')
            filters = @()
        },
        @{
            name = 'ExitedModule'
            fields = @('ivrModule', 'ivr', 'name', 'ivrSequenceId')
            filters = @()
        },
        @{
            name = 'ExitedQueue'
            fields = @('skillInfo', 'skill_id', 'taskId')
            filters = @()
        },
        @{
            name = 'FirstAgentResponse'
            fields = @('agent', 'skillInfo', 'skill_id')
            filters = @()
        },
        @{
            name = 'FirstResponse'
            fields = @('agent', 'skillInfo', 'skill_id')
            filters = @()
        },
        @{
            name = 'JoinedConference'
            fields = @('id', 'conference_participant')
            filters = @()
        },
        @{
            name = 'LeftConference'
            fields = @('reason', 'initiator', 'id', 'conference_participant')
            filters = @()
        },
        @{
            name = 'ModuleError'
            fields = @('ivrModule', 'ivr', 'error_code', 'ivrSequenceId', 'message')
            filters = @()
        },
        @{
            name = 'Offered'
            fields = @('agent', 'offer_interval', 'skillInfo', 'interaction', 'skill_id')
            filters = @()
        },
        @{
            name = 'Parked'
            fields = @('reason', 'initiator', 'parked_party')
            filters = @()
        },
        @{
            name = 'PreviewCall'
            fields = @('agent', 'interaction')
            filters = @()
        },
        @{
            name = 'PreviewInterrupted'
            fields = @('agent', 'interruptedBy')
            filters = @()
        },
        @{
            name = 'PreviewResumed'
            fields = @('agent')
            filters = @()
        },
        @{
            name = 'PutOnHold'
            fields = @('reason', 'initiator', 'party')
            filters = @()
        },
        @{
            name = 'QueueTimeout'
            fields = @('skillInfo', 'skill_id', 'taskId')
            filters = @()
        },
        @{
            name = 'Rejected'
            fields = @('reason', 'agent', 'skillInfo', 'interaction', 'skill_id', 'taskId')
            filters = @()
        },
        @{
            name = 'RetrievedFromHold'
            fields = @('reason', 'initiator', 'party')
            filters = @()
        },
        @{
            name = 'RetrievedFromPark'
            fields = @('reason', 'parkedParty', 'initiator')
            filters = @()
        },
        @{
            name = 'SentToVoicemail'
            fields = @('skillInfo', 'skill_id', 'taskId')
            filters = @()
        },
        @{
            name = 'TransferCompleted'
            fields = @('result', 'initiator', 'destination')
            filters = @()
        },
        @{
            name = 'TransferInitiated'
            fields = @('dialing_timeout', 'initiator', 'destination', 'transfer_type')
            filters = @()
        }
    )
    subGroups = @()
    }

    $body_interaction = $ess_interaction | ConvertTo-Json -Depth 10

    #Create ESS Interaction Subscription
    try {
        Invoke-RestMethod -Uri $ess_uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body $body_interaction
    } catch {
        Write-Error "Failed to add Aceyus Interaction Event Subscription: $_"
    }
}