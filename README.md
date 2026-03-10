# PSFive9CloudAPI

A PowerShell module designed to simplify interacting with the Five9 Cloud APIs. It supports PowerShell 5.1 and PowerShell 7+, enabling you to authenticate using OAuth2 or Basic authentication and perform operations against Five9 endpoints.

## Features

- Easy-to-use PowerShell functions for common Five9 API tasks
- Supports multiple authentication methods:
  - **ApiControl**: OAuth2 authentication with Client ID/Client Secret
  - **CloudAuth**: Basic authentication with Username/Password
  - **NGRest**: Basic authentication with Username/Password
- Compatible with multiple regions: US, CA, EU, IN, UK

## Quick Installation
```powershell
irm "https://raw.githubusercontent.com/justingray82/PSFive9CloudAPI/main/Install-PSFive9CloudAPI.ps1" | iex
Import-Module PSFive9CloudAPI -Force
```

## Usage

### CloudAuth and NG REST Authentication (Basic)

Connect using Username and Password. You'll be prompted to save credentials for future use:
```powershell
Connect-Five9Cloud -DomainId "12345" -Username "user@domain.com" -Password "password"
```

### ApiControl Authentication (OAuth2)

Connect using ClientID and ClientSecret. You'll be prompted to save credentials for future use:
```powershell
Connect-Five9Cloud -DomainId "12345" -ClientID "ClientID12345" -ClientSecret "Secret67890"
```

### Regional Support

Specify a region other than US:
```powershell
Connect-Five9Cloud -DomainId "12345" -Username "user@domain.com" -Password "password" -Region "EU"
```

## Requirements

- PowerShell 5.1 or later
- API access to Five9 with valid credentials
- Network access to Five9 Cloud API endpoints
- Admin Console Application Access

## Disclaimer

This repository contains sample code which is not an official Five9 resource. It is intended solely for educational and illustrative purposes to demonstrate possible ways to interact with Five9 APIs.

**Under the MIT License:**

- This is not officially endorsed or supported software by Five9
- Any customizations, modifications, or deployments made with this code are done at your own risk and sole responsibility
- The code may not account for all use cases or meet specific requirements without further development
- Five9 assumes no liability and provides no support for issues arising from the use of this code

For production-ready tailored implementations, we strongly recommend working with Five9's Professional Services and Technical Account Management teams.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License - See LICENSE file for details
