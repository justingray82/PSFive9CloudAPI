# PSFive9CloudAPI Installation Script
# Run this script to install the PSFive9CloudAPI module
Write-Host "Installing PSFive9CloudAPI module..." -ForegroundColor Green

try {
    # Get available module paths from PSModulePath environment variable
    $AvailablePaths = $env:PSModulePath -split ';' | Where-Object { $_ -and (Test-Path $_) }
    
    # Determine the best module path
    # Prefer user profile paths over system paths
    $ModulesPath = $AvailablePaths | Where-Object { 
        $_ -like "*$env:USERPROFILE*" -or $_ -like "*Documents*" 
    } | Select-Object -First 1
    
    # If no user path found, use the first available path
    if (-not $ModulesPath) {
        $ModulesPath = $AvailablePaths | Select-Object -First 1
    }
    
    # If still no path, create default user path
    if (-not $ModulesPath) {
        $ModulesPath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"
        New-Item -ItemType Directory -Path $ModulesPath -Force | Out-Null
    }
    
    Write-Host "Using module path: $ModulesPath" -ForegroundColor Cyan
    
    $ModulePath = Join-Path $ModulesPath "PSFive9CloudAPI"
    $TempZip = "$env:TEMP\PSFive9CloudAPI.zip"
    $DownloadUrl = "https://github.com/justingray82/PSFive9CloudAPI/archive/refs/heads/main.zip"
    
    # Create modules directory if it doesn't exist
    Write-Host "Creating modules directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ModulesPath -Force | Out-Null
    
    # Remove existing module if present
    if (Test-Path $ModulePath) {
        Write-Host "Removing existing module..." -ForegroundColor Yellow
        if (Get-Module PSFive9CloudAPI -ErrorAction SilentlyContinue) {
            Remove-Module PSFive9CloudAPI -Force
            Write-Host "Unloaded existing module from memory" -ForegroundColor Yellow
        }
        Start-Sleep -Milliseconds 500
        Remove-Item $ModulePath -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Download the ZIP file
    Write-Host "Downloading module from GitHub..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempZip
    
    # Extract the ZIP file
    Write-Host "Extracting module..." -ForegroundColor Yellow
    Expand-Archive -Path $TempZip -DestinationPath $env:TEMP -Force
    
    # Move the extracted folder to the correct location and rename it
    Write-Host "Installing module..." -ForegroundColor Yellow
    Move-Item -Path "$env:TEMP\PSFive9CloudAPI-main" -Destination $ModulePath -Force
    
    # Clean up temporary files
    Write-Host "Cleaning up temporary files..." -ForegroundColor Yellow
    Remove-Item $TempZip -Force
    
    Write-Host "PSFive9CloudAPI module installed successfully!" -ForegroundColor Green
    Write-Host "Module location: $ModulePath" -ForegroundColor Cyan
    Write-Host "You can now import the module with: Import-Module PSFive9CloudAPI" -ForegroundColor Cyan
    
} catch {
    Write-Error "Installation failed: $($_.Exception.Message)"
    exit 1
}