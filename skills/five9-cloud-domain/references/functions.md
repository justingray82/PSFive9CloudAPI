# PSFive9CloudAPI functions

Generated from the module source on 2026-11-11. Effect: read = no changes; WRITE = changes configuration; DESTRUCTIVE / DISRUPTIVE = needs the extra confirmation in SKILL.md. `*` = mandatory (within its parameter set). If the repo is cloned, the `.ps1` files win over this table.


## Domain settings, tags, schedules, email, digital assistance

| Function | Effect | Parameters (* = mandatory) |
|---|---|---|
| `Get-Five9CloudConfigEvents` | read | Sort, StartDate, EndDate, TimeZoneOffset |
| `Get-Five9CloudDigitalAssistance` | read | Sort, PageCursor, PageLimit, Filter |
| `Get-Five9CloudDomainSettings` | read | none |
| `Get-Five9CloudDomainTags` | read | Sort, PageCursor, PageLimit, Filter |
| `Get-Five9CloudDomainVerintPackages` | read | none |
| `Get-Five9CloudEmailConfigurations` | read | EmailConfigurationId |
| `Get-Five9CloudEmailNotificationSettings` | read | none |
| `Get-Five9CloudInternalCallsSettings` | read | none |
| `Get-Five9CloudSchedules` | read | Sort, PageCursor, PageLimit, Filter |
| `Get-Five9CloudServiceAccounts` | read | none |
| `Get-Five9CloudUtilizationSettings` | read | none |
| `Add-Five9CloudDigitalAssistance` | WRITE | Name*, Response*, RichTextOption (RichTextEmailOnly|RichControlsMessaging|NoRichText)* |
| `Add-Five9CloudTagScope` | WRITE | Scope (user|campaign|skill|data-table|agent-group|speed-dial|phone-number|permission)*, Name, TagId (dynamic), TagName (dynamic), Username (dynamic), UserUID (dynamic), CampaignName (dynamic), CampaignId (dynamic), SkillName (dynamic), SkillId (dynamic), DataTableName (dynamic), DataTableId (dynamic), AgentGroupName (dynamic), AgentGroupId (dynamic), SpeedDialCode (dynamic), SpeedDialId (dynamic), PhoneNumber (dynamic), PhoneNumberId (dynamic) |
| `New-Five9CloudSchedule` | WRITE | Name*, Description, DefaultScriptId*, ActionScriptId*, ActionDestination*, ActionReject* [switch], ScriptParameterNames, ScriptParameterValues |
| `Remove-Five9CloudDigitalAssistance` | DESTRUCTIVE | AssistanceId, AssistanceName |
| `Remove-Five9CloudSchedule` | DESTRUCTIVE | ScheduleId, ScheduleName |
| `Resolve-Five9CloudAgentGroupId` | read | AgentGroupId, AgentGroupName |
| `Resolve-Five9CloudContactFieldId` | read | FieldId, FieldName |
| `Resolve-Five9CloudDataTableId` | read | DataTableId, DataTableName |
| `Resolve-Five9CloudDomainAssistance` | read | AssistanceName |
| `Resolve-Five9CloudDomainTag` | read | TagName |
| `Resolve-Five9CloudEmailConfigurationId` | read | Email, Type |
| `Resolve-Five9CloudScheduleId` | read | ScheduleName |
| `Resolve-Five9CloudServiceAccountId` | read | ServiceAccountName |
| `Resolve-Five9CloudSpeedDialId` | read | SpeedDialId, SpeedDialCode |
| `Set-Five9CloudDigitalAssistance` | WRITE | AssistanceName*, Response*, RichTextOption (RichTextEmailOnly|RichControlsMessaging|NoRichText)* |
| `Set-Five9CloudEmailConfiguration` | WRITE | EmailConfigurationId, Email, Type (INBOUND|OUTBOUND), NewEmail, Protocol (IMAP|IMAPS|POP3|POP3S|EXCHANGE|EXCHANGE_WEBMAIL|GRAPH|SMTP), ServerHost, Port, Timeout, ConnectionTimeout, CheckServerIdentity, SaveProcessedEmail, ReplyToHeaders, AutoPushbackEmail, AutoPushback4LoggedinUsers, AutoPushbackInterval, ServiceAccountId, ServiceAccountName |
| `Set-Five9CloudEmailNotificationSettings` | WRITE | LineUtilizationNotificationEmails, MaintenanceNotificationEmails, PstnLoginNotificationEmails |
| `Set-Five9CloudInternalCallsSettings` | WRITE | TransferTimedOutInternalCalls, InternalCallTimeout |
| `Set-Five9CloudSchedule` | WRITE | ScheduleId, ScheduleName, Name, Description, DefaultScriptId, ActionScriptId, ActionDestination*, ActionReject* [switch], ScriptParameterNames, ScriptParameterValues |

## Users and access (for exports)

| Function | Effect | Parameters (* = mandatory) |
|---|---|---|
| `Get-Five9CloudApplications` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter |
| `Get-Five9CloudCannedReports` | read | PageCursor, PageLimit |
| `Get-Five9CloudCircleAttributeDetails` | read | circleID, Circlename, Scope ("users"|"roles"|"application-sets"|"skill-sets"|"media-type-sets"|"reason-code-sets")* |
| `Get-Five9CloudCircleDetails` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter |
| `Get-Five9CloudDomainMFAPolicies` | read | none |
| `Get-Five9CloudIdpPolicyDetails` | read | Sort, Offset, Limit, PageCursor, Filter |
| `Get-Five9CloudPermissionList` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter |
| `Get-Five9CloudPermissionSetDetails` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter |
| `Get-Five9CloudPermissionSetUsers` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter, PermissionSet*, SetID |
| `Get-Five9CloudReasonCodeList` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter |
| `Get-Five9CloudReasonCodeSetList` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter |
| `Get-Five9CloudSkillUsers` | read | SkillId, SkillName, Sort, PageCursor, PageLimit, Filter |
| `Get-Five9CloudUserACLDetails` | read | UserUID, Username, Scope ("permissions"|"roles"|"applicationSets"|"applications"|"circles")* |
| `Get-Five9CloudUserCannedReports` | read | Username, UserUID, PageCursor, PageLimit |
| `Get-Five9CloudUserDetails` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter |
| `Get-Five9CloudUserMigrationDetails` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter |
| `Get-Five9CloudUserProfiles` | read | Sort, PageCursor, PageLimit, UserProfileId |
| `Get-Five9CloudUserVMEmailSettings` | read | Username, UserUID |
| `Get-Five9CloudUserVerintDetails` | read | UserUID, Username, Suppress [switch] |
| `Add-Five9CloudCannedReportToUser` | WRITE | Username, UserUID, Report*, ReportFolder |
| `Add-Five9CloudCircleToUser` | WRITE | Username*, UserUID, CircleName*, CircleID |
| `Add-Five9CloudPermissionSetToUser` | WRITE | Username*, UserUID, PermissionSet*, SetID |
| `Add-Five9CloudPermissionToSet` | WRITE | SetID*, Permission* |
| `Add-Five9CloudReasonCodeSetToUser` | WRITE | Username*, UserUID, ReasonCodeSet*, SetID |
| `Add-Five9CloudUserProfileToUser` | WRITE | Username, UserUID, UserProfileName, UserProfileId |
| `Copy-Five9CloudUser` | WRITE | UserUID, Username, NewUsername*, FirstName*, LastName*, Email*, Status (ACTIVE|INACTIVE), AutoMigration [switch], Extension, StartDate, HomeNumber, Locale, MobileNumber, PublicName, Timezone, WorkNumber, MustChangePassword [switch], SkipApplications [switch], SkipPermissions [switch], SkipRoles [switch], SkipAgentGroups [switch], SkipMediaTypes [switch], SkipSkills [switch], SkipCircles [switch], SkipReasonCodes [switch] |
| `New-Five9CloudPermissionSet` | WRITE | Name*, Description |
| `New-Five9CloudUser` | WRITE | Username*, FirstName*, LastName*, Email*, Status (ACTIVE|INACTIVE), FederationID*, IdPPolicy, IdpPolicyId, Extension, StartDate, HomeNumber, Locale, MobileNumber, Timezone, WorkNumber |
| `Remove-Five9CloudUserApplication` | DESTRUCTIVE | UserUID, Username, Application ("adt"|"web-java-admin"|"scc-admin"|"java-admin"|"plus-supervisor"|"admin-console"|"plus-agent"|"agent-assist"|"reporting")* |
| `Remove-Five9CloudUserTag` | DESTRUCTIVE | UserUID, Username*, Tag, TagId |
| `Remove-Five9CloudUserVerintSettings` | DESTRUCTIVE | UserUID, Username |
| `Resolve-Five9CloudCannedReport` | read | Report, ReportFolder |
| `Resolve-Five9CloudCircleID` | read | CircleName |
| `Resolve-Five9CloudIdpPolicyID` | read | IdpPolicy |
| `Resolve-Five9CloudPermissionID` | read | Permission |
| `Resolve-Five9CloudPermissionSetID` | read | PermissionSet |
| `Resolve-Five9CloudReasonCodeId` | read | ReasonCodeId, ReasonCodeName |
| `Resolve-Five9CloudReasonCodeSetId` | read | ReasonCodeSet |
| `Resolve-Five9CloudSkillId` | read | SkillId, SkillName |
| `Resolve-Five9CloudUserIDPPolicy` | read | Username |
| `Resolve-Five9CloudUserProfileId` | read | UserProfileName |
| `Resolve-Five9CloudUserUID` | read | Username |
| `Set-Five9CloudUserApplication` | WRITE | Username*, Application ("adt"|"web-java-admin"|"scc-admin"|"java-admin"|"plus-supervisor"|"admin-console"|"plus-agent"|"agent-assist"|"reporting")* |
| `Set-Five9CloudUserDetails` | WRITE | UserUID, Username, FirstName, LastName, Email, Initials, MobileNumber, WorkNumber, HomeNumber, Timezone, Locale, StartDate, Extension, Mfa (on|off), IdpFederationId, EmployeeId, CostCenter, Status, AvatarUrl, MustChangePassword |
| `Set-Five9CloudUserMfaPolicy` | WRITE | UserUID, Username, Remove [switch] |
| `Set-Five9CloudUserPermission` | WRITE | UserUID, Username, PermissionID, Permission, Remove [switch] |
| `Set-Five9CloudUserSecurity` | WRITE | Username*, IdPPolicy*, FederationID* |
| `Set-Five9CloudUserStatus` | WRITE | Username, UserUID, Action (Activate|Deactivate)* |
| `Set-Five9CloudUserVMEmailSettings` | WRITE | Username, UserUID, CcEmailAddresses, AttachVoicemail, EmbedCampaignProfileLayoutFields, Remove [switch] |
| `Set-Five9CloudUserVerintSettings` | WRITE | Username, UserUID, Packages (
call-recording|
call-recording.screen-recording|
call-recording.quality-monitoring|
call-recording.quality-monitoring.analytics-driven-quality|
call-recording.speech-analytics|
workforce-management|
performance-management|
call-recording.advanced-desktop-analytics
), ScreenRecordingDomainName, ScreenRecordingLoginName |

## Campaigns (for exports)

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

## Numbers (for exports)

| Function | Effect | Parameters (* = mandatory) |
|---|---|---|
| `Get-Five9CloudAniGroupNumbers` | read | AniGroupId, AniGroupName, Fields, Sort, Order (ASC|DESC), Offset, Limit, PageCursor, PageLimit, Filter |
| `Get-Five9CloudAniGroups` | read | Fields, Sort, Order (ASC|DESC), Offset, Limit, PageCursor, PageLimit, Filter |
| `Get-Five9CloudCampaignNumbers` | read | CampaignId, CampaignName, Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter |
| `Get-Five9CloudDomainNumbers` | read | none |
| `Get-Five9CloudNumberCredits` | read | none |
| `Get-Five9CloudNumberInventory` | read | AreaCode, NumberType (DID|TFN), Country |
| `Add-Five9CloudAniGroupNumber` | WRITE | AniGroupId, AniGroupName, Ani*, AreaCode, NoNormalize [switch] |
| `Add-Five9CloudCampaignNumber` | WRITE | CampaignId, CampaignName, Number* |
| `Add-Five9CloudPhoneNumber` | WRITE, consumes credits | AreaCode*, Random* [switch], Quantity, NumberType (DID|TFN), Country, NoWait [switch], TimeoutSeconds |
| `New-Five9CloudNumberOrder` | WRITE, consumes credits | AreaCode*, Quantity, NumberType (DID|TFN), Country |
| `Remove-Five9CloudAniGroupNumber` | DESTRUCTIVE | AniGroupId, AniGroupName, Ani, AniId, NoNormalize [switch] |
| `Remove-Five9CloudCampaignNumber` | DESTRUCTIVE | CampaignId, CampaignName, Number* |
| `Remove-Five9CloudPhoneNumbers` | DESTRUCTIVE, releases numbers | PhoneNumbers*, CsvPath*, ColumnName |
| `Resolve-Five9CloudAniGroupId` | read | AniGroupName |
| `Resolve-Five9CloudAniId` | read | AniGroupId, Ani |
| `Resolve-Five9CloudPhoneNumberId` | read | PhoneNumberId, PhoneNumber |
| `Set-Five9CloudCampaignProfileAniGroup` | WRITE | ProfileId, ProfileName, AniGroupId, AniGroupName, ContactFieldId, ContactFieldName, DefaultAni, ApplyAniGroupToManualCalls, ApplyContactFieldToManualCalls, AgentDidNumber, TransfersAniGroupId, TransfersAniGroupName, TransfersContactFieldId, TransfersContactFieldName, DefaultAniForTransfers, DefaultAniForConferences, QueueCallbackAniSelection (USE_SPECIFIC_ANI|USE_DOMAIN_DEFAULT_ANI|USE_INBOUND_CAMPAIGN_DNIS), QueueCallbackDefaultAni |
| `Set-Five9CloudUserDID` | WRITE | UserUID, Username, DID |

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
