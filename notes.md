### 11.07.26
**SQL Server backup fundamentals**
Backup types (Full vs Differential vs Transaction Log)
Recovery models (Simple vs Full) and why it matters for log backups (even though we're not using log backups yet)

**T-SQL syntax**
BACKUP DATABASE dbname TO DISK = 'path' 
The concept of a "backup device" — a .bak file can hold multiple backup sets appended together by default
WITH INIT (overwrite) vs default WITH NOINIT (append) differences

SQL Server runs as its own Windows service account (NT Service\MSSQLSERVER), not as a personal user

Backing up to a personal Documents folder failed with OS error 5 (access denied)
Fix: granting the service account Modify permission on a dedicated folder


**PowerShell + SQL Server**
Get-Module -ListAvailable
Get-Module (in session)
Import-Module to load it
Invoke-Sqlcmd -ServerInstance -Database -Query -TrustServerCertificate
The -Database parameter sets connection context but doesn't override an explicitly-named database inside the query itself

**Git**
git remote add origin <url> to link local repo to gh
git push -u origin master — what -u actually does is sets upstream so future pushes don't need arguments