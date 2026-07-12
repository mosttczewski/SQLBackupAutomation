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
### 12.07 & 13.07 2026
**PowerShell**
Get-ChildItem — listing files in a folder, -Filter for wildcard matching
ForEach-Object — runs a block of code once per item in a pipeline
$_ — represents "the current object" inside a pipeline/loop (and how it's different from a normal named variable)
Property access with . — e.g. $_.LastWriteTime, $_.Name, $_.FullName (and the distinction between .Name and .FullName)

**String interpolation edge cases**
- `${variableName}` with curly braces — needed when a literal character (like `_`) immediately follows a variable name inside a string, so PowerShell doesn't misinterpret where the variable name ends
- The subexpression operator (dollar sign + parentheses) — needed inside a double-quoted string when you want to access a *property* or run an expression, not just a plain variable. Example: writing the property access wrapped in the subexpression operator works correctly, but referencing `$_.Name` directly inside a string breaks, because PowerShell stops at `$_` and treats `.Name` as literal text

**Date/time logic**
Get-Date -Format "yyyyMMdd_HHmmss" and why yyyy-MM-dd order (not day-first) is deliberate for filenames — sorts correctly alphabetically = chronologically
MM (month) vs mm (minutes) — case-sensitive, easy silent bug
HH (24-hour) vs hh (12-hour) — and the concrete failure case (same digits at 3AM and 3PM)
.AddDays(-N) for date arithmetic — computing a cutoff date

**Comparison operators recap**
-lt, -gt, -le, -ge instead of </>

**Retention/cleanup logic**
The overall pattern: get files → loop → compare LastWriteTime to a cutoff → conditionally delete
Remove-Item -Path $_.FullName
Dry-run technique — testing destructive logic safely with Write-Host before switching to the real Remove-Item, and testing edge cases by temporarily manipulating input values (e.g. AddDays(0)) rather than waiting or touching real files

**Design/ordering decision**
Backup-before-cleanup vs. cleanup-before-backup, I've choosen backup first because of simpler failure recovery path. There is no textbook solutions for things like this
