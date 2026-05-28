function Remove-Five9CloudPhoneNumbers {
    [CmdletBinding(DefaultParameterSetName = 'Direct')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Direct')][string[]]$PhoneNumbers,
        [Parameter(Mandatory, ParameterSetName = 'CSV')][string]$CsvPath,
        [Parameter(ParameterSetName = 'CSV')][string]$ColumnName = 'PhoneNumber'
    )

    $numbersArray = @()

    switch ($PSCmdlet.ParameterSetName) {
        'Direct' { $numbersArray = $PhoneNumbers }
        'CSV' {
            if (-not (Test-Path $CsvPath)) { Write-Error "CSV file not found: $CsvPath"; return }
            $csvData = Import-Csv -Path $CsvPath
            if ($csvData.Count -gt 0 -and -not ($csvData[0].PSObject.Properties.Name -contains $ColumnName)) {
                Write-Error "Column '$ColumnName' not found in CSV. Available columns: $($csvData[0].PSObject.Properties.Name -join ', ')"; return
            }
            $numbersArray = $csvData.$ColumnName | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        }
    }

    $validatedNumbers = foreach ($number in $numbersArray) {
        $clean = $number -replace '\D', ''
        if ($clean -notmatch '^\+') { $clean = "1$clean" -replace '^1{2,}', '1' }
        "+$clean"
    }

    if (-not $validatedNumbers) { Write-Error "No valid phone numbers to process."; return }

    $body = @{ numberIds = @($validatedNumbers) }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/numbers-svc/v1/domains/$($global:Five9.DomainId)/phone-numbers:release" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Phone number(s) removed successfully." } else { Write-Host "Failed to remove phone number(s)."; return $false }
}