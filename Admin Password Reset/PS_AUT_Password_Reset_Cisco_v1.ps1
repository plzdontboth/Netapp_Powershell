$MyPassword = Get-Content -Path <path_to_the_password_file>
$plinkPath  = "C:\Program Files (x86)\PuTTY\plink.exe"  
$username   = <username_admin>
$password   = $MyPassword
$hosts = @("<switch1>,<switch2>") 
$commands = @"
configure terminal
username admin password $newPass
end
copy running-config startup-config
exit
exit
"@

foreach ($hostname in $hosts) {
    $logFile = "C:\Users\<user>\Downloads\Pow_logs\PS_Cisco_pass_reset_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"
    Write-Host "--- Starting execution for Host: $hostname ---" -ForegroundColor Green

    $commandString = "echo `"$commands`" | & `"$plinkPath`" -ssh -batch -pw `"$oldPass`" $username@$hostname"
    
    Invoke-Expression $commandString | Out-File -FilePath $logFile
    
    Write-Host "XXX == Script Execution Completed == XX" -ForegroundColor Magenta
}