$plinkPath = "C:\Program Files (x86)\PuTTY\plink.exe"
$username  = "<username_admin>"
$oldPass = Get-Content "C:\Users\<user>\Downloads\old_password.txt" -Raw
$newPass = Get-Content "C:\Users\<user>\Downloads\new_password.txt" -Raw
$hosts = @("host1","host2") 

foreach ($hostname in $hosts) {
    Write-Host "--- Starting execution for Host: $hostname ---" -ForegroundColor Green
    
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $plinkPath
    $processInfo.Arguments = "-t -ssh $username@$hostname -pw $oldPass security login password -username $username"
    $processInfo.RedirectStandardInput = $true
    $processInfo.RedirectStandardOutput = $true
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $false

    $process = [System.Diagnostics.Process]::Start($processInfo)

    function Send-Input($proc, $text, $delay = 1000) {
        Start-Sleep -Milliseconds $delay
        $proc.StandardInput.WriteLine($text)
    }

    Send-Input $process $oldPass 2000 # Wait for initial interactive prompt
    Send-Input $process $newPass 1000 # Send new password
    Send-Input $process $newPass 1000 # Confirm new password

    $process.WaitForExit()

    $timestamp = Get-Date -Format 'yyyyMMdd_HHmm'
    $logFile = "C:\Users\<user>\Downloads\Pow_logs\PS_pwd_reset_output_${hostname}_${timestamp}.txt"
    
    New-Item -ItemType File -Path $logFile -Force | Out-Null
    
    Write-Host "XXX == Script Execution Completed == XX" -ForegroundColor Magenta
    
    $output = $process.StandardOutput.ReadToEnd()
    $output | Out-File $logFile
    Write-Host "Check the logs for errors at $logFile"

    $errorKeywords = @("denied", "failed", "error", "invalid", "rejected") 
    $foundErrors = Select-String -Path $logFile -Pattern $errorKeywords -CaseSensitive:$false
 
    if ($foundErrors) {
        Write-Host "--- Issues detected in log file! ---" -ForegroundColor Red
        $foundErrors | ForEach-Object { Write-Host "Found: $($_.Line)" -ForegroundColor Yellow }
    }
    else {
        Write-Host "--- Log scan complete: No errors found. Password reset appears successful. ---" -ForegroundColor Green
    }
    
    Write-Host "`n==============================================================================================`n"
}