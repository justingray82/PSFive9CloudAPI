function Add-Five9CloudDialingRule {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        # Region Restriction Parameters
        [Parameter()]
        [string]$RegionRestrictionType,

        [Parameter()]
        [string]$RegionName,

        [Parameter()]
        [string[]]$AdditionalContactRegions,

        # Date Restriction Parameters
        [Parameter()]
        [string]$DateRestrictionType,

        [Parameter()]
        [ValidateSet('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')]
        [string[]]$DaysOfWeek,

        # Time Restriction Parameters
        [Parameter()]
        [string]$TimeRestrictionType,

        [Parameter()]
        [ValidateRange(0, 23)]
        [int]$StartHour,

        [Parameter()]
        [ValidateRange(0, 59)]
        [int]$StartMinute,

        [Parameter()]
        [ValidateRange(0, 23)]
        [int]$EndHour,

        [Parameter()]
        [ValidateRange(0, 59)]
        [int]$EndMinute,

        # General Parameters
        [Parameter()]
        [string]$TimeZone = "",

        [Parameter()]
        [bool]$ApplyToManualCalls = $false
    )

        # Build the request body
        $body = @{
            name = $Name
            timeZone = $TimeZone
            applyToManualCalls = $ApplyToManualCalls
        }

        # Build region restriction if parameters provided
        if ($RegionRestrictionType) {
            $body.regionRestriction = @{
                type = $RegionRestrictionType
            }

            if ($RegionName -or $AdditionalContactRegions) {
                $body.regionRestriction.standard = @{}
                
                if ($RegionName) {
                    $body.regionRestriction.standard.regionName = $RegionName
                }
                
                if ($AdditionalContactRegions) {
                    $body.regionRestriction.standard.additionalContactRegions = $AdditionalContactRegions
                }
            }
        }

        # Build date restriction if parameters provided
        if ($DateRestrictionType) {
            $body.dateRestriction = @{
                type = $DateRestrictionType
            }

            if ($DaysOfWeek) {
                $body.dateRestriction.daysOfWeek = @{
                    days = $DaysOfWeek
                }
            }
        }

        # Build time restriction if parameters provided
        if ($TimeRestrictionType) {
            $body.timeRestriction = @{
                type = $TimeRestrictionType
            }

            if ($PSBoundParameters.ContainsKey('StartHour') -or 
                $PSBoundParameters.ContainsKey('StartMinute') -or 
                $PSBoundParameters.ContainsKey('EndHour') -or 
                $PSBoundParameters.ContainsKey('EndMinute')) {
                
                $body.timeRestriction.timeRange = @{}
                
                if ($PSBoundParameters.ContainsKey('StartHour')) {
                    $body.timeRestriction.timeRange.startHour = $StartHour
                }
                if ($PSBoundParameters.ContainsKey('StartMinute')) {
                    $body.timeRestriction.timeRange.startMinute = $StartMinute
                }
                if ($PSBoundParameters.ContainsKey('EndHour')) {
                    $body.timeRestriction.timeRange.endHour = $EndHour
                }
                if ($PSBoundParameters.ContainsKey('EndMinute')) {
                    $body.timeRestriction.timeRange.endMinute = $EndMinute
                }
            }
        }

        # Convert to JSON
        $jsonBody = $body | ConvertTo-Json -Depth 10

        Write-Verbose "Request Body: $jsonBody"

        if (-not (Test-Five9CloudConnection -AuthType RestApi)) { return }
    
        $uri = "$($global:Five9CloudToken.RestBaseUrl)/v1/domains/$($global:Five9CloudToken.DomainId)/dialing-rules"
    
        $headers = @{
            Authorization = "Basic $($global:Five9CloudToken.RestBasicAuth)"
            "Content-Type" = "application/json"
            "Accept" = "application/json"
        }

    try {
        Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body ($body | ConvertTo-Json -Depth 10)
    } catch {
        Write-Error "Failed to add dialing rule: $_"
    }

}