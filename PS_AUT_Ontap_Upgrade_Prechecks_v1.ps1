$MyPassword = Get-Content -Path <path_to_the_password_file>
$plinkPath  = "C:\Program Files (x86)\PuTTY\plink.exe"  
$username   = <username_readonly>
$password   = $MyPassword
$hosts = @("<host1>,<host2>") 
$commands = @(
    "ro 0; date", "ro 0; node show", "ro 0; aggr show", "ro 0; net port show", "ro 0; vlan show", "ro 0; vol show -state !online", "ro 0; vserver show -admin-state !running", "ro 0; version", "ro 0; system controller environment show", "ro 0; cluster show", "ro 0; cluster peer show", "ro 0; system node run -node * -command storage show fault", "ro 0; aggr show -r", "ro 0; disk show -container-type unassigned ,unknown ,broken", "ro 0; storage shelf show", "ro 0; system controller memory dimm show", "ro 0; cluster ha show", "ro 0; hwassist show", "ro 0; storage failover show", "ro 0; set advanced -confirmations off;  cluster ring show", "ro 0; storage aggregate show -state !online", "ro 0; system node run -node * -command environment status", "ro 0; system node run -node * aggr status -f", "ro 0; cluster date show", "ro 0; license show", "ro 0; sp show", "ro 0; sp show -instance", "ro 0; system service-processor image show", "ro 0; net interface show -fields failover-policy,failover-group", "ro 0; net int show", "ro 0; net int show -is-home false", "ro 0; storage bridge show", "ro 0; set advanced -confirmations off;  cluster ring show -unitname vldb", "ro 0; set advanced -confirmations off;  cluster ring show -unitname mgmt", "ro 0; set advanced -confirmations off;  cluster ring show -unitname vifmgr", "ro 0; set advanced -confirmations off;  cluster ring show -unitname bcomd", "ro 0; volume show -state !online", "ro 0; system node run -node * disk show -n", "ro 0; net interface show -is-home false", "ro 0; network interface show -status-oper down", "ro 0; network interface show -failover", "ro 0; set advanced -confirmations off;  network interface show -fields allow-lb-migrate", "ro 0; cluster time-service ntp server show", "ro 0; set advanced -confirmations off;  system node image show", "ro 0; cluster image package show-repository", "ro 0; storage disk option show -fields bkg-firmware-update", "ro 0; snapmirror show", "ro 0; system node run -node * options snapmirror", "ro 0; job show", "ro 0; system services ndmp status", "ro 0; system node run -node * -command backup status", "ro 0; system services ndmp kill-all -node *", "ro 0; node run -node * -command sysstat -c 10 -x 3", "ro 0; vol show -vserver * -volume * -physical-used-percent > 80 ", "ro 0; aggr show -aggregate aggr_n0* -physical-used-percent >50 ", "ro 0; node run -node * sysconfig -a", "ro 0; storage switch show", "ro 0; network device-discovery show", "ro 0; fcp adapter show", "ro 0; fcp adapter show -fields switch-port", "ro 0; metrocluster check run", "ro 0; metrocluster operation show", "ro 0; metrocluster show", "ro 0; metrocluster node show", "ro 0; metrocluster check show", "ro 0; network port show -ipspace Cluster", "ro 0; network interface show -vserver Cluster", "ro 0; system health subsystem show", "ro 0; system health alert show", "ro 0; system health config show"
)

foreach ($hostname in $hosts) {
    $logFile = "C:\Users\<user>\Downloads\Pow_logs\SessionLog_${hostname}_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"
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