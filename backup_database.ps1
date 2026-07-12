$connParams = @{
ServerInstance = "localhost"
Database = "TestDB"
TrustServerCertificate = $true
}
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$database = "TestDB"
$backupPath = "C:\SQLBackups"
Invoke-Sqlcmd @connParams -Query "BACKUP DATABASE $database TO DISK = '$backupPath\${database}_${timestamp}.bak';"