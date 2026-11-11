# PSFive9CloudAPI functions

Generated from the module source on 2026-11-11. Effect: read = no changes; WRITE = changes configuration; DESTRUCTIVE / DISRUPTIVE = needs the extra confirmation in SKILL.md. `*` = mandatory (within its parameter set). If the repo is cloned, the `.ps1` files win over this table.


## Phone numbers and ANI groups

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
