# Load rules from JSON
$rulesPath = "$PSScriptRoot\rules.json"
if (-Not (Test-Path $rulesPath)) {
    Write-Host "ERROR: Rules file not found at $rulesPath"
    exit
}

Write-Host "Loading rules from: $rulesPath"
$rules = Get-Content $rulesPath | ConvertFrom-Json
$Downloads = "$env:USERPROFILE\Downloads"
Write-Host "Downloads folder: $Downloads"
Write-Host "Downloads folder exists: $(Test-Path $Downloads)"

# Get total file count first
$allFiles = Get-ChildItem -Path $Downloads -File -ErrorAction SilentlyContinue
Write-Host "Total files found: $($allFiles.Count)"

if ($allFiles.Count -eq 0) {
    Write-Host "No files to process - Downloads folder is empty"
    exit
}

Write-Host ""
Write-Host "Starting to apply rules..."

$totalProcessed = 0
$summary = @()

# Apply rules
foreach ($folder in $rules.PSObject.Properties.Name) {
    $patterns = $rules.$folder
    $target = Join-Path $Downloads $folder
    $moveCount = 0
    $folderHasFiles = $false
   
    # First pass: check if this folder will have any files to process
    foreach ($pattern in $patterns) {
        $files = Get-ChildItem -Path $Downloads -File -ErrorAction SilentlyContinue | Where-Object {
            $matchesDirectory = $_.DirectoryName -eq $Downloads
            $matchesPattern = $_.Name -like $pattern
            return ($matchesDirectory -and $matchesPattern)
        }
        
        if ($files.Count -gt 0) {
            $folderHasFiles = $true
            break
        }
    }
    
    # Only log and process if this folder has files
    if ($folderHasFiles) {
        Write-Host ""
        Write-Host "--- Processing folder: $folder ---"
        
        # Ensure target folder exists
        if (!(Test-Path $target)) {
            New-Item $target -ItemType Directory | Out-Null
            Write-Host "  Created folder: $target"
        } else {
            Write-Host "  Target folder: $target"
        }
        
        # Second pass: actually process the files
        foreach ($pattern in $patterns) {
            $files = Get-ChildItem -Path $Downloads -File -ErrorAction SilentlyContinue | Where-Object {
                $matchesDirectory = $_.DirectoryName -eq $Downloads
                $matchesPattern = $_.Name -like $pattern
                return ($matchesDirectory -and $matchesPattern)
            }
            
            # Only log patterns that have matching files
            if ($files.Count -gt 0) {
                Write-Host "  Found $($files.Count) files matching pattern: $pattern"
                
                foreach ($file in $files) {
                    Write-Host "    Moving: $($file.Name)"
                    try {
                        Move-Item -Path $file.FullName -Destination $target -Force
                        $moveCount++
                        Write-Host "      Success: moved to $folder"
                    } catch {
                        Write-Host "      Error: $($_.Exception.Message)"
                    }
                }
            }
        }
        
        # Summary for this folder
        Write-Host "  Total moved to $folder`: $moveCount files"
        $summary += "  - $folder`: $moveCount files"
        $totalProcessed += $moveCount
    }
}

# Final Summary
Write-Host ""
Write-Host "========================================"
Write-Host "EXECUTION SUMMARY"
Write-Host "========================================"

if ($totalProcessed -gt 0) {
    Write-Host "Total files organized: $totalProcessed"
    Write-Host ""
    Write-Host "Breakdown by folder:"
    $summary | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "No files needed organizing - all files already sorted or no matching patterns found"
}

Write-Host ""
Write-Host "Task completed successfully"