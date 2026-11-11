# PSFive9CloudAPI functions

Generated from the module source on 2026-11-11. Effect: read = no changes; WRITE = changes configuration; DESTRUCTIVE / DISRUPTIVE = needs the extra confirmation in SKILL.md. `*` = mandatory (within its parameter set). If the repo is cloned, the `.ps1` files win over this table.


## Campaigns, profiles, scripts, and prompts

| Function | Effect | Parameters (* = mandatory) |
|---|---|---|
| `Get-Five9CloudCampaignAgentScript` | read | CampaignId, CampaignName |
| `Get-Five9CloudCampaignCallList` | read | CampaignId, CampaignName, CallListId* |
| `Get-Five9CloudCampaignCallLists` | read | CampaignId, CampaignName, PageCursor, PageLimit, CallListId |
| `Get-Five9CloudCampaignConnectors` | read | CampaignId, CampaignName, Sort, PageCursor, PageLimit, Filter |
| `Get-Five9CloudCampaignDetails` | read | CampaignId, CampaignName |
| `Get-Five9CloudCampaignDialingConfiguration` | read | CampaignId, CampaignName |
| `Get-Five9CloudCampaignDialingSettings` | read | CampaignId, CampaignName |
| `Get-Five9CloudCampaignHold` | read | CampaignId, CampaignName |
| `Get-Five9CloudCampaignList` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter |
| `Get-Five9CloudCampaignPrioritization` | read | none |
| `Get-Five9CloudCampaignProfileDetails` | read | ProfileId, ProfileName, Include (Dialing|Ani|Layout|Dispositions|Campaigns|Tags), Raw [switch], Kind, Key |
| `Get-Five9CloudCampaignProfiles` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter |
| `Get-Five9CloudCampaignSkills` | read | CampaignId, CampaignName, Sort, PageCursor, PageLimit, Filter |
| `Get-Five9CloudCampaignTags` | read | CampaignId, CampaignName, Sort, PageCursor, PageLimit, Filter |
| `Get-Five9CloudCampaignWhisper` | read | CampaignId, CampaignName |
| `Get-Five9CloudConnectors` | read | ConnectorName |
| `Get-Five9CloudDispositionList` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter |
| `Get-Five9CloudInboundCampaignDetails` | read | CampaignId, CampaignName, Include (Recordings|Skills|Connectors|Dispositions|Digital|Prompts|Numbers|Messaging|Script|Tags), Raw [switch], Path, Key |
| `Get-Five9CloudOutboundCampaignDetails` | read | CampaignId, CampaignName, Include (Dialing|Lists|Recordings|Skills|Connectors|Dispositions|Digital|Prompts|Messaging|Script|Tags), Raw [switch], Path, Key |
| `Get-Five9CloudPrompts` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter |
| `Get-Five9CloudScriptParameters` | read | ScriptId, ScriptName |
| `Get-Five9CloudScripts` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter |
| `Add-Five9CloudCampaignConnector` | WRITE | CampaignId, CampaignName, ConnectorName, ConnectorId |
| `Add-Five9CloudCampaignSkill` | WRITE | CampaignId, CampaignName, SkillId* |
| `Add-Five9CloudCampaignTag` | WRITE | CampaignId, CampaignName, TagId* |
| `New-Five9CloudAutodialCampaign` | WRITE | Name*, Description, CampaignProfileId, CampaignProfileName, Timezone, DefaultScriptId, UseContactPhoneAsAniForConference [switch], MaxNumOfLines, MaintenanceNotificationEmails, AutoRecord [switch], UserCanControlRecording [switch], RecordQueueCallbacks [switch], DisableRecordingFilenamePattern [switch], ContinueRecordTo3rdParty [switch], ContinueRecordOnHoldCaller [switch], ContinueRecordOnHoldAgent [switch], OverrideDomainTranscriptSettings [switch], ExportChatTranscripts [switch], ExportEmailTranscripts [switch], ExportSocialTranscripts [switch], DisableTranscriptFilenamePattern [switch], WrapupTimeLimit, WrapupSetAgentNotReady [switch], WrapupReasonCodeId, WrapupDispositionId |
| `New-Five9CloudCampaign` | WRITE | CampaignDetails* |
| `New-Five9CloudCampaignProfile` | WRITE | Name*, Description |
| `New-Five9CloudInboundCampaign` | WRITE | Name*, Description, CampaignProfileId, CampaignProfileName, Timezone*, DefaultScriptId*, Extension, UseContactPhoneAsAniForConference [switch], MaxNumVoiceLines, MaxNumVivrSessions, MaxNumTextInteractions, InboundLineUtilizationThreshold, InboundLineUtilizationEmails, MaintenanceNotificationEmails, AutoRecord [switch], UserCanControlRecording [switch], RecordQueueCallbacks [switch], DisableRecordingFilenamePattern [switch], ContinueRecordTo3rdParty [switch], ContinueRecordOnHoldCaller [switch], ContinueRecordOnHoldAgent [switch], OverrideDomainTranscriptSettings [switch], ExportChatTranscripts [switch], ExportEmailTranscripts [switch], ExportSocialTranscripts [switch], DisableTranscriptFilenamePattern [switch], WrapupTimeLimit, WrapupSetAgentNotReady [switch], WrapupReasonCodeId, WrapupDispositionId |
| `New-Five9CloudOutboundCampaign` | WRITE | Name*, Description, CampaignProfileId, CampaignProfileName, UseContactPhoneAsAniForConference [switch], MaintenanceNotificationEmails, AutoRecord [switch], UserCanControlRecording [switch], RecordQueueCallbacks [switch], DisableRecordingFilenamePattern [switch], ContinueRecordTo3rdParty [switch], ContinueRecordOnHoldCaller [switch], ContinueRecordOnHoldAgent [switch], OverrideDomainTranscriptSettings [switch], ExportChatTranscripts [switch], ExportEmailTranscripts [switch], ExportSocialTranscripts [switch], DisableTranscriptFilenamePattern [switch], WrapupTimeLimit, WrapupSetAgentNotReady [switch], WrapupReasonCodeId, WrapupDispositionId |
| `Remove-Five9CloudCampaign` | DESTRUCTIVE | CampaignId, CampaignName |
| `Remove-Five9CloudCampaignConnector` | DESTRUCTIVE | CampaignId, CampaignName, ConnectorName, ConnectorId |
| `Remove-Five9CloudCampaignProfile` | DESTRUCTIVE | ProfileId, ProfileName |
| `Remove-Five9CloudCampaignProfileTag` | DESTRUCTIVE | ProfileId, ProfileName, TagId* |
| `Remove-Five9CloudCampaignSkill` | DESTRUCTIVE | CampaignId, CampaignName, SkillId* |
| `Remove-Five9CloudCampaignSurvey` | DESTRUCTIVE | CampaignId, CampaignName |
| `Remove-Five9CloudCampaignTag` | DESTRUCTIVE | CampaignId, CampaignName, TagId* |
| `Reset-Five9CloudCampaign` | DESTRUCTIVE | CampaignId, CampaignName |
| `Reset-Five9CloudCampaignAbandonedCallRate` | DESTRUCTIVE | CampaignId, CampaignName |
| `Reset-Five9CloudCampaignCSS` | DESTRUCTIVE | CampaignId, CampaignName |
| `Reset-Five9CloudCampaignDialingListPositions` | DESTRUCTIVE | CampaignId, CampaignName |
| `Resolve-Five9CloudCampaignDialingSettings` | read | CampaignId, CampaignName |
| `Resolve-Five9CloudCampaignId` | read | CampaignId, CampaignName |
| `Resolve-Five9CloudCampaignProfileId` | read | ProfileName |
| `Resolve-Five9CloudConnectorId` | read | ConnectorName |
| `Resolve-Five9CloudDispositionId` | read | DispositionId, DispositionName |
| `Resolve-Five9CloudPromptId` | read | PromptName |
| `Resolve-Five9CloudScriptId` | read | ScriptName |
| `Set-Five9CloudCampaignAgentScript` | WRITE | CampaignId, CampaignName, Script* |
| `Set-Five9CloudCampaignCSS` | WRITE | CampaignId, CampaignName, Content* |
| `Set-Five9CloudCampaignCallList` | WRITE | CampaignId, CampaignName, CallListId*, Order*, DialingPriority*, DialingRatio* |
| `Set-Five9CloudCampaignDialingConfiguration` | WRITE | CampaignId, CampaignName, OutOfNumbersAlert*, MaxQueueTime, UseTelemarketingMaxQueueTime1sec, EnableTrainingMode |
| `Set-Five9CloudCampaignDialingSettings` | WRITE | CampaignId, CampaignName, Predictive* [switch], Progressive* [switch], Power* [switch], Preview* [switch], Auto* [switch], ListDialingMode (listPenetration|verticalDialing|extendedStrategy), MinDurationBeforeRedialing, DialingPriority, DialingRatio, CallAnalysisMode (noAnalysis|faxOnly|faxAndAnsweringMachine), AmdVoiceDetectionLevel, AmdActionType (dropCall|playPrompt|startScript), AmdPlayPromptId, AmdPlayPromptMaxGreetingTime, AmdStartScriptId, QueueExpirationActionType (abandonCall|playPrompt|startScript), QueueExpirationPlayPromptId, QueueExpirationStartScriptId, ExtendedStrategy, PreviewMinDurationBeforeRedialing, PreviewDialingPriority, PreviewDialingRatio, PreviewOptionsType (unlimited|limited|dialImmediately), LimitedPreviewActionType (dial|switchAgentToNotReady), LimitedPreviewMaxTime, InterruptCalls, InterruptSkillVoicemails, AutoListDialingMode (listPenetration|verticalDialing|extendedStrategy), AutoMinDurationBeforeRedialing, VoiceDetectionLevel |
| `Set-Five9CloudCampaignHold` | WRITE | CampaignId, CampaignName, PromptName* |
| `Set-Five9CloudCampaignPrioritization` | WRITE | EnablePriority*, EnableDialingRatio* |
| `Set-Five9CloudCampaignProfile` | WRITE | ProfileId, ProfileName, Name, Description |
| `Set-Five9CloudCampaignWhisper` | WRITE | CampaignId, CampaignName, PromptName* |
| `Set-Five9CloudInboundCampaign` | WRITE | CampaignId, CampaignName, Name, Description, CampaignProfileId, CampaignProfileName, Timezone, DefaultScriptId, Extension, UseContactPhoneAsAniForConference [switch], MaxNumVoiceLines, MaxNumVivrSessions, MaxNumTextInteractions, InboundLineUtilizationThreshold, InboundLineUtilizationEmails, MaintenanceNotificationEmails, AutoRecord [switch], UserCanControlRecording [switch], RecordQueueCallbacks [switch], DisableRecordingFilenamePattern [switch], ContinueRecordTo3rdParty [switch], ContinueRecordOnHoldCaller [switch], ContinueRecordOnHoldAgent [switch], OverrideDomainTranscriptSettings [switch], ExportChatTranscripts [switch], ExportEmailTranscripts [switch], ExportSocialTranscripts [switch], DisableTranscriptFilenamePattern [switch], WrapupTimeLimit, WrapupSetAgentNotReady [switch], WrapupReasonCodeId, WrapupDispositionId |
| `Set-Five9CloudOutboundCampaign` | WRITE | CampaignId, CampaignName, Name, Description, CampaignProfileId, CampaignProfileName, UseContactPhoneAsAniForConference [switch], MaintenanceNotificationEmails, AutoRecord [switch], UserCanControlRecording [switch], RecordQueueCallbacks [switch], DisableRecordingFilenamePattern [switch], ContinueRecordTo3rdParty [switch], ContinueRecordOnHoldCaller [switch], ContinueRecordOnHoldAgent [switch], Byot, OverrideDomainTranscriptSettings [switch], ExportChatTranscripts [switch], ExportEmailTranscripts [switch], ExportSocialTranscripts [switch], DisableTranscriptFilenamePattern [switch], WrapupTimeLimit, WrapupSetAgentNotReady [switch], WrapupReasonCodeId, WrapupDispositionId |
| `Start-Five9CloudCampaign` | DISRUPTIVE (live traffic) | CampaignId, CampaignName |
| `Start-Five9CloudCampaignIvrDebugger` | DISRUPTIVE (live traffic) | CampaignId, CampaignName, Channel (VOICE|VISUAL|CHAT|EMAIL|CASE)*, Variable*, Value* |
| `Stop-Five9CloudCampaign` | DISRUPTIVE (live traffic) | CampaignId, CampaignName, Force [switch] |

## Connection and plumbing

| Function | Effect | Parameters (* = mandatory) |
|---|---|---|
| `Get-Five9CloudAuthHeader` | read | none |
| `Get-Five9CloudJwtClaims` | read | Token |
| `Connect-Five9Cloud` | WRITE | Region (us|uk|eu|ca), Environment (prod|alpha), Username, Password, ClientId*, ClientSecret*, DomainId, SkipUpdateCheck [switch] |
| `Invoke-Five9CloudApi` | WRITE | Uri, Method, Suppress [switch] |
| `Invoke-Five9CloudAuth` | WRITE | Base, User, Pass |
| `Invoke-Five9CloudOAuth` | WRITE | Base, Id, Secret |
| `Invoke-Five9CloudPagedApi` | WRITE | Uri, Params, ResultProperty |
| `Set-Five9CloudQueryUri` | WRITE | BasePath, Params |
| `Set-Five9CloudToken` | WRITE | none |
| `Test-Five9CloudConnection` | read | AutoReconnect [switch] |
