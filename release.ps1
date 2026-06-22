# Error pause
$ErrorActionPreference = "Stop"

# Output type selection
$createZip = $false

while ($true) {
    $response = (Read-Host "Create as ZIP? (Y/N)").Trim().ToUpper()

    if ($response -eq "Y") {
        $createZip = $true
        break
    }

    if ($response -eq "N") {
        $createZip = $false
        break
    }

    Clear-Host
}
Write-Host

# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Current working directory (where script was executed from)
$currentDir = Get-Location
$currentFolderName = Split-Path $currentDir -Leaf

# -----------------------------
# Folders inside "libraries" / "disabled_libraries" that should NOT be copied to "My Libraries"
# Leave empty @() if you want to copy everything
# -----------------------------
$excludedLibraryFolders = @(
<#      "UndertaleMonstersRecreation",
    "UndertaleBorders" #>
)

# Read version from mod.json
$modJsonPath = Join-Path $scriptDir "mod.json"

if (-not (Test-Path $modJsonPath)) {
    Clear-Host
    Write-Host "ERROR: mod.json not found in script directory." -ForegroundColor Red
    Write-Host
    cmd /c pause
    exit 1
}

$modJsonContent = Get-Content $modJsonPath -Raw
$versionMatch = [regex]::Match($modJsonContent, '"version"\s*:\s*"([^"]+)"')

if (-not $versionMatch.Success) {
    Clear-Host
    Write-Host "ERROR: Version not found in mod.json." -ForegroundColor Red
    Write-Host
    cmd /c pause
    exit 1
}

$version = $versionMatch.Groups[1].Value
$versionFormatted = $version -replace '\.', '_'

$idMatch = [regex]::Match($modJsonContent, '"id"\s*:\s*"([^"]+)"')

if (-not $idMatch.Success) {
    Clear-Host
    Write-Host "ERROR: ID not found in mod.json." -ForegroundColor Red
    Write-Host
    cmd /c pause
    exit 1
}

$modId = $idMatch.Groups[1].Value

# Put folder on Desktop
$desktopPath = [Environment]::GetFolderPath("Desktop")
$outputFolderName = "${modId}_$versionFormatted"
$outputFolderPath = Join-Path $desktopPath $outputFolderName

# Temporary staging directory
$tempDir = Join-Path $env:TEMP ("zip_temp_" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $tempDir | Out-Null

# Create CurrentFolderName root in zip
$currentFolderInZip = Join-Path $tempDir $currentFolderName
New-Item -ItemType Directory -Path $currentFolderInZip | Out-Null

# Copy entire current directory into it
Copy-Item -Path (Join-Path $currentDir "*") `
          -Destination $currentFolderInZip `
          -Recurse -Force

# Add "My Libraries" at root
$myLibrariesDestination = Join-Path $tempDir "My Libraries"
New-Item -ItemType Directory -Path $myLibrariesDestination | Out-Null

# Add "My Tools" folder logic
$localToolsPath = Join-Path $scriptDir "tools"
$myToolsDestination = Join-Path $tempDir "My Tools"

if ((Test-Path $localToolsPath) -and (@(Get-ChildItem -Path $localToolsPath -Directory).Count -gt 0)) {

    # Create the "My Tools" base folder first
    New-Item -ItemType Directory -Path $myToolsDestination -Force | Out-Null

    # Get all subdirectories inside "tools"
    $toolFolders = Get-ChildItem -Path $localToolsPath -Directory

    foreach ($toolFolder in $toolFolders) {
        $toolVersionFile = Join-Path $toolFolder.FullName "version.txt"

        if (Test-Path $toolVersionFile) {
            # Read the 1-line version and trim any trailing spaces/newlines
            $toolVersion = (Get-Content $toolVersionFile -TotalCount 1).Trim()
            $toolVersionFormatted = $toolVersion -replace '\.', '_'

            # Combine the folder name and version with the new prefix
            $newFolderName = "(Tool) $($toolFolder.Name)_v$toolVersionFormatted"
            $toolZipName = "$newFolderName.zip"
            $toolZipPath = Join-Path $myToolsDestination $toolZipName

            # Create a temporary folder just for this tool to filter out version.txt
            $toolTempStage = Join-Path $tempDir "stage_$($toolFolder.Name)"
            New-Item -ItemType Directory -Path $toolTempStage -Force | Out-Null

            # Copy all items from this specific tool folder except "version.txt"
            Get-ChildItem -Path $toolFolder.FullName | Where-Object {$_.Name -ne "version.txt"} | Copy-Item -Destination $toolTempStage -Recurse -Force

            # Zip the staged folder contents into "My Tools"
            Compress-Archive -Path (Join-Path $toolTempStage "*") -DestinationPath $toolZipPath -Force

            # Clean up the temporary folder
            Remove-Item $toolTempStage -Recurse -Force

            Write-Host "Added tool ZIP: $toolZipName"
        } else {
            Clear-Host
            Write-Host "ERROR: Tool folder '$($toolFolder.Name)' is missing 'version.txt'." -ForegroundColor Red
            Write-Host
            Remove-Item $tempDir -Recurse -Force
            cmd /c pause
            exit 1
        }
    }
    Write-Host
}

# Pull from libraries + (optionally) disabled_libraries; error on duplicates
$librariesPath         = Join-Path $scriptDir "libraries"
$disabledLibrariesPath = Join-Path $scriptDir "disabled_libraries"

if (-not (Test-Path $librariesPath)) {
    Clear-Host
    Write-Host "ERROR: libraries folder not found in script directory." -ForegroundColor Red
    Write-Host
    Remove-Item $tempDir -Recurse -Force
    cmd /c pause
    exit 1
}

# Only consider folder libraries (not files)
$librariesItems = Get-ChildItem -Path $librariesPath -Directory

$disabledLibrariesItems = @()
if (Test-Path $disabledLibrariesPath) {
    $disabledLibrariesItems = Get-ChildItem -Path $disabledLibrariesPath -Directory

    # Check duplicates by folder name
    $namesA = $librariesItems.Name
    $namesB = $disabledLibrariesItems.Name
    $dupes  = $namesA | Where-Object {$_ -in $namesB}

    if ($dupes.Count -gt 0) {
        Clear-Host
        Write-Host "ERROR: Duplicate library folder(s) found in BOTH 'libraries' and 'disabled_libraries': $($dupes -join ', ')" -ForegroundColor Red
        Write-Host
        Remove-Item $tempDir -Recurse -Force
        cmd /c pause
        exit 1
    }
}

# Create ZIP for each library/tool inside "My Libraries/Tools"
$allLibraryItems = @($librariesItems + $disabledLibrariesItems)

foreach ($item in $allLibraryItems) {

    if (($excludedLibraryFolders.Count -ne 0) -and ($item.Name -in $excludedLibraryFolders)) {
        continue
    }

    $libJsonPath = Join-Path $item.FullName "lib.json"

    if (-not (Test-Path $libJsonPath)) {
        Clear-Host
        Write-Host "ERROR: Library '$($item.Name)' is missing lib.json." -ForegroundColor Red
        Write-Host
        Remove-Item $tempDir -Recurse -Force
        cmd /c pause
        exit 1
    }

    $libJsonContent = Get-Content $libJsonPath -Raw
    $versionMatch = [regex]::Match($libJsonContent, '"version"\s*:\s*"([^"]+)"')

    if (-not $versionMatch.Success) {
        Clear-Host
        Write-Host "ERROR: Library '$($item.Name)' does not contain a version in lib.json." -ForegroundColor Red
        Write-Host
        Remove-Item $tempDir -Recurse -Force
        cmd /c pause
        exit 1
    }

    $libVersion = $versionMatch.Groups[1].Value
    $libVersionFormatted = $libVersion -replace '\.', '_'

    $libraryZipName = "$($item.Name)_$libVersionFormatted.zip"
    $libraryZipPath = Join-Path $myLibrariesDestination $libraryZipName

    Compress-Archive `
        -Path $item.FullName `
        -DestinationPath $libraryZipPath `
        -Force

    Write-Host "Added library ZIP: $libraryZipName"
}

if ($createZip) {

    $zipFilePath = "$outputFolderPath.zip"

    if (Test-Path $zipFilePath) {
        Remove-Item $zipFilePath -Force
    }

    Compress-Archive -Path (Join-Path $tempDir "*") `
                     -DestinationPath $zipFilePath `
                     -Force

    Write-Host
    Write-Host "Created ZIP on desktop: $zipFilePath"
    Write-Host
}
else {

    if (Test-Path $outputFolderPath) {
        Remove-Item $outputFolderPath -Recurse -Force
    }

    New-Item -ItemType Directory -Path $outputFolderPath -Force | Out-Null

    Copy-Item -Path (Join-Path $tempDir "*") `
              -Destination $outputFolderPath `
              -Recurse -Force

    Write-Host
    Write-Host "Created folder on desktop: $outputFolderPath"
    Write-Host
}

# Cleanup
Remove-Item $tempDir -Recurse -Force

cmd /c pause