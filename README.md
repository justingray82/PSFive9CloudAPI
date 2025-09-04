# PSFive9CloudAPI

A PowerShell module designed to simplify interacting with the new Five9 Cloud APIs.
It supports PowerShell 5.1 and PowerShell 7+, enabling you to authenticate using OAuth2 and perform operations against Five9 endpoints.

Features
Easy-to-use PowerShell functions for common Five9 API tasks.

Supports OAuth2 authentication.

Compatible with multiple regions: US, CA, EU, IN, UK.

# Installation
1. Set Operating Directory

  ```cd {{Your Module Folder}}```

2. Clone the repository

  ```git clone https://github.com/justingray82/PSFive9CloudAPI.git```

3. Import the Module
  
  ```Import-Module PSFive9CloudAPI -Force```

# Usage

Connects to ApiControl with provided CustomerKey/SecretId. Prompted to save credential file

```Connect-Five9Cloud -DomainId "12345" -AuthEndpoint "ApiControl" -CustomerKey "CustomerKey12345" -SecretId "SecretId67890"```

Connects to CloudAuth with provided Username/Password. Prompted to save credential file

```Connect-Five9Cloud -DomainId "12345" -AuthEndpoint "CloudAuth" -Username "user" -Password "password"```

Uses ApiControl if you specify it

```Connect-Five9Cloud -DomainId "12345" -ExistingAuthorization $true -AuthEndpoint "ApiControl"```

Prompts to choose if both credential types are stored

```Connect-Five9Cloud -DomainId "12345" -ExistingAuthorization $true```
 

<ul>Parameters:


DomainId (Required): Your Five9 domain ID.
CustomerKey (Required): Your API client ID.
SecretId (Required): Your API client secret.
Region (Optional): One of us, ca, eu, in, uk. Defaults to us.</ul>


# Requirements
PowerShell 5.1 or later.
API access to Five9 with valid credentials.
Network access to the Five9 Cloud API endpoints.

# Disclaimer
This repository contains sample code which is not an official Five9 resource. It is intended solely for educational and illustrative purposes to demonstrate possible ways to interact with Five9 APIs.

Under the MIT License:

This is not officially endorsed or supported software by Five9.

Any customizations, modifications, or deployments made with this code are done at your own risk and sole responsibility.

The code may not account for all use cases or meet specific requirements without further development.

Five9 assumes no liability and provides no support for issues arising from the use of this code.

For production-ready tailored implementations, we strongly recommend working with Five9’s Professional Services and Technical Account Management teams.
