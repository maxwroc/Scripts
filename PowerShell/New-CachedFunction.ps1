

Function New-CachedFunction {
    <#
      .SYNOPSIS
        Caches function result in a json text file.
      .DESCRIPTION
        Display the input PSObject(s)/Object(s) as formatted table with defined foreground colors for values based on specified conditions or criteria.
      .EXAMPLE
        # The following code will create "Get-NewsCached" function based on existing "Get-News" function
        # The result will be cached for time defined in the last parameter (TimeSpan object)
        ${function:Get-NewsCached} = New-CachedFunction "Get-News" ${function:Get-News} (New-TimeSpan -Minutes 3)
        # Now instead of using Get-News function you can use new Get-NewsCached
        Get-NewsCached -Type Weather
    #>

    Param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Name,
        [Parameter(Mandatory = $true, Position = 1)][ScriptBlock]$TargetFunction,
        [Parameter(Mandatory = $true, Position = 2)][TimeSpan]$Expiration,
        [Parameter(Mandatory = $false, Position = 3)][string]$CacheDir = "$($env:TEMP)\PSFuncCache"
    )

    # Create cache directory if it doesn't exist
    if (-not (Test-Path $funcCacheDir)) {
        New-Item -ItemType Directory $funcCacheDir
    }

    # Path to cache file
    $filePath = "$funcCacheDir\$Name.json" 

    # Cache values hash table
    [hashtable]$cachedResults = @{}

    if (Test-Path -Path $filePath) {
        # Checking if last write time is older then expiration time
        if ((Get-Item $filePath).LastWriteTime -ge ((Get-Date) - $Expiration)) {
            # Converting json to hash table 
            (Get-Content $filePath | ConvertFrom-Json).PSObject.Properties | ForEach { $cachedResults[$_.Name] = $_.Value }
        }
    }

    return {
        # Take args as a key or [null] if they don't exist
        $key = ("$args", "[null]", 1 -ne "")[0]

        # Check if entry exists
        if (-not $cachedResults[$key]) {
            # Executing function/script and adding it to results table
            $cachedResults.Add($key, $TargetFunction.invoke($args))
            # Updating cache file
            ConvertTo-Json $cachedResults | Set-Content -Path $filePath
        }

        return $cachedResults[$key]
    }.GetNewClosure()
}
