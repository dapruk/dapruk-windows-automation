$tasks = Get-Content -Raw -Path "tasks.json" | ConvertFrom-Json
foreach ($task in $tasks) {
    if (-not $task.active) { continue }
   
    $runThisWeek = $false
    switch ($task.schedule.ToLower()) {
        "weekly" {
            $day = (Get-Date).DayOfWeek
            if ($day -eq "Monday") { $runThisWeek = $true }
        }
        "daily" {
            $runThisWeek = $true
        }
        default {
            Write-Host "Unknown schedule type: $($task.schedule)"
        }
    }
   
    if ($runThisWeek) {
        Write-Host "Running: $($task.name)"
       
        try {
            # Capture all output and convert to string with proper line breaks
            $output = & $task.script 4>&1 5>&1 6>&1 2>&1 | Out-String -Width 4096
           
            if ($task.log) {
                # Create date-stamped log filename
                $dateStamp = Get-Date -Format "yyyy-MM-dd"
                $logDir = Split-Path $task.log -Parent
                $logBaseName = [System.IO.Path]::GetFileNameWithoutExtension($task.name)
                $logFileName = "$logBaseName-$dateStamp.log"
                $logPath = Join-Path $logDir $logFileName
               
                # Ensure log directory exists
                if (-not (Test-Path $logDir)) {
                    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
                }
               
                # Create log entry with timestamp
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logEntry = @"
[$timestamp] Task: $($task.name)
Script: $($task.script)
Schedule: $($task.schedule)
Status: Success
Output:
$output
================================================================================
"@
               
                # Append to date-stamped log file
                Add-Content -Path $logPath -Value $logEntry -Encoding UTF8
                Write-Host "Log saved to: $logPath"
            }
           
        } catch {
            Write-Host "Error running task: $($task.name) - $_"
           
            # Log errors too if logging is enabled
            if ($task.log) {
                $dateStamp = Get-Date -Format "yyyy-MM-dd"
                $logDir = Split-Path $task.log -Parent
                $logBaseName = [System.IO.Path]::GetFileNameWithoutExtension($task.name)
                $logFileName = "$logBaseName-$dateStamp.log"
                $logPath = Join-Path $logDir $logFileName
               
                if (-not (Test-Path $logDir)) {
                    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
                }
               
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $errorEntry = @"
[$timestamp] Task: $($task.name)
Script: $($task.script)
Schedule: $($task.schedule)
Status: ERROR
Error: $_
================================================================================
"@
               
                Add-Content -Path $logPath -Value $errorEntry -Encoding UTF8
                Write-Host "Error log saved to: $logPath"
            }
        }
    }
}