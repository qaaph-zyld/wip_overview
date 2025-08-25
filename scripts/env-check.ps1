Write-Host "Checking SqlServer PowerShell module..."
$mod = Get-Module -ListAvailable SqlServer
if ($null -eq $mod) { Write-Warning "SqlServer module NOT found. Install-Module SqlServer -Scope CurrentUser" } else { Write-Host "SqlServer module found: $($mod.Version)" }

Write-Host "`nChecking sqlcmd..."
$paths = $env:Path -split ";"
$hasSqlcmd = $paths | ForEach-Object { Test-Path (Join-Path $_ "sqlcmd.exe") } | Where-Object { $_ } | Measure-Object | Select-Object -ExpandProperty Count
if ($hasSqlcmd -gt 0) { Write-Host "sqlcmd found in PATH" } else { Write-Warning "sqlcmd NOT found. Install via winget: winget install Microsoft.sqlcmd" }

Write-Host "`nChecking ODBC drivers..."
$odbcKey = "HKLM:\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers"
if (Test-Path $odbcKey) {
  Get-ItemProperty $odbcKey | Select-Object -Property "ODBC Driver 17 for SQL Server","ODBC Driver 18 for SQL Server"
} else {
  Write-Warning "ODBC registry key not found."
}
