$connParams = @{
ServerInstance = "localhost"
Database = "TestDB"
TrustServerCertificate = $true
}
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$database = "TestDB"
$backupPath = "C:\SQLBackups"
$retentionDays = 7
$cutoffDate = (Get-Date).AddDays(-$retentionDays)

#BACKUP PART
Invoke-Sqlcmd @connParams -Query "BACKUP DATABASE $database TO DISK = '$backupPath\${database}_${timestamp}.bak';"

#CLEANUP PART
Get-ChildItem -Path $backupPath -Filter "*.bak" | ForEach-Object {
    if ($_.LastWriteTime -lt $cutoffDate)
        {   Remove-Item -Path $_.FullName 
            Write-Host "Deleted: $($_.name)" 
}
}