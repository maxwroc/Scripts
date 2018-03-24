
$funcCacheDir = ($funcCacheDir, "$($env:TEMP)\PSFuncCache", 1 -ne $null)[0]

Function New-CachedFunction {
    Param(
        [string]$Name,
        [ScriptBlock]$TargetFunction,
        [string]$KeyName = $null
    )

    {
        $TargetFunction
    }.GetNewClosure()
}

function Subject {
    $ans = Read-Host "Enter some val"
    return @{"hello" = "val $ans"}
}

${function:Cached-Subject} = New-CachedFunction "Subject" ${function:Subject}

$funcCacheDir

Cached-Subject 1
#Cached-Subject 1
#Cached-Subject 2
#Cached-Subject 1