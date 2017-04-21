[CmdletBinding()]
param()

$configFileName = "$($MyInvocation.MyCommand.Name.Substring(0, $MyInvocation.MyCommand.Name.Length - 4))Config.xml"

if(-not (Test-Path $configFileName)) {
    Write-Error "Config file missing ($($configFileName))"
    exit
}

Write-Verbose "Reading config"
try {
    $config = [xml] (Get-Content $configFileName)
    $config = $config.Config
}
catch {
    Write-Error "Failed to load the config file: $($_.Exception.Message)"
    Exit
}


# http://blogs.technet.com/b/heyscriptingguy/archive/2013/04/26/use-powershell-to-work-with-windows-explorer.aspx
$o = New-Object -com Shell.Application
# https://msdn.microsoft.com/en-us/library/windows/desktop/bb774096(v=vs.85).aspx
# ShellSpecialFolderConstants.ssfDRIVES == 0x11
$folder = $o.NameSpace(0x11)





Function GetSubFolder ($folder, $sourcePathChunks, $sourcePathDepth)
{
    if($sourcePathDepth -ge $sourcePathChunks.Count) {
        Write-Verbose "Reached the end of the path ($($sourcePathDepth))"
        Write-Host $sourcePathChunks
        return
    }

    $searchingFor = $sourcePathChunks[$sourcePathDepth]
    Write-Verbose "Looking for $($searchingFor)"

    foreach ($i in $folder) {
        Write-Verbose "    Checking if $($i.Name) is a folder: $($i.IsFolder)"
        if ($i.IsFolder -and $i.Name -eq $searchingFor) {
            
            $fld = $i.GetFolder()
            if($sourcePathDepth -eq $sourcePathChunks.Count-1) {
                Write-Verbose "Found"
                return $fld
            }
            else {
                return GetSubFolder $fld.Items() $sourcePathChunks ($sourcePathDepth+1)
            }
        }
    }

    Write-Host -NoNewline "This PC"
    for ($i=0; $i -lt $sourcePathChunks.Count; $i++) {
        Write-Host -NoNewline "\"
        if($sourcePathDepth -eq $i) {
            Write-Host -NoNewline -ForegroundColor Yellow $sourcePathChunks[$i]
        }
        else {
            Write-Host -NoNewline $sourcePathChunks[$i]
        }
    }
    Write-Host ""

    Write-Host -ForegroundColor Red "Error: Couldn't find the path specified"

    return
}

Function CopyFiles ($sourceFolder, $filters) {
    
    $items = $sourceFolder.Items()

    $cleanName = $items.Item(0).Name.Replace("IMG_", "")
    $targetPath = "D:\Photos\Temp\$($cleanName)"
    
    Write-Verbose "Getting temporary directory dir"
    $target = $o.NameSpace("D:\Photos\Temp")

    # create empty collection
    $filesToProcess = @()
    for ($i = 0; $i -lt $items.Count; $i++) {
        Write-Progress -Activity "Detecting how many items to copy" -PercentComplete ($i / $items.Count * 100)

        $isValid = 1
        foreach ($filter in $filters) {
            $isValid = IsValidFile $items.Item($i) $filter
            if (-not $isValid) {
                break
            }
        }

        if (-not $isValid) {
            continue
        }

        $filesToProcess += ,$items.Item($i)
    }

    Write-Host "Files to process: $($filesToProcess.Count)"

    return
    Write-Verbose "copy"
    $target.CopyHere($photo, 0)
    Write-Verbose "copied"

    Write-Verbose "Copying from: $($items.Item(0).Path)"
    Write-Verbose "To: $($targetPath)"
    Copy-Item -LiteralPath "$($items.Item(0).Path)fdsfsdfsds" -Destination $targetPath
    Write-Verbose "Done"

    #-ItemUsingExplorer $items.Item(0).Path "D:\Photos\Temp" -CopyFlags 16
}

Function IsValidFile ($file, $filter) {
    $result = 1
    switch ($filter.Type) {
        "NewerThan" { 
            $namePattern = $filter.ExtractDateFromName
            $date = [DateTime]::Parse($filter.Date)
            $fileName = $file.Name
            if($namePattern.SubString) {
                $fileName = $fileName.Substring($namePattern.Substring.From, $namePattern.Substring.Length)
                Write-Verbose "Cutting file name: $($file.Name) -> $fileName"
            }
            Write-Verbose "Is valid file: $($fileName) [filter: $($filter.Type)][pattern: $($namePattern.Pattern)]"
            $parsedDate = [DateTime]::ParseExact($fileName, $namePattern.Pattern, $null)
            
            if ($parsedDate -lt $date) {
                Write-Verbose "File too old: $($fileName)"
                $result = 0
            }
         }
        Default {}
    }

    return $result
}


Write-Verbose "Iterating over available dives:"
foreach ($device in $folder.Items()) {
    Write-Verbose "    Checking config for device $($device.Name)"
    $deviceConfig = $config.Sources.Source | Where-Object {$_.Name -eq $device.Name}

    if($deviceConfig) {
        Write-Verbose "Loaded config for device $($device.Name)"
        Write-Verbose "    Path: $($deviceConfig.Path)"

        $sourceFolder = GetSubFolder $device.GetFolder().Items() $deviceConfig.Path.Split("\") 1
        if(!$sourceFolder) {
            Write-Error "Source folder not found: $($deviceConfig.Path)"
            exit
        }

        CopyFiles $sourceFolder $deviceConfig.Filters.Filter
        break
    }
}
