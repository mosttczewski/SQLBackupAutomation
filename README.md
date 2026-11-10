# SQLBackupAutomation

(For learning purposes) A script that automates database backups using T-SQL and PowerShell.

## What it does

The script backs up the database specified in the script file, with adjustable options.

Each backup file is named automatically using the database name and a timestamp in `yyyyMMdd_HHmmss` format (for example `TestDB_20260803_125159.bak`). Putting the year first means files sort alphabetically in the same order as chronologically.

The `$retentionDays` variable specifies how many days backups are kept. After a backup completes successfully, the script deletes every `.bak` file in the backup folder that is older than that period.

If the backup fails, the script prints the error message and skips the cleanup entirely, so old backups are never deleted when there is no fresh one to replace them.

## Requirements

To run the script you need:
- SQL Server (tested on SQL Server 2025)
- PowerShell 7
- The `SqlServer` PowerShell module
- A backup folder (the one set in `$backupPath`) where the SQL Server service account has **Modify** permission

## Setting up folder permissions

SQL Server writes backup files under its own service account, not under your Windows user. For a default instance that account is `NT Service\MSSQLSERVER` (a named instance uses `NT Service\MSSQL$InstanceName`).

1. Create the backup folder, for example `C:\SQLBackups`
2. Right-click it → Properties → Security → Edit → Add
3. Type the service account name and click **Check Names** to confirm it exists
4. Give it **Modify** permission (Full Control is not needed, following the principle of least privilege) and click Apply

## Configuration

To configure the script, edit these variables at the top of `backup_database.ps1`:

- `$connParams` - connection settings passed to `Invoke-Sqlcmd`:
  - `ServerInstance` - the SQL Server to connect to, e.g. `localhost` (default instance) or `localhost\InstanceName` (named instance)
  - `Database` - the connection's default database; should match `$database` to avoid confusion
  - `TrustServerCertificate` - skips certificate validation. Fine for a local server with a self-signed certificate, but not recommended for production servers
- `$database` - the name of the database to back up. It is also used in the backup file name
- `$backupPath` - the folder where backups are saved, without a trailing backslash. The SQL Server service account needs Modify permission on it (see "Setting up folder permissions")
- `$retentionDays` - how many days backups are kept. After each successful backup, `.bak` files older than this are deleted

## How to run it

1. Configure the script (see [Configuration](#configuration)) and make sure SQL Server is running
2. Open PowerShell
3. Go to the folder containing the script, for example:
   ```powershell
   cd ~\Documents\SQLBackupAutomation
   ```
4. Run the script:
   ```powershell
   .\backup_database.ps1
   ```

### What to expect

- **Success:** the script prints nothing for the backup itself. A new file like `TestDB_20260803_125159.bak` appears in your backup folder. If any backups were older than `$retentionDays`, the script prints `Deleted: <filename>` for each one.
- **Failure:** the script prints `Backup failed:` followed by the error message from SQL Server, and skips the cleanup, so no old backups are deleted.

## Design decisions
- **Why backup runs before cleanup?**
    Cleanup first would free disk space for the new backup. I chose backup first because it is the safer failure mode: if something goes wrong in the cleanup logic, today's backup already exists, and a failed backup is easy to fix and re-run manually.
- **Why cleanup is skipped if the backup fails?**
    If the cleanup hasn't been skipped after failed backup it could erase other correct backups, leaving no valid recent backup at all.
- **Why the timestamp is `yyyyMMdd_HHmmss`?**
    It's because it is easier to sort that way (in this format, backups are sorted in the exact same order as chronological sorting — oldest file first, most recent file last, A-to-Z.). `HH` (24-hour) is used instead of `hh` (12-hour) so that 3 AM and 3 PM never produce the same digits.

## What I learned

- **Backup types and recovery models:** SQL Server has full, differential and transaction log backups. Log backups only work in Full or Bulk-Logged recovery, not in Simple. This project uses full backups on a database in Simple recovery.
- **Permissions:** my first backup failed with OS error 5 (access denied). SQL Server runs under its own service account (`NT Service\MSSQLSERVER`), not my Windows user, so it couldn't write to my Documents folder. The fix was a dedicated backup folder where that account has Modify permission, not Full Control, following the principle of least privilege.
- **Backup devices:** a `.bak` file can hold several backups, and by default a new backup is appended instead of overwriting. Unique timestamped filenames avoid this.
- **PowerShell pipes and objects:** `Get-ChildItem` passes file objects, not text, through the pipe to `ForEach-Object`. That is why `$_.LastWriteTime` can be compared with a cutoff date.
- **String interpolation:** `${database}_${timestamp}` needs curly braces, otherwise PowerShell reads the underscore as part of the variable name and the filename comes out wrong.
- **Error handling:** `try`/`catch` only catches terminating errors, so `-ErrorAction Stop` is needed on `Invoke-Sqlcmd`. I tested it by stopping the SQL Server service and confirming the cleanup was skipped.
- **Safe testing:** I tested the deletion logic with a dry run (`Write-Host` instead of `Remove-Item`) and a temporary cutoff of 0 days before letting it delete real files.
- **Git:** I practised imperative commit messages, `git log --oneline`, `git show` and `.gitignore`.

## Possible improvements

- Use `$database` inside `$connParams` so the database name is only set in one place
- Back up multiple databases in a loop
- Log results to a file instead of only printing to the console
- Add differential and transaction log backups
- Verify backups with `RESTORE VERIFYONLY`
- Schedule the script with Windows Task Scheduler