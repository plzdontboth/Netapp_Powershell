$plinkPath = "C:\Program Files (x86)\PuTTY\plink.exe"  

$targetHosts = @(
    [PSCustomObject]@{
        Hostname     = "<host1>"
        Username     = "admin"
        PasswordPath = <path_to_the_password_file>
        CommonName   = "<host1>"
        DNSName      = "host1.company.com"
        IPAddr       = "10.0.0.92"
		Country      = "US"
		State		 = "Arizona"
		Locality	 = "Sun City"
    },
    [PSCustomObject]@{
        Hostname     = "<host2>"
        Username     = "admin"
        PasswordPath = <path_to_the_password_file>
        CommonName   = "<host2>"
        DNSName      = "host2.company.com"
        IPAddr       = "10.0.0.93"
		Country      = "US"
		State		 = "Florida"
		Locality	 = "Bun City"
    }
)


foreach ($node in $targetHosts) {
    
    Write-Host "=========================================" -ForegroundColor Yellow
    Write-Host "Processing Target Host: $($node.Hostname)" -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Yellow

    if (Test-Path $node.PasswordPath) {
        $password = Get-Content -Path $node.PasswordPath
    } else {
        Write-Warning "Password file not found for $($node.Hostname) at $($node.PasswordPath). Skipping..."
        continue # Skips to the next host in the loop
    }

    $commands = "rows 0`nsecurity certificate generate-csr -common-name $($node.CommonName) -dns-name $($node.DNSName) -ipaddr $($node.IPAddr) -country $($node.Country) -state $($node.State) -locality $($node.Locality) -algorithm RSA -hash-function SHA256 -key-usage critical,digitalSignature,keyEncipherment -extended-key-usage serverAuth,clientAuth -size 4096 -organization Corp_inc -unit Finance -email-addr mail@company.com`ny`nexit"

    Write-Host "[$($node.Hostname)] - Executing CSR generation..." -ForegroundColor Cyan

    $netappOutput = ($commands | & $plinkPath -ssh "$($node.Username)@$($node.Hostname)" -pw $password) -join "`r`n"

    $csrPattern = "(?s)-----BEGIN CERTIFICATE REQUEST-----.*?-----END CERTIFICATE REQUEST-----"
    $keyPattern = "(?s)-----BEGIN PRIVATE KEY-----.*?-----END PRIVATE KEY-----"

    if ($netappOutput -match $csrPattern) {
        $csrContent = $Matches[0]
        $csrContent | Set-Content -Path "C:\Users\<user>\Downloads\Certificates\$($node.Hostname).txt"
        Write-Host "CSR successfully saved to C:\Users\<user>\Downloads\Certificates\$($node.Hostname).txt" -ForegroundColor Green
    } else {
        Write-Warning "Could not find CSR in the output for $($node.Hostname)."
    }

    if ($netappOutput -match $keyPattern) {
        $keyContent = $Matches[0]
        $keyContent | Set-Content -Path "C:\Users\<user>\Downloads\Certificates\Private_Keys\$($node.Hostname)_p.txt"
        Write-Host "Private Key successfully saved to C:\Users\<user>\Downloads\Certificates\Private_Keys\$($node.Hostname)_p.txt" -ForegroundColor Green
    } else {
        Write-Warning "Could not find Private Key in the output for $($node.Hostname)."
    }
    
    Write-Host "Finished processing $($node.Hostname).`n" -ForegroundColor Magenta
}

Write-Host "XXX == All Hosts Processed == XXX" -ForegroundColor Cyan