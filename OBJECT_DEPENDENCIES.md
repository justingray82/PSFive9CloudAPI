# Object dependencies — check before deleting or releasing

Deleting a Five9 object that something else still references can break call
routing, outbound dialing, or agent logins. The API sometimes refuses with an
"in use" error, and sometimes does not. Treat an "in use" error as a safety
signal, never as something to work around.

Before any `Remove-`, `Reset-`, or number release, an agent must produce a
**dependency report** and get a separate confirmation that names exactly what
will be removed.

## The dependency report

1. **Domain and target.** Domain ID, object type, name, and ID.
2. **Current state backup.** Save the object's full current definition to a
   timestamped JSON file (`backups/<type>-<name>-<yyyyMMdd-HHmmss>.json`) using
   the matching `Get-` function and `ConvertTo-Json -Depth 20`.
3. **References found.** Results of the checks below.
4. **Gaps.** Checks this module cannot perform, which the user must verify in
   the Admin Console. "Nothing found" in a checkable area does not prove the
   object is unused.
5. **Detach plan.** What will be unassigned or reassigned first, in order.
6. **Validation plan.** How the result will be re-read afterwards.

## Checks by object

| Deleting | Check with this module | Verify manually (not covered by the module) |
|---|---|---|
| Phone number (`Remove-Five9CloudPhoneNumbers`) | `Get-Five9CloudCampaignNumbers` for every campaign (DNIS); `Get-Five9CloudAniGroupNumbers` for every ANI group; `Get-Five9CloudUserDetails` for user DIDs if the user record exposes them; `Get-Five9CloudCampaignProfileDetails` for default ANIs | IVR scripts that dial or reference the number; external carrier porting plans. Released numbers may not be recoverable. |
| Campaign (`Remove-Five9CloudCampaign`) | Campaign state via `Get-Five9CloudCampaignDetails` (must be stopped); assigned numbers, skills, connectors, tags | IVR scripts and schedules that transfer to the campaign; speed dials; reports filtered on it |
| Campaign profile (`Remove-Five9CloudCampaignProfile`) | `Get-Five9CloudOutboundCampaignDetails` for each outbound campaign to find which use the profile | Saved filters or lists configured only in the profile |
| Schedule (`Remove-Five9CloudSchedule`) | `Get-Five9CloudSchedules` (definition backup) | Campaigns and IVR scripts that reference the schedule |
| Digital assistance entry | `Get-Five9CloudDigitalAssistance` (definition backup) | Agent workflows relying on it |
| ANI group number (`Remove-Five9CloudAniGroupNumber`) | Remaining numbers in the group; profiles using the group via `Get-Five9CloudCampaignProfileDetails` | Whether the group becomes empty for a live outbound campaign |
| Campaign skill/number/connector/tag (`Remove-Five9CloudCampaign*`) | Current assignments via the matching `Get-` | Whether removal leaves an inbound campaign with no skill or no DNIS |
| User application, tag, Verint settings | Current values via the matching `Get-` | Downstream WFO/QM integrations |

## Campaign control actions

`Stop-`, `Reset-`, and `Reset-Five9CloudCampaignDialingListPositions` are not
deletions but have immediate live impact (dropped dialing, restarted lists).
Treat them with the same confirmation: name the campaign, say what will happen
to in-progress calls and list positions, and confirm timing with the user.
