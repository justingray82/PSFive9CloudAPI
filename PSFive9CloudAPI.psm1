# Auto-import public and private function scripts

try {
    $public = Get-ChildItem -Path "$PSScriptRoot\Public\" -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue |
              Where-Object { $_.Name -notmatch '\.Tests\.ps1' } |
              Sort-Object FullName
} catch {}

try {
    $private = Get-ChildItem -Path "$PSScriptRoot\Private\" -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue |
               Where-Object { $_.Name -notmatch '\.Tests\.ps1' } |
               Sort-Object FullName
} catch {}

$toImport = @()
$toImport += $public
$toImport += $private

# Dot source all valid scripts
foreach ($file in $toImport) {
    try {
        . $file.FullName
        Write-Verbose "Imported $($file.FullName)"
    } catch {
        Write-Error -Message "Failed to import function '$($file.Name)': $($_.Exception.Message)"
    }
}

# Export all public functions (based on filenames)
$exportedFunctions = $public | ForEach-Object { $_.BaseName }
Export-ModuleMember -Function $exportedFunctions