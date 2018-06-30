[cmdletbinding()]

Param(
    [Parameter(Mandatory = $false, Position = 0)][Alias("r")][Switch]$RegisterLogonTask = $false,
    [Parameter(Mandatory = $false, Position = 1)][Alias("u")][Switch]$UnregisterLogonTask = $false
)

$ErrorActionPreference = "Stop"

$taskName = "WhereIsMyInternet"
if ($RegisterLogonTask) {
    if (Get-ScheduledTask -TaskName $taskName -ErrorAction Ignore) {
        Write-Error "Task already exists: $taskName"
    }

    $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -File `"$PSScriptRoot`""
    $trigger = New-ScheduledTaskTrigger -AtLogOn

    Write-Host "Registering task: $taskName"

    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description "Script restarting network adapter when internet connection is gone"
}

if ($UnregisterLogonTask) {
    $task = Get-ScheduledTask $taskName -ErrorAction Ignore
    if (-not $task) {
        write-Error "Task not found with name: $taskName"
    }

    $task | Unregister-ScheduledTask -Confirm
    exit
}

# Start-Sleep -s 15


$networkAdapterName = "*Atheros AR9271*"

$isInternetConnectionRunning = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet

if (-not $isInternetConnectionRunning) {
    $device = Get-PnpDevice -FriendlyName $networkAdapterName

    if ($device -and $device.Status -ne "OK") {
        $device | Disable-PnpDevice -Confirm:$false
        $device | Enable-PnpDevice -Confirm:$false
    }
}

