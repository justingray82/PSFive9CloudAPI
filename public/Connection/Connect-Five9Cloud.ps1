function Connect-Five9Cloud {
    [CmdletBinding(DefaultParameterSetName = 'CloudAuth')]
    param (
        # Common Parameters
        [Parameter(Mandatory = $true)]
        [string]$DomainId,
        
        [Parameter(ParameterSetName = 'CloudAuth')]
        [Parameter(ParameterSetName = 'ApiAccessControl')]
        [ValidateSet('us', 'uk', 'eu', 'ca')]
        [string]$Region = 'us',

        [Parameter(ParameterSetName = 'CloudAuth')]
        [Parameter(ParameterSetName = 'ApiAccessControl')]
        [Parameter(ParameterSetName = 'ExistingAuth')]
        [ValidateSet('prod', 'alpha')]
        [string]$Environment = 'prod',
        
        # CloudAuth/REST API Parameters (Default)
        [Parameter(ParameterSetName = 'CloudAuth', Mandatory = $false)]
        [string]$Username,
        
        [Parameter(ParameterSetName = 'CloudAuth', Mandatory = $false)]
        [string]$Password,
        
        [Parameter(ParameterSetName = 'CloudAuth')]
        [switch]$CloudAuthOnly,  # Only authenticate to CloudAuth, not REST API
        
        # API Access Control Parameters
        [Parameter(ParameterSetName = 'ApiAccessControl', Mandatory = $true)]
        [string]$ClientId,
        
        [Parameter(ParameterSetName = 'ApiAccessControl', Mandatory = $true)]
        [string]$ClientSecret,
        
        [Parameter(ParameterSetName = 'ApiAccessControl')]
        [switch]$ApiAccessControl,
        
        # Existing Authorization Parameter
        [Parameter(ParameterSetName = 'ExistingAuth')]
        [bool]$ExistingAuthorization,
        
        [Parameter(ParameterSetName = 'ExistingAuth')]
        [ValidateSet('CloudAuth', 'ApiAccessControl')]
        [string]$AuthEndpoint = 'CloudAuth',
        
        # Credential Management
        [switch]$SaveCredentials,
        [switch]$ForceNewCredentials  # Force prompt even if saved credentials exist
    )

    $global:Five9CloudToken = @{
        # Token Storage
        ApiAccessControl = $null
        CloudAuth = $null
        RestApi = $null
    
        # Base URLs for existing functions
        ApiBaseUrl = $null      # For CloudAuth and API Access Control
        RestBaseUrl = "https://api.five9.com/restadmin/api"  # Static REST API URL
    
        # Common Properties
        AccessToken = $null     # For bearer token auth
        RestBasicAuth = $null   # For basic auth
        DomainId = $null
        Region = $null
        ActiveAuthType = $null
        ExpiresAt = $null
    }

    $global:Five9CloudCredentialPath = "$env:USERPROFILE\.five9cloud"
    
    # Initialize credential path
    if (-not (Test-Path $global:Five9CloudCredentialPath)) {
        New-Item -ItemType Directory -Path $global:Five9CloudCredentialPath -Force | Out-Null
    }
    
    # Store domain and region
    $global:Five9CloudToken.DomainId = $DomainId
    $global:Five9CloudToken.Region = $Region
    
    # Set ApiBaseUrl based on region
    $global:Five9CloudToken.ApiBaseUrl = "https://api.$Environment.$Region.five9.net"
    
    # RestBaseUrl is always static
    $global:Five9CloudToken.RestBaseUrl = "https://api.five9.com/restadmin/api"
    
    # Determine authentication type
    $authType = $PSCmdlet.ParameterSetName
    
    if ($authType -eq 'ExistingAuth') {
        $authType = $AuthEndpoint
        # Try to load saved credentials
        if (-not (Load-Five9CloudCredentials -DomainId $DomainId -AuthType $authType)) {
            Write-Warning "No saved credentials found for Domain: $DomainId, Auth Type: $authType"
            Write-Host "Please provide credentials:" -ForegroundColor Yellow
            
            # Switch to appropriate auth flow
            if ($authType -eq 'ApiAccessControl') {
                $ClientId = Read-Host "Enter Client ID"
                $ClientSecret = Read-Host "Enter Client Secret" -AsSecureString
                $ApiAccessControl = $true
            }
            else {
                $authType = 'CloudAuth'
                $Username = Read-Host "Enter Username"
                $Password = Read-Host "Enter Password" -AsSecureString
            }
        }
    }
    
    # Handle saved credentials if not forcing new ones
    if (-not $ForceNewCredentials) {
        $savedCreds = Load-Five9CloudCredentials -DomainId $DomainId -AuthType $authType
        if ($savedCreds) {
            Write-Host "Found saved credentials for Domain: $DomainId" -ForegroundColor Gray
            $useSaved = Read-Host "Use saved credentials? (Y/N)"
            if ($useSaved -eq 'Y') {
                if ($authType -eq 'ApiAccessControl') {
                    $ClientId = $savedCreds.ClientId
                    $ClientSecret = $savedCreds.ClientSecret
                }
                else {
                    $Username = $savedCreds.Username
                    if ($savedCreds.Password) {
                        $Password = Convert-SecureStringToPlainText -SecureString $savedCreds.Password
                    }
                }
                # Update region if it was saved
                if ($savedCreds.Region) {
                    $Region = $savedCreds.Region
                    $global:Five9CloudToken.Region = $Region
                    $global:Five9CloudToken.ApiBaseUrl = "https://api.$Environment.$Region.five9.net"
                }
            }
        }
    }
    
    # Prompt for missing credentials
    if ($authType -eq 'ApiAccessControl' -or $ApiAccessControl) {
        if (-not $ClientId) { $ClientId = Read-Host "Enter Client ID" }
        if (-not $ClientSecret) { $ClientSecret = Read-Host "Enter Client Secret" }
        
        $result = Connect-ApiAccessControl -DomainId $DomainId -Region $Region -Environment $Environment `
                                          -ClientId $ClientId -ClientSecret $ClientSecret
    }
    else {
        # CloudAuth (and optionally REST API)
        if (-not $Username) { $Username = Read-Host "Enter Username" }
        if (-not $Password) { $Password = Read-Host "Enter Password" }
        
        $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
        $result = Connect-CloudAuth -DomainId $DomainId -Region $Region `
                                   -Username $Username -Password $SecurePassword
        
        # Also connect to REST API unless CloudAuthOnly is specified
        if ($result -and -not $CloudAuthOnly) {
            $restResult = Connect-RestApi -Username $Username -Password $SecurePassword
            $result = $result -and $restResult
        }
    }
    
    # Handle credential saving
    if ($result -and ($SaveCredentials -or (-not $SaveCredentials -and -not $ExistingAuthorization))) {
        if (-not $SaveCredentials -and (-not $savedCreds)) {
            $save = Read-Host "Save credentials for future use? (Y/N)"
            $SaveCredentials = ($save -eq 'Y')
        }
        
        if ($SaveCredentials) {
            $credType = if ($ApiAccessControl) { 'ApiAccessControl' } else { 'CloudAuth' }
            Save-Five9CloudCredentials -DomainId $DomainId -AuthType $credType `
                                      -Username $Username -Password $SecurePassword `
                                      -ClientId $ClientId -ClientSecret $ClientSecret `
                                      -Region $Region
        }
    }
    
    if ($result) {
        Write-Host "Connection to Domain $DomainId successful." -ForegroundColor Gray
    }
    else {
        Write-Error "Failed to connect to Five9 Cloud"
    }
    
    #return $result
}
#endregion

#region Individual Authentication Functions
function Connect-ApiAccessControl {
    param (
        [string]$DomainId,
        [string]$Region,
        [string]$Environment,
        [string]$ClientId,
        [string]$ClientSecret
    )
    
    try {
        $uri = "https://api.$Environment.$Region.five9.net/oauth2/v1/token"
        
        $body = @{
            grant_type = "client_credentials"
            client_id = $ClientId
            client_secret = $ClientSecret
            scope = "api"
        }
        
        $response = Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/x-www-form-urlencoded" -Body $body
        
        # Store token details
        $global:Five9CloudToken.ApiAccessControl = @{
            AccessToken = $response.access_token
            TokenType = $response.token_type
            ExpiresIn = $response.expires_in
            ExpiresAt = (Get-Date).AddSeconds($response.expires_in - 60)  # Subtract 60 seconds for safety margin
            Scope = $response.scope
        }
        
        # Set main token properties for existing functions
        $global:Five9CloudToken.AccessToken = $response.access_token
        $global:Five9CloudToken.ExpiresAt = $global:Five9CloudToken.ApiAccessControl.ExpiresAt
        $global:Five9CloudToken.ActiveAuthType = 'ApiAccessControl'
        
        # Clear sensitive data
        #[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        
        return $true
    }
    catch {
        Write-Error "Failed to authenticate to API Access Control: $_"
        return $false
    }
}

function Connect-CloudAuth {
    param (
        [string]$DomainId,
        [string]$Region,
        [string]$Username,
        [SecureString]$Password
    )
    
    try {
        $uri = "https://api.prod.$Region.five9.net/cloudauthsvcs/v1/admin/login"
        
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

        $authString = "${Username}:${plainPassword}"
        $encodedCreds = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($authString))
        
    # Create JSON body with grant_type
    $body = @{
        grant_type = "client_credentials"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers @{
        Authorization = "Basic $encodedCreds"
        'Content-Type' = 'application/json'
    } -Body $body
        
        # Store token details
        $global:Five9CloudToken.CloudAuth = @{
            AccessToken = $response.access_token
            TokenType = $response.token_type
            ExpiresIn = $response.expires_in
            ExpiresAt = (Get-Date).AddSeconds($response.expires_in - 60)  # Subtract 60 seconds for safety margin
            Username = $Username
        }
        
        # Set main token properties for existing functions
        $global:Five9CloudToken.AccessToken = $response.access_token
        $global:Five9CloudToken.ExpiresAt = $global:Five9CloudToken.CloudAuth.ExpiresAt
        
        if ($global:Five9CloudToken.ActiveAuthType -ne 'RestApi') {
            $global:Five9CloudToken.ActiveAuthType = 'CloudAuth'
        }
        
        # Clear sensitive data
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        
        return $true
    }
    catch {
        Write-Error "Failed to authenticate to CloudAuth: $_"
        return $false
    }
}

function Connect-RestApi {
    param (
        [string]$Username,
        [SecureString]$Password
    )
    
    try {
        # Convert credentials to Basic auth format
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        
        $credentials = "$($Username):$($plainPassword)"
        $encodedCreds = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($credentials))
        
        # Store REST API credentials
        $global:Five9CloudToken.RestApi = @{
            Authorization = "Basic $encodedCreds"
            Username = $Username
        }
        
        # Set Authorization for existing functions that might use it
        $global:Five9CloudToken.RestBasicAuth = "$encodedCreds"
        
        # Clear sensitive data
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

        return $true
         
    }
    catch {
        Write-Error "Failed to authenticate to REST API: $_"
        return $false
    }
}

function Save-Five9CloudCredentials {
    param (
        [string]$DomainId,
        [string]$AuthType,
        [string]$Username,
        [SecureString]$Password,
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$Region
    )
    
    $credFile = Join-Path $global:Five9CloudCredentialPath "$DomainId.$AuthType.cred"
    
    $credObject = @{
        DomainId = $DomainId
        AuthType = $AuthType
        Region = $Region
        Timestamp = Get-Date
    }
    
    if ($AuthType -eq 'CloudAuth') {
        $credObject.Username = $Username
        if ($Password) {
            # Convert SecureString to encrypted string
            $credObject.Password = ConvertFrom-SecureString $Password
        }
    }
    elseif ($AuthType -eq 'ApiAccessControl') {
        $credObject.ClientId = $ClientId
        if ($ClientSecret) {
            # Convert SecureString to encrypted string
            $credObject.ClientSecret = $ClientSecret
        }
    }
    
    try {
        $credObject | ConvertTo-Json | Out-File $credFile -Force
        Write-Verbose "Credentials saved to $credFile"
        return $true
    }
    catch {
        Write-Warning "Failed to save credentials: $_"
        return $false
    }
}

function Load-Five9CloudCredentials {
    param (
        [string]$DomainId,
        [string]$AuthType
    )
    
    $credFile = Join-Path $global:Five9CloudCredentialPath "$DomainId.$AuthType.cred"
    
    if (-not (Test-Path $credFile)) {
        Write-Verbose "No saved credentials found at $credFile"
        return $null
    }
    
    try {
        $credObject = Get-Content $credFile | ConvertFrom-Json
        
        # Convert encrypted strings back to SecureString
        if ($credObject.Password) {
            $credObject.Password = ConvertTo-SecureString $credObject.Password
        }
        if ($credObject.ClientSecret) {
            $credObject.ClientSecret = ConvertTo-SecureString $credObject.ClientSecret
        }
        
        Write-Verbose "Loaded credentials from $credFile"
        return $credObject
    }
    catch {
        Write-Warning "Failed to load credentials: $_"
        return $null
    }
}

function Remove-Five9CloudCredentials {
    [CmdletBinding()]
    param (
        [string]$DomainId,
        [ValidateSet('All', 'ApiAccessControl', 'CloudAuth')]
        [string]$AuthType = 'All'
    )
    
    if ($AuthType -eq 'All') {
        $files = Get-ChildItem -Path $global:Five9CloudCredentialPath -Filter "$DomainId.*.cred" -ErrorAction SilentlyContinue
    }
    else {
        $files = Get-ChildItem -Path $global:Five9CloudCredentialPath -Filter "$DomainId.$AuthType.cred" -ErrorAction SilentlyContinue
    }
    
    if (-not $files) {
        Write-Warning "No saved credentials found for Domain: $DomainId"
        return
    }
    
    foreach ($file in $files) {
        try {
            Remove-Item $file.FullName -Force
            Write-Host "Removed saved credentials: $($file.Name)" -ForegroundColor Gray
        }
        catch {
            Write-Warning "Failed to remove $($file.Name): $_"
        }
    }
}

function Convert-SecureStringToPlainText {
    param (
        [SecureString]$SecureString
    )
    
    if (-not $SecureString) {
        return $null
    }
    
    try {
        $netCred = New-Object System.Net.NetworkCredential("", $SecureString)
        return $netCred.Password
    }
    catch {
        Write-Error "Failed to convert secure string: $_"
        return $null
    }
}