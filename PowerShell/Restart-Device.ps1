$device = Get-PnpDevice -FriendlyName "*Atheros AR9271*" 

if ($device -and $device.Status -ne "OK") {
    $device | Disable-PnpDevice -Confirm:$false
    $device | Enable-PnpDevice -Confirm:$false
}