# PSFive9CloudAPI function reference

Generated from the module source on 2026-11-11 by `skills/tools/generate_function_reference.py`. If the user's installed version differs, the source wins: ask them to run `(Get-Command <Name>).Definition`.

- **Effect**: read = no changes; WRITE = changes configuration; DESTRUCTIVE / LIVE TRAFFIC / uses credits = confirm separately.
- **Parameters**: `*` = mandatory (within its parameter set). `(a\|b)` = allowed values. Most functions accept a name *or* an ID for the target (`-CampaignName` or `-CampaignId`); pass one.
- **Output**: what the function writes to the pipeline. "page envelopes" means read `.items`. Detected automatically; spot-check the source when it matters.
- **Pipeline**: functions marked ⇢ accept objects piped from list functions by property name.

Contents: [Connection](#connection), [Phone numbers, ANI groups, and caller ID](#phone-numbers-ani-groups-and-caller-id), [Campaigns, campaign profiles, scripts, and prompts](#campaigns-campaign-profiles-scripts-and-prompts), [Users and access](#users-and-access), [Domain settings, tags, schedules, email, digital assistance, audit log](#domain-settings-tags-schedules-email-digital-assistance-audit-log)

## Connection

| Function | Effect | Parameters | Output |
|---|---|---|---|
| `Connect-Five9Cloud` | read | Region (us\|uk\|eu\|ca), Environment (prod\|alpha), Username, Password, ClientId*, ClientSecret*, DomainId, SkipUpdateCheck [switch] | nothing; sets $global:Five9 (empty on failure) |
| `Test-Five9CloudConnection` | read | AutoReconnect [switch] | $true or $false |

## Phone numbers, ANI groups, and caller ID

| Function | Effect | Parameters | Output |
|---|---|---|---|
| `Get-Five9CloudAniGroupNumbers` | read | AniGroupId, AniGroupName, Fields, Sort, Order (ASC\|DESC), Offset, Limit, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudAniGroups` | read | Fields, Sort, Order (ASC\|DESC), Offset, Limit, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudCampaignNumbers` | read | CampaignId, CampaignName, Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudDomainNumbers` | read | none | page envelopes: read .items |
| `Get-Five9CloudNumberCredits` | read | none | one object of credit counts (e.g. DID_AVAILABLE) |
| `Get-Five9CloudNumberInventory` | read | AreaCode [array], NumberType (DID\|TFN), Country | one row per area code: AreaCode, State, Available, NumberType, Country |
| `Resolve-Five9CloudAniGroupId` | read | AniGroupName | ID, or $null if not found |
| `Resolve-Five9CloudAniId` | read | AniGroupId, Ani | ID, or $null if not found |
| `Resolve-Five9CloudPhoneNumberId` | read | PhoneNumberId, PhoneNumber | ID, or $null if not found |
| `New-Five9CloudNumberOrder` | WRITE, uses credits | AreaCode* [array], Quantity (1-1000), NumberType (DID\|TFN), Country | object with NumberOrderId and Status; $false on failure |
| `Add-Five9CloudAniGroupNumber` | WRITE | AniGroupId, AniGroupName, Ani*, AreaCode, NoNormalize [switch] | API response on success; $false on failure |
| `Add-Five9CloudCampaignNumber` | WRITE | CampaignId, CampaignName, Number* | nothing on success (prints a message); $false on failure |
| `Add-Five9CloudPhoneNumber` | WRITE, uses credits | AreaCode* [array], Random* [switch], Quantity (1-1000), NumberType (DID\|TFN), Country, NoWait [switch], TimeoutSeconds | claim result after polling; the bulkClaimId with -NoWait; $false on failure |
| `Set-Five9CloudCampaignProfileAniGroup` | WRITE | ProfileId, ProfileName, AniGroupId, AniGroupName, ContactFieldId, ContactFieldName, DefaultAni, ApplyAniGroupToManualCalls [bool], ApplyContactFieldToManualCalls [bool], AgentDidNumber [bool], TransfersAniGroupId, TransfersAniGroupName, TransfersContactFieldId, TransfersContactFieldName, DefaultAniForTransfers, DefaultAniForConferences, QueueCallbackAniSelection (USE_SPECIFIC_ANI\|USE_DOMAIN_DEFAULT_ANI\|USE_INBOUND_CAMPAIGN_DNIS), QueueCallbackDefaultAni | nothing on success (prints a message); $false on failure |
| `Set-Five9CloudUserDID` | WRITE | UserUID, Username, DID | nothing on success (prints a message); $false on failure |
| `Remove-Five9CloudAniGroupNumber` | DESTRUCTIVE | AniGroupId, AniGroupName, Ani, AniId, NoNormalize [switch] | nothing (prints a message): verify by re-reading |
| `Remove-Five9CloudCampaignNumber` | DESTRUCTIVE | CampaignId, CampaignName, Number* | nothing on success (prints a message); $false on failure |
| `Remove-Five9CloudPhoneNumbers` | DESTRUCTIVE, releases numbers | PhoneNumbers* [array], CsvPath*, ColumnName | nothing on success (prints a message); $false on failure |

## Campaigns, campaign profiles, scripts, and prompts

| Function | Effect | Parameters | Output |
|---|---|---|---|
| `Get-Five9CloudCampaignAgentScript` | read | CampaignId, CampaignName | API response object |
| `Get-Five9CloudCampaignCallList` | read | CampaignId, CampaignName, CallListId* | API response object |
| `Get-Five9CloudCampaignCallLists` | read | CampaignId, CampaignName, PageCursor, PageLimit, CallListId | page envelopes: read .items |
| `Get-Five9CloudCampaignConnectors` | read | CampaignId, CampaignName, Sort, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudCampaignDetails` | read | CampaignId, CampaignName | API response object |
| `Get-Five9CloudCampaignDialingConfiguration` | read | CampaignId, CampaignName | API response object |
| `Get-Five9CloudCampaignDialingSettings` | read | CampaignId, CampaignName | API response object |
| `Get-Five9CloudCampaignHold` | read | CampaignId, CampaignName | API response object |
| `Get-Five9CloudCampaignList` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudCampaignPrioritization` | read | none | API response object |
| `Get-Five9CloudCampaignProfileDetails` ⇢ | read | ProfileId, ProfileName, Include (Dialing\|Ani\|Layout\|Dispositions\|Campaigns\|Tags) [array], Raw [switch], Kind, Key | one combined object per profile; -Raw for untouched API responses |
| `Get-Five9CloudCampaignProfiles` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudCampaignSkills` | read | CampaignId, CampaignName, Sort, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudCampaignTags` | read | CampaignId, CampaignName, Sort, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudCampaignWhisper` | read | CampaignId, CampaignName | API response object |
| `Get-Five9CloudConnectors` | read | ConnectorName | page envelopes: read .items |
| `Get-Five9CloudDispositionList` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudInboundCampaignDetails` ⇢ | read | CampaignId, CampaignName, Include (Recordings\|Skills\|Connectors\|Dispositions\|Digital\|Prompts\|Numbers\|Messaging\|Script\|Tags) [array], Raw [switch], Path, Key | one combined object per campaign (all tabs); -Raw for untouched API responses |
| `Get-Five9CloudOutboundCampaignDetails` ⇢ | read | CampaignId, CampaignName, Include (Dialing\|Lists\|Recordings\|Skills\|Connectors\|Dispositions\|Digital\|Prompts\|Messaging\|Script\|Tags) [array], Raw [switch], Path, Key | one combined object per campaign (all tabs); -Raw for untouched API responses |
| `Get-Five9CloudPrompts` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudScriptParameters` | read | ScriptId, ScriptName | API response object |
| `Get-Five9CloudScripts` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Resolve-Five9CloudCampaignDialingSettings` | read | CampaignId, CampaignName | ID, or $null if not found |
| `Resolve-Five9CloudCampaignId` | read | CampaignId, CampaignName | ID, or $null if not found |
| `Resolve-Five9CloudCampaignProfileId` | read | ProfileName | ID, or $null if not found |
| `Resolve-Five9CloudConnectorId` | read | ConnectorName | ID, or $null if not found |
| `Resolve-Five9CloudDispositionId` | read | DispositionId, DispositionName | ID, or $null if not found |
| `Resolve-Five9CloudPromptId` | read | PromptName | ID, or $null if not found |
| `Resolve-Five9CloudScriptId` | read | ScriptName | ID, or $null if not found |
| `New-Five9CloudAutodialCampaign` | WRITE | Name*, Description, CampaignProfileId, CampaignProfileName, Timezone, DefaultScriptId, UseContactPhoneAsAniForConference [switch], MaxNumOfLines, MaintenanceNotificationEmails [array], AutoRecord [switch], UserCanControlRecording [switch], RecordQueueCallbacks [switch], DisableRecordingFilenamePattern [switch], ContinueRecordTo3rdParty [switch], ContinueRecordOnHoldCaller [switch], ContinueRecordOnHoldAgent [switch], OverrideDomainTranscriptSettings [switch], ExportChatTranscripts [switch], ExportEmailTranscripts [switch], ExportSocialTranscripts [switch], DisableTranscriptFilenamePattern [switch], WrapupTimeLimit, WrapupSetAgentNotReady [switch], WrapupReasonCodeId, WrapupDispositionId | API response on success; $false on failure |
| `New-Five9CloudCampaign` | WRITE | CampaignDetails* | API response on success; $false on failure |
| `New-Five9CloudCampaignProfile` | WRITE | Name*, Description | API response on success; $false on failure |
| `New-Five9CloudInboundCampaign` | WRITE | Name*, Description, CampaignProfileId, CampaignProfileName, Timezone*, DefaultScriptId*, Extension, UseContactPhoneAsAniForConference [switch], MaxNumVoiceLines, MaxNumVivrSessions, MaxNumTextInteractions, InboundLineUtilizationThreshold, InboundLineUtilizationEmails [array], MaintenanceNotificationEmails [array], AutoRecord [switch], UserCanControlRecording [switch], RecordQueueCallbacks [switch], DisableRecordingFilenamePattern [switch], ContinueRecordTo3rdParty [switch], ContinueRecordOnHoldCaller [switch], ContinueRecordOnHoldAgent [switch], OverrideDomainTranscriptSettings [switch], ExportChatTranscripts [switch], ExportEmailTranscripts [switch], ExportSocialTranscripts [switch], DisableTranscriptFilenamePattern [switch], WrapupTimeLimit, WrapupSetAgentNotReady [switch], WrapupReasonCodeId, WrapupDispositionId | API response on success; $false on failure |
| `New-Five9CloudOutboundCampaign` | WRITE | Name*, Description, CampaignProfileId, CampaignProfileName, UseContactPhoneAsAniForConference [switch], MaintenanceNotificationEmails [array], AutoRecord [switch], UserCanControlRecording [switch], RecordQueueCallbacks [switch], DisableRecordingFilenamePattern [switch], ContinueRecordTo3rdParty [switch], ContinueRecordOnHoldCaller [switch], ContinueRecordOnHoldAgent [switch], OverrideDomainTranscriptSettings [switch], ExportChatTranscripts [switch], ExportEmailTranscripts [switch], ExportSocialTranscripts [switch], DisableTranscriptFilenamePattern [switch], WrapupTimeLimit, WrapupSetAgentNotReady [switch], WrapupReasonCodeId, WrapupDispositionId | API response on success; $false on failure |
| `Add-Five9CloudCampaignConnector` | WRITE | CampaignId, CampaignName, ConnectorName, ConnectorId | nothing (prints a message): verify by re-reading |
| `Add-Five9CloudCampaignSkill` | WRITE | CampaignId, CampaignName, SkillId* | nothing on success (prints a message); $false on failure |
| `Add-Five9CloudCampaignTag` | WRITE | CampaignId, CampaignName, TagId* | nothing on success (prints a message); $false on failure |
| `Set-Five9CloudCampaignAgentScript` | WRITE | CampaignId, CampaignName, Script* | nothing on success (prints a message); $false on failure |
| `Set-Five9CloudCampaignCSS` | WRITE | CampaignId, CampaignName, Content* | nothing on success (prints a message); $false on failure |
| `Set-Five9CloudCampaignCallList` | WRITE | CampaignId, CampaignName, CallListId*, Order*, DialingPriority (1-99)*, DialingRatio (1-99)* | API response on success; $false on failure |
| `Set-Five9CloudCampaignDialingConfiguration` | WRITE | CampaignId, CampaignName, OutOfNumbersAlert* [bool], MaxQueueTime, UseTelemarketingMaxQueueTime1sec [bool], EnableTrainingMode [bool] | API response on success; $false on failure |
| `Set-Five9CloudCampaignDialingSettings` | WRITE | CampaignId, CampaignName, Predictive* [switch], Progressive* [switch], Power* [switch], Preview* [switch], Auto* [switch], ListDialingMode (listPenetration\|verticalDialing\|extendedStrategy), MinDurationBeforeRedialing, DialingPriority (1-99), DialingRatio (1-99), CallAnalysisMode (noAnalysis\|faxOnly\|faxAndAnsweringMachine), AmdVoiceDetectionLevel (20-100), AmdActionType (dropCall\|playPrompt\|startScript), AmdPlayPromptId, AmdPlayPromptMaxGreetingTime, AmdStartScriptId, QueueExpirationActionType (abandonCall\|playPrompt\|startScript), QueueExpirationPlayPromptId, QueueExpirationStartScriptId, ExtendedStrategy [bool], PreviewMinDurationBeforeRedialing, PreviewDialingPriority (1-99), PreviewDialingRatio (1-99), PreviewOptionsType (unlimited\|limited\|dialImmediately), LimitedPreviewActionType (dial\|switchAgentToNotReady), LimitedPreviewMaxTime, InterruptCalls [bool], InterruptSkillVoicemails [bool], AutoListDialingMode (listPenetration\|verticalDialing\|extendedStrategy), AutoMinDurationBeforeRedialing, VoiceDetectionLevel (20-100) | API response on success; $false on failure |
| `Set-Five9CloudCampaignHold` | WRITE | CampaignId, CampaignName, PromptName* | nothing on success (prints a message); $false on failure |
| `Set-Five9CloudCampaignPrioritization` | WRITE | EnablePriority* [bool], EnableDialingRatio* [bool] | API response on success; $false on failure |
| `Set-Five9CloudCampaignProfile` | WRITE | ProfileId, ProfileName, Name, Description | API response on success; $false on failure |
| `Set-Five9CloudCampaignWhisper` | WRITE | CampaignId, CampaignName, PromptName* | nothing on success (prints a message); $false on failure |
| `Set-Five9CloudInboundCampaign` | WRITE | CampaignId, CampaignName, Name, Description, CampaignProfileId, CampaignProfileName, Timezone, DefaultScriptId, Extension, UseContactPhoneAsAniForConference [switch], MaxNumVoiceLines, MaxNumVivrSessions, MaxNumTextInteractions, InboundLineUtilizationThreshold, InboundLineUtilizationEmails [array], MaintenanceNotificationEmails [array], AutoRecord [switch], UserCanControlRecording [switch], RecordQueueCallbacks [switch], DisableRecordingFilenamePattern [switch], ContinueRecordTo3rdParty [switch], ContinueRecordOnHoldCaller [switch], ContinueRecordOnHoldAgent [switch], OverrideDomainTranscriptSettings [switch], ExportChatTranscripts [switch], ExportEmailTranscripts [switch], ExportSocialTranscripts [switch], DisableTranscriptFilenamePattern [switch], WrapupTimeLimit, WrapupSetAgentNotReady [switch], WrapupReasonCodeId, WrapupDispositionId | nothing (prints a message): verify by re-reading |
| `Set-Five9CloudOutboundCampaign` | WRITE | CampaignId, CampaignName, Name, Description, CampaignProfileId, CampaignProfileName, UseContactPhoneAsAniForConference [switch], MaintenanceNotificationEmails [array], AutoRecord [switch], UserCanControlRecording [switch], RecordQueueCallbacks [switch], DisableRecordingFilenamePattern [switch], ContinueRecordTo3rdParty [switch], ContinueRecordOnHoldCaller [switch], ContinueRecordOnHoldAgent [switch], Byot [bool], OverrideDomainTranscriptSettings [switch], ExportChatTranscripts [switch], ExportEmailTranscripts [switch], ExportSocialTranscripts [switch], DisableTranscriptFilenamePattern [switch], WrapupTimeLimit, WrapupSetAgentNotReady [switch], WrapupReasonCodeId, WrapupDispositionId | nothing (prints a message): verify by re-reading |
| `Start-Five9CloudCampaign` | LIVE TRAFFIC | CampaignId, CampaignName | nothing on success (prints a message); $false on failure |
| `Start-Five9CloudCampaignIvrDebugger` | LIVE TRAFFIC | CampaignId, CampaignName, Channel (VOICE\|VISUAL\|CHAT\|EMAIL\|CASE)*, Variable*, Value* | API response on success; $false on failure |
| `Stop-Five9CloudCampaign` | LIVE TRAFFIC | CampaignId, CampaignName, Force [switch] | nothing on success (prints a message); $false on failure |
| `Reset-Five9CloudCampaign` | DESTRUCTIVE | CampaignId, CampaignName | nothing on success (prints a message); $false on failure |
| `Reset-Five9CloudCampaignAbandonedCallRate` | DESTRUCTIVE | CampaignId, CampaignName | nothing on success (prints a message); $false on failure |
| `Reset-Five9CloudCampaignCSS` | DESTRUCTIVE | CampaignId, CampaignName | API response on success; $false on failure |
| `Reset-Five9CloudCampaignDialingListPositions` | DESTRUCTIVE | CampaignId, CampaignName | nothing on success (prints a message); $false on failure |
| `Remove-Five9CloudCampaign` | DESTRUCTIVE | CampaignId, CampaignName | nothing on success (prints a message); $false on failure |
| `Remove-Five9CloudCampaignConnector` | DESTRUCTIVE | CampaignId, CampaignName, ConnectorName, ConnectorId | nothing (prints a message): verify by re-reading |
| `Remove-Five9CloudCampaignProfile` | DESTRUCTIVE | ProfileId, ProfileName | nothing on success (prints a message); $false on failure |
| `Remove-Five9CloudCampaignProfileTag` | DESTRUCTIVE | ProfileId, ProfileName, TagId* | nothing on success (prints a message); $false on failure |
| `Remove-Five9CloudCampaignSkill` | DESTRUCTIVE | CampaignId, CampaignName, SkillId* | nothing on success (prints a message); $false on failure |
| `Remove-Five9CloudCampaignSurvey` | DESTRUCTIVE | CampaignId, CampaignName | nothing on success (prints a message); $false on failure |
| `Remove-Five9CloudCampaignTag` | DESTRUCTIVE | CampaignId, CampaignName, TagId* | nothing on success (prints a message); $false on failure |

## Users and access

| Function | Effect | Parameters | Output |
|---|---|---|---|
| `Get-Five9CloudApplications` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudCannedReports` | read | PageCursor, PageLimit | page envelopes: read .items |
| `Get-Five9CloudCircleAttributeDetails` | read | circleID, Circlename, Scope (users\|roles\|application-sets\|skill-sets\|media-type-sets\|reason-code-sets)* | names (strings) |
| `Get-Five9CloudCircleDetails` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudDomainMFAPolicies` | read | none | API response object |
| `Get-Five9CloudIdpPolicyDetails` | read | Sort, Offset, Limit, PageCursor, Filter | page envelopes: read .items |
| `Get-Five9CloudPermissionList` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudPermissionSetDetails` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudPermissionSetUsers` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter, PermissionSet*, SetID | page envelopes: read .items |
| `Get-Five9CloudReasonCodeList` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudReasonCodeSetList` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudSkillUsers` | read | SkillId, SkillName, Sort, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudUserACLDetails` | read | UserUID, Username, Scope (permissions\|roles\|applicationSets\|applications\|circles)* | entries for the chosen -Scope (names for circles); all users when no user is given |
| `Get-Five9CloudUserCannedReports` | read | Username, UserUID, PageCursor, PageLimit | page envelopes: read .items |
| `Get-Five9CloudUserDetails` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudUserMigrationDetails` | read | Fields, Sort, Offset, Limit, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudUserProfiles` | read | Sort, PageCursor, PageLimit, UserProfileId | page envelopes: read .items |
| `Get-Five9CloudUserVMEmailSettings` | read | Username, UserUID | API response object |
| `Get-Five9CloudUserVerintDetails` | read | UserUID, Username, Suppress [switch] | API response object |
| `Resolve-Five9CloudCannedReport` | read | Report, ReportFolder | ID, or $null if not found |
| `Resolve-Five9CloudCircleID` | read | CircleName | ID, or $null if not found |
| `Resolve-Five9CloudIdPPolicyID` | read | IdpPolicy | ID, or $null if not found |
| `Resolve-Five9CloudPermissionID` | read | Permission | ID, or $null if not found |
| `Resolve-Five9CloudPermissionSetID` | read | PermissionSet | ID, or $null if not found |
| `Resolve-Five9CloudReasonCodeId` | read | ReasonCodeId, ReasonCodeName | ID, or $null if not found |
| `Resolve-Five9CloudReasonCodeSetID` | read | ReasonCodeSet | ID, or $null if not found |
| `Resolve-Five9CloudSkillId` | read | SkillId, SkillName | ID, or $null if not found |
| `Resolve-Five9CloudUserIDPPolicy` | read | Username | ID, or $null if not found |
| `Resolve-Five9CloudUserProfileId` | read | UserProfileName | ID, or $null if not found |
| `Resolve-Five9CloudUserUID` | read | Username | ID, or $null if not found |
| `Copy-Five9CloudUser` | WRITE | UserUID, Username, NewUsername*, FirstName*, LastName*, Email*, Status (ACTIVE\|INACTIVE), AutoMigration [switch], Extension, StartDate, HomeNumber, Locale, MobileNumber, PublicName, Timezone, WorkNumber, MustChangePassword [switch], SkipApplications [switch], SkipPermissions [switch], SkipRoles [switch], SkipAgentGroups [switch], SkipMediaTypes [switch], SkipSkills [switch], SkipCircles [switch], SkipReasonCodes [switch] | nothing on success (prints a message); $false on failure |
| `New-Five9CloudPermissionSet` | WRITE | Name*, Description | API response on success; $false on failure |
| `New-Five9CloudUser` | WRITE | Username*, FirstName*, LastName*, Email*, Status (ACTIVE\|INACTIVE), FederationID*, IdPPolicy, IdpPolicyId, Extension, StartDate, HomeNumber, Locale, MobileNumber, Timezone, WorkNumber | nothing, success or failure: verify by re-reading |
| `Add-Five9CloudCannedReportToUser` | WRITE | Username, UserUID, Report* [array], ReportFolder | nothing (prints a message): verify by re-reading |
| `Add-Five9CloudCircleToUser` | WRITE | Username*, UserUID, CircleName*, CircleID | nothing (prints a message): verify by re-reading |
| `Add-Five9CloudPermissionSetToUser` | WRITE | Username*, UserUID, PermissionSet*, SetID | nothing (prints a message): verify by re-reading |
| `Add-Five9CloudPermissionToSet` | WRITE | SetID*, Permission* | nothing (prints a message): verify by re-reading |
| `Add-Five9CloudReasonCodeSetToUser` | WRITE | Username*, UserUID, ReasonCodeSet*, SetID | nothing (prints a message): verify by re-reading |
| `Add-Five9CloudUserProfileToUser` | WRITE | Username [array], UserUID [array], UserProfileName, UserProfileId | nothing (prints a message): verify by re-reading |
| `Set-Five9CloudUserApplication` | WRITE | Username*, Application (adt\|web-java-admin\|scc-admin\|java-admin\|plus-supervisor\|admin-console\|plus-agent\|agent-assist\|reporting)* | nothing on success (prints a message); $false on failure |
| `Set-Five9CloudUserDetails` | WRITE | UserUID, Username, FirstName, LastName, Email, Initials, MobileNumber, WorkNumber, HomeNumber, Timezone, Locale, StartDate, Extension, Mfa (on\|off), IdpFederationId, EmployeeId, CostCenter, Status, AvatarUrl, MustChangePassword [bool] | nothing on success (prints a message); $false on failure |
| `Set-Five9CloudUserMfaPolicy` | WRITE | UserUID, Username, Remove [switch] | nothing (prints a message): verify by re-reading |
| `Set-Five9CloudUserPermission` | WRITE | UserUID, Username, PermissionID, Permission, Remove [switch] | nothing on success (prints a message); $false on failure |
| `Set-Five9CloudUserSecurity` | WRITE | Username*, IdPPolicy*, FederationID* | nothing on success (prints a message); $false on failure |
| `Set-Five9CloudUserStatus` | WRITE, deactivation is disruptive | Username [array], UserUID [array], Action (Activate\|Deactivate)* | nothing, success or failure: verify by re-reading |
| `Set-Five9CloudUserVMEmailSettings` | WRITE | Username, UserUID, CcEmailAddresses [array], AttachVoicemail [bool], EmbedCampaignProfileLayoutFields [bool], Remove [switch] | nothing on success (prints a message); $false on failure |
| `Set-Five9CloudUserVerintSettings` | WRITE | Username, UserUID, Packages (
call-recording\|
call-recording.screen-recording\|
call-recording.quality-monitoring\|
call-recording.quality-monitoring.analytics-driven-quality\|
call-recording.speech-analytics\|
workforce-management\|
performance-management\|
call-recording.advanced-desktop-analytics
) [array], ScreenRecordingDomainName, ScreenRecordingLoginName | nothing (prints a message): verify by re-reading |
| `Remove-Five9CloudUserApplication` | DESTRUCTIVE | UserUID, Username, Application (adt\|web-java-admin\|scc-admin\|java-admin\|plus-supervisor\|admin-console\|plus-agent\|agent-assist\|reporting)* | nothing (prints a message): verify by re-reading |
| `Remove-Five9CloudUserTag` | DESTRUCTIVE | UserUID, Username*, Tag, TagId | nothing on success (prints a message); $false on failure |
| `Remove-Five9CloudUserVerintSettings` | DESTRUCTIVE | UserUID, Username | nothing (prints a message): verify by re-reading |

## Domain settings, tags, schedules, email, digital assistance, audit log

| Function | Effect | Parameters | Output |
|---|---|---|---|
| `Get-Five9CloudConfigEvents` | read | Sort, StartDate, EndDate, TimeZoneOffset | page envelopes: read .items |
| `Get-Five9CloudDigitalAssistance` | read | Sort, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudDomainSettings` | read | none | API response object |
| `Get-Five9CloudDomainTags` | read | Sort, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudDomainVerintPackages` | read | none | list of packages |
| `Get-Five9CloudEmailConfigurations` | read | EmailConfigurationId | one configuration (with -EmailConfigurationId) or a list of configurations |
| `Get-Five9CloudEmailNotificationSettings` | read | none | API response object |
| `Get-Five9CloudInternalCallsSettings` | read | none | API response object |
| `Get-Five9CloudSchedules` | read | Sort, PageCursor, PageLimit, Filter | page envelopes: read .items |
| `Get-Five9CloudServiceAccounts` | read | none | list of service accounts |
| `Get-Five9CloudUtilizationSettings` | read | none | API response object |
| `Resolve-Five9CloudAgentGroupId` | read | AgentGroupId, AgentGroupName | ID, or $null if not found |
| `Resolve-Five9CloudContactFieldId` | read | FieldId, FieldName | ID, or $null if not found |
| `Resolve-Five9CloudDataTableId` | read | DataTableId, DataTableName | ID, or $null if not found |
| `Resolve-Five9CloudDomainAssistance` | read | AssistanceName | ID, or $null if not found |
| `Resolve-Five9CloudDomainTag` | read | TagName | ID, or $null if not found |
| `Resolve-Five9CloudEmailConfigurationId` | read | Email, Type | ID, or $null if not found |
| `Resolve-Five9CloudScheduleId` | read | ScheduleName | ID, or $null if not found |
| `Resolve-Five9CloudServiceAccountId` | read | ServiceAccountName | ID, or $null if not found |
| `Resolve-Five9CloudSpeedDialId` | read | SpeedDialId, SpeedDialCode | ID, or $null if not found |
| `New-Five9CloudSchedule` | WRITE | Name*, Description, DefaultScriptId*, ActionScriptId*, ActionDestination*, ActionReject* [switch], ScriptParameterNames [array], ScriptParameterValues [array] | API response on success; $false on failure |
| `Add-Five9CloudDigitalAssistance` | WRITE | Name*, Response*, RichTextOption (RichTextEmailOnly\|RichControlsMessaging\|NoRichText)* | API response on success; $false on failure |
| `Add-Five9CloudTagScope` | WRITE | Scope (user\|campaign\|skill\|data-table\|agent-group\|speed-dial\|phone-number\|permission)*, Name, TagId (dynamic), TagName (dynamic), Username (dynamic), UserUID (dynamic), CampaignName (dynamic), CampaignId (dynamic), SkillName (dynamic), SkillId (dynamic), DataTableName (dynamic), DataTableId (dynamic), AgentGroupName (dynamic), AgentGroupId (dynamic), SpeedDialCode (dynamic), SpeedDialId (dynamic), PhoneNumber (dynamic), PhoneNumberId (dynamic) | nothing (prints a message): verify by re-reading |
| `Set-Five9CloudDigitalAssistance` | WRITE | AssistanceName*, Response*, RichTextOption (RichTextEmailOnly\|RichControlsMessaging\|NoRichText)* | nothing on success (prints a message); $false on failure |
| `Set-Five9CloudEmailConfiguration` | WRITE | EmailConfigurationId, Email, Type (INBOUND\|OUTBOUND), NewEmail, Protocol (IMAP\|IMAPS\|POP3\|POP3S\|EXCHANGE\|EXCHANGE_WEBMAIL\|GRAPH\|SMTP), ServerHost, Port, Timeout, ConnectionTimeout, CheckServerIdentity [bool], SaveProcessedEmail [bool], ReplyToHeaders [bool], AutoPushbackEmail [bool], AutoPushback4LoggedinUsers [bool], AutoPushbackInterval, ServiceAccountId, ServiceAccountName | API response on success; $false on failure |
| `Set-Five9CloudEmailNotificationSettings` | WRITE | LineUtilizationNotificationEmails [array], MaintenanceNotificationEmails [array], PstnLoginNotificationEmails [array] | API response on success; $false on failure |
| `Set-Five9CloudInternalCallsSettings` | WRITE | TransferTimedOutInternalCalls [bool], InternalCallTimeout (0-3599) | API response on success; $false on failure |
| `Set-Five9CloudSchedule` | WRITE | ScheduleId, ScheduleName, Name, Description, DefaultScriptId, ActionScriptId, ActionDestination*, ActionReject* [switch], ScriptParameterNames [array], ScriptParameterValues [array] | API response on success; $false on failure |
| `Remove-Five9CloudDigitalAssistance` | DESTRUCTIVE | AssistanceId, AssistanceName | nothing on success (prints a message); $false on failure |
| `Remove-Five9CloudSchedule` | DESTRUCTIVE | ScheduleId, ScheduleName | nothing on success (prints a message); $false on failure |
