# PSFive9CloudAPI functions

Generated from the module source on 2026-11-11. Effect: read = no changes; WRITE = changes configuration; DESTRUCTIVE / DISRUPTIVE = needs the extra confirmation in SKILL.md. `*` = mandatory (within its parameter set). If the repo is cloned, the `.ps1` files win over this table.


## Users, access, and user settings

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
