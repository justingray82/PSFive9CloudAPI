function Remove-Five9CloudPhoneNumbers {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Direct')]
        [string[]]$PhoneNumbers,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'CSV')]
        [string]$CsvPath,
        
        [Parameter(ParameterSetName = 'CSV')]
        [string]$ColumnName = 'PhoneNumber',

        [Parameter()]
        [string]$DefaultCountryCode = '+1'  # Default to US/Canada
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    # Initialize the phone numbers array
    $numbersArray = @()
    
    # Process based on parameter set
    switch ($PSCmdlet.ParameterSetName) {
        'Direct' {
            # Split the comma-separated string into an array
            # Remove any spaces and split by comma
            $numbersArray = $PhoneNumbers -split ',' | ForEach-Object { $_.Trim() }
            Write-Verbose "Using directly provided phone numbers: $($numbersArray -join ', ')"
        }
        
        'CSV' {
            # Load phone numbers from CSV
            if (-not (Test-Path -Path $CsvPath)) {
                throw "CSV file not found: $CsvPath"
            }
            
            try {
                $csvData = Import-Csv -Path $CsvPath
                
                # Check if the specified column exists
                if ($csvData.Count -gt 0 -and -not ($csvData[0].PSObject.Properties.Name -contains $ColumnName)) {
                    throw "Column '$ColumnName' not found in CSV. Available columns: $($csvData[0].PSObject.Properties.Name -join ', ')"
                }
                
                # Extract phone numbers from the specified column
                $numbersArray = $csvData | ForEach-Object {
                    $_.$ColumnName
                } | Where-Object { 
                    # Filter out empty or null values
                    -not [string]::IsNullOrWhiteSpace($_) 
                }
                
                Write-Verbose "Loaded $($numbersArray.Count) phone numbers from CSV column '$ColumnName'"
            }
            catch {
                throw "Error reading CSV file: $_"
            }
        }
    }
    
    # Validate and normalize phone numbers
    $validatedNumbers = @()
    foreach ($number in $numbersArray) {
        # Clean the number - remove spaces, dashes, parentheses, periods
        $cleanedNumber = $number.Trim() -replace '[\s\-\(\)\.]', ''
        
        # Check different formats and normalize
        if ($cleanedNumber -match '^\+\d{11,15}$') {
            # Already has + and correct length - use as is
            $validatedNumbers += $cleanedNumber
            Write-Verbose "Number already formatted correctly: $cleanedNumber"
        }
        elseif ($cleanedNumber -match '^1\d{10}$') {
            # Starts with 1 but no + (US format without +)
            $formattedNumber = "+$cleanedNumber"
            $validatedNumbers += $formattedNumber
            Write-Verbose "Added + to number: $number -> $formattedNumber"
        }
        elseif ($cleanedNumber -match '^\d{10}$') {
            # Just 10 digits - assume US/Canada number
            $formattedNumber = "${DefaultCountryCode}${cleanedNumber}"
            $validatedNumbers += $formattedNumber
            Write-Verbose "Added $DefaultCountryCode to number: $number -> $formattedNumber"
        }
        elseif ($cleanedNumber -match '^\d{11}$' -and $cleanedNumber -notmatch '^1\d{10}$') {
            # 11 digits but doesn't start with 1 - likely missing +
            $formattedNumber = "+$cleanedNumber"
            $validatedNumbers += $formattedNumber
            Write-Verbose "Added + to international number: $number -> $formattedNumber"
        }
        else {
            Write-Warning "Invalid phone number format skipped: $number (cleaned: $cleanedNumber)"
        }
    }
    
    if ($validatedNumbers.Count -eq 0) {
        throw "No valid phone numbers to process"
    }
    
    # Build the request body
    $body = @{
        numberIds = $validatedNumbers
    } | ConvertTo-Json
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/numbers-svc/v1/domains/$($global:Five9CloudToken.DomainId)/phone-numbers:release"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body $body
    } catch {
        Write-Error "Failed to remove number(s): $_"
    }
}