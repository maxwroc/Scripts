<#
.SYNOPSIS
    Restarts (disables/enables) given device (WiFi)
.DESCRIPTION
    Script created when my WiFi was turning in to idle state after hibernation. To fix the issue I have created this script
    which registers a scheduled task and runs after every successful workstation unlock.

    Please check if $networkAdapterName has a correct device name.
.EXAMPLE
    Restart-Device
    # Checks if the internet connection is live. If not it checks status of the WiFi adapter. In case of "error" status it
    # restarts the adapter
.EXAMPLE
    Restart-Device -RegisterLogonTask
.EXAMPLE
    Restart-Device -UnregisterLogonTask
.EXAMPLE
    Restart-Device -RegisterLogonTask -LogFile D:\temp\WhereIsMyInternet.log
    # Registers a task and uses given file as a log where you can check when the script was running last time and what happened
#>
[cmdletbinding()]

Param(
    [Parameter(Mandatory = $false, Position = 0)][Alias("r")][Switch]$RegisterLogonTask = $false,
    [Parameter(Mandatory = $false, Position = 1)][Alias("u")][Switch]$UnregisterLogonTask = $false,
    [Parameter(Mandatory = $false, Position = 2)][string]$LogFile = $null
)

########################################
# Network adapter name
########################################
$networkAdapterName = "*Atheros AR9271*"

$ErrorActionPreference = "Stop"

$scriptName = $MyInvocation.MyCommand.Name
$scriptPath = "$PSScriptRoot\$scriptName"

Function Write-Log {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position = 0)]
        [string]
        $Message,

        [Parameter(Mandatory=$False, Position = 1)]
        [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
        [String]
        $Level = "INFO"
    )

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Level $Message"
    if($LogFile) {
        Add-Content $LogFile -Value $Line
    }
    else {
        Write-Verbose $Line
    }

    if($Level -eq "ERROR") {
        Write-Error $Message
    }
}

Function Add-SessionStateChangeSessionUnlockTrigger {
    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][Alias("x")][Xml]$Xml
    )
    Process {
        $found = $false
        ForEach ($trigger in $Xml.Task.Triggers.ChildNodes) {
            if ($trigger.Name -eq "SessionStateChangeTrigger") {
                $found = $true
            }
        }

        if (-not $found) {
            $newTrigger = $Xml.CreateElement("SessionStateChangeTrigger", $Xml.Task.NamespaceURI)

            $enabled = $Xml.CreateElement("Enabled", $Xml.Task.NamespaceURI)
            $enabled.InnerText = "true"
            $z = $newTrigger.AppendChild($enabled)

            $stateChange = $Xml.CreateElement("StateChange", $Xml.Task.NamespaceURI)
            $stateChange.InnerText = "SessionUnlock"
            $z = $newTrigger.AppendChild($stateChange)

            $z = $Xml.Task.Triggers.AppendChild($newTrigger)
        }

        $Xml.OuterXml
    }
}

$taskName = "WhereIsMyInternet"
if ($RegisterLogonTask) {
    if (Get-ScheduledTask -TaskName $taskName -ErrorAction Ignore) {
        Write-Log "Task already exists: $taskName" "ERROR"
    }

    # Currently there is no way to create a task triggered when user is unlocking workstation
    # To solve the problem we
    # 1. Create initial task
    # 2. Export it to xml
    # 3. Editing xml
    # 4. Unregistering task created second ago
    # 5. Importing task using updated xml

    $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File `"$scriptPath`""
    if ($LogFile) {
        $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File `"$scriptPath`" -LogFile `"$LogFile`""
    }

    # Consider removing this
    $trigger = New-ScheduledTaskTrigger -AtLogOn

    Write-Log "Registering initial task: $taskName"

    $task = Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description "Script restarting network adapter when internet connection is gone"

    Write-Log "Updating task configuration"
    $xml = Get-ScheduledTask WhereIsMyInternet | Export-ScheduledTask | Add-SessionStateChangeSessionUnlockTrigger | Out-String

    Write-Log "Removing old task"
    $task | Unregister-ScheduledTask -Confirm:$false
    Write-Log "Registering final task"
    $task = Register-ScheduledTask -Xml $xml -TaskName $taskName

    exit
}

if ($UnregisterLogonTask) {
    $task = Get-ScheduledTask $taskName -ErrorAction Ignore
    if (-not $task) {
        Write-Log "ERROR"  "Task not found with name: $taskName"
    }

    $task | Unregister-ScheduledTask -Confirm:$false
    exit
}

$isInternetConnectionRunning = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet

if (-not $isInternetConnectionRunning) {
    Write-Log "No internet connection detected"
    $device = Get-PnpDevice -FriendlyName $networkAdapterName

    if ($device -and $device.Status -ne "OK") {
        Write-Log "Restarting WiFi adapter"
        $device | Disable-PnpDevice -Confirm:$false
        $device | Enable-PnpDevice -Confirm:$false
    }
    else {
        Write-Log "Device status seems to be fine"
    }
}
else {
    Write-Log "Internet connection is live"
}

