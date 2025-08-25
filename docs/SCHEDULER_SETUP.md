# Scheduled Task (hourly, 08:00–17:00 local)

1) Ensure credentials file and repo exist.
2) Execution policy:
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

3) Register:
```powershell
$WorkDir = "<adjust to your clone path, e.g. C:\Users\ajelacn\OneDrive - Adient\Documents\Projects\Adient_automations\Inventory Dashboards\wip_overview_repo>"
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$WorkDir\scripts\publish-inventory.ps1`""
$trigger = New-ScheduledTaskTrigger -Daily -At 08:00AM
$trigger.RepetitionInterval = (New-TimeSpan -Hours 1)
$trigger.RepetitionDuration = (New-TimeSpan -Hours 10) # up to 17:00
Register-ScheduledTask -TaskName "PublishWipInventory" -Trigger $trigger -Action $action -Description "Publish WIP inventory hourly 08–17" -RunLevel Highest
```
