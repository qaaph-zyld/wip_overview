param(
  [string]$ServerInstance = "a265m001",
  [string]$Database = "qadee2798",
  [string]$SqlFile = "C:\\Users\\ajelacn\\OneDrive - Adient\\Documents\\Projects\\Adient_automations\\Inventory Dashboards\\WIP_overview\\Inventory_per_location.sql",
  [string]$CredPath = "C:\\Users\\ajelacn\\OneDrive - Adient\\Documents\\Projects\\Adient_automations\\Inventory Dashboards\\WIP_overview\\secrets\\db_cred.xml",
  [string]$RepoRoot = "$PSScriptRoot\\..",
  [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $CredPath)) { throw "Credential file not found: $CredPath" }
$cred = Import-Clixml -Path $CredPath
$user = $cred.UserName
$pass = $cred.GetNetworkCredential().Password

if (-not (Test-Path $SqlFile)) { throw "SQL file not found: $SqlFile" }
$sql = Get-Content -Raw -Path $SqlFile

function Invoke-WithSqlServerModule {
  try {
    Import-Module SqlServer -ErrorAction Stop | Out-Null
    $rows = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Username $user -Password $pass -Query $sql
    return ,$rows
  } catch {
    return $null
  }
}

function Invoke-WithSqlClient {
  $connStr = "Server=$ServerInstance;Database=$Database;User Id=$user;Password=$pass;TrustServerCertificate=True;"
  $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
  $cmd = $conn.CreateCommand()
  $cmd.CommandText = $sql
  $da = New-Object System.Data.SqlClient.SqlDataAdapter $cmd
  $dt = New-Object System.Data.DataTable
  $null = $da.Fill($dt)
  $conn.Close()

  $rows = @()
  foreach ($dr in $dt.Rows) {
    $obj = [ordered]@{}
    foreach ($col in $dt.Columns) { $obj[$col.ColumnName] = $dr[$col] }
    $rows += [pscustomobject]$obj
  }
  return ,$rows
}

$rows = Invoke-WithSqlServerModule
if ($null -eq $rows) { $rows = Invoke-WithSqlClient }

$dataDir = Join-Path $RepoRoot "site\data"
New-Item -ItemType Directory -Force -Path $dataDir | Out-Null
$outFile = Join-Path $dataDir "inventory.json"

$rows | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 $outFile
"$(Get-Date -Format o)" | Set-Content -Encoding UTF8 (Join-Path $dataDir "last_updated.txt")

try { git -C $RepoRoot config user.name  "a265m001-bot" | Out-Null } catch {}
try { git -C $RepoRoot config user.email "a265m001-bot@example.com" | Out-Null } catch {}

git -C $RepoRoot add site/data/inventory.json site/data/last_updated.txt | Out-Null
try { git -C $RepoRoot commit -m "data: inventory.json update $(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')" | Out-Null } catch {}
try { git -C $RepoRoot push origin $Branch } catch { Write-Warning "git push failed (check PAT)" }
