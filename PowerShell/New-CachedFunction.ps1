
$funcCacheDir = ($funcCacheDir, "$($env:TEMP)\PSFuncCache", 1 -ne $null)[0]

Function New-CachedFunction {
    <#
      .SYNOPSIS
        Caches function result in a json text file.
      .DESCRIPTION
        Display the input PSObject(s)/Object(s) as formatted table with defined foreground colors for values based on specified conditions or criteria.
      .EXAMPLE
        ${function:Cached-Subject} = New-CachedFunction "Get-File" ${function:Subject}
    #>

    Param(
        [string]$Name,
        [ScriptBlock]$TargetFunction
    )

    if (-not (Test-Path $funcCacheDir)) {
        New-Item -ItemType Directory $funcCacheDir
    }

    $filePath = "$funcCacheDir\$Name.json" 
    [hashtable]$cachedResults = @{}
    if (Test-Path -Path $filePath) {
        (Get-Content $filePath | ConvertFrom-Json).PSObject.Properties | ForEach { $cachedResults[$_.Name] = $_.Value }
    }

    return {
        $key = ("$args", "[null]", 1 -ne "")[0]
        if (-not $cachedResults[$key]) {
            $cachedResults.Add($key, $TargetFunction.invoke($args))
            ConvertTo-Json $cachedResults | Set-Content -Path $filePath
        }

        return $cachedResults[$key]
    }.GetNewClosure()
}

function Subject($number) {
    $ans = Read-Host "Enter some val"
    return @{"hello" = "$number entered val: $ans"}
}

function Subject-NoParam() {
    $ans = Read-Host "Subject-NoParam some val"
    return "ans $ans"
}

${function:Cached-Subject} = New-CachedFunction "Subject" ${function:Subject}


${function:Subject-NoParamCached} = New-CachedFunction "Subject-NoParam" ${function:Subject-NoParam}


Cached-Subject 1
Cached-Subject 1
#Cached-Subject 2
#Cached-Subject 1
Subject-NoParamCached
Subject-NoParamCached