$MyPassword = Get-Content -Path <path_to_the_password_file>
$plinkPath  = "C:\Program Files (x86)\PuTTY\plink.exe"  
$username   = <username_readonly>
$password   = $MyPassword
$hosts = @("<host1>,<host2>") 
$commands = @(
    "ro 0; volume show -vserver !*-mc -volume !*vol0,!*root"
)

foreach ($hostname in $hosts) {
    $logFile = "C:\Users\<user>\Downloads\Pow_logs\PS_vol_output_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"
    Write-Host "--- Starting execution for Host: $hostname ---" -ForegroundColor Green

    
    foreach ($command in $commands) {
        $logHeader = "[$hostname] - Executing: $command"
        Write-Host $logHeader -ForegroundColor Cyan
        $logHeader | Out-File -FilePath $logFile -Append
        $output = & $plinkPath -batch -t -ssh "$username@$hostname" -pw $password $command
        $output | Out-File -FilePath $logFile -Append
        "================================================================================" | Out-File -FilePath $logFile -Append
    }
	Write-Host "XXX == Script Execution Completed == XX" -ForegroundColor Magenta
}

