
foreach ($drive in GET-WMIOBJECT win32_logicaldisk) {
    Write-Host "Hide drive $($drive.DeviceID) ($($drive.VolumeName))? y/n [n]:"
}

exit

foreach ($user in Get-LocalUser | where {$_.Enabled}) {
    Write-Host "Name $($user.Name)"\
    # https://www.pdq.com/blog/modifying-the-registry-of-another-user/
}