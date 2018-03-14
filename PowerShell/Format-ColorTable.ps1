
function Format-ColorTable {
    <#
      .SYNOPSIS
        Display the input PSObject(s)/Object(s) with formatted defined colors.
      .DESCRIPTION
        Display the input PSObject(s)/Object(s) as formatted table with defined foreground colors for values based on specified conditions or criteria.
      .EXAMPLE
        Get-Service | select -first 5 | Format-ColorTable 
        # Displays object in the table in the similar way how Format-Table does
      .EXAMPLE
        Get-Service | select -first 5 | Format-ColorTable -Columns Name, Status -RowNumbers
        # Shows two columns (Name and Status) from original object and adds row-number column 
      .EXAMPLE
        Get-Service | select -first 5 | Format-ColorTable -RowNumbers -ColumnColors @{ "No" = "Yellow" }
        # Prints "No" column values in yellow
      .EXAMPLE
        Get-Service | select -first 5 | Format-ColorTable -Columns Name, Status -RowNumbers -ColumnColors @{ `
          "No" = "Yellow"; `
          "Status" = @(@{ Equal = "Stopped"; Color = "Red"}, @{ Equal = "Running"; Color = "Green"}); `
          "Name" = @{ Match = "^.pp"; Color = "Magenta"} `
        }
        # "No" column values are printed in yellow
        # "Status" column values are printed in Red or Green whenever value is equal "Stopped" or "Running" accordingly
        # "Name" column values are printed in Magenta whenever second and third letter of the value is "pp" (uses regular expression) 
    #>

    Param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName=$true)][Alias("o", "i")][Object]$Object,
        [Parameter(Mandatory = $false, Position = 1)][Alias("c")][String[]]$Columns = @(),
        [Parameter(Mandatory = $false, Position = 2)][Alias("cc")][Hashtable]$ColumnColors,
        [Parameter(Mandatory = $false, Position = 4)][Alias("rn")][Switch]$RowNumbers,
        [Parameter(Mandatory = $false, Position = 5)][Alias("nh")][Switch]$NoHeaders
    )

    Begin {
        [System.Collections.ArrayList]$results = @()
        [Hashtable]$maxSize = @{}

        $initColumnsFromObj = $false
        if (-not $Columns -or $Columns.Count -eq 0) {
            $initColumnsFromObj = $true
        }

        if (-not $initColumnsFromObj -and $RowNumbers) {
            $Columns = @("No") + @($Columns)
        }

        function Get-ColorValue([string]$value, [Hashtable]$data, [string]$column) {
            $color = $data["Color"]
            if (-not $color) {
                Write-Error "Missing color value in data for $column column"
                return
            }

            foreach ($_ in $data.GetEnumerator()) {
                switch($_.Key) {
                    "Equal" { if ($value -eq $data[$_]) { return $color } }
                    "Match" { if ($value -match $data[$_]) { return $color } }
                    "Like" { if ($value -match $data[$_]) { return $color } }
                }
            }

            return
        }
    }

    Process {
        $obj = $_
        
        if ($initColumnsFromObj) {
            $Columns = $obj.PSStandardMembers.DefaultDisplayPropertySet.ReferencedPropertyNames

            if ($RowNumbers) {
                $Columns = @("No") + @($Columns)
            }

            $initColumnsFromObj = $false
        }
        else {
            $obj = $obj | select -Property $Columns
        }



        $Columns | ForEach-Object {
            $val = $obj.$_
            if ($RowNumbers -and $_ -eq "No") {
                $val = $results.Count + 1
            }

            if ($val -eq $null) {
                $val = "null"
            }

            $value = $val.ToString()

            if (-not $maxSize[$_]) {
                $maxSize[$_] = $_.Length
            }

            if ($value.Length -gt $maxSize[$_]) {
                $maxSize[$_] = $value.Length
            }
        }

        $r = $results.Add($obj)
    }

    End {

        Write-Host ""

        if (-not $NoHeaders) {
            $Columns | ForEach-Object {
                Write-Host -NoNewline "$($_.PadRight($maxSize[$_])) "
            }

            Write-Host ""
            
            $Columns | ForEach-Object {
                Write-Host -NoNewline "$(''.PadRight($maxSize[$_], '-')) "
            }

            Write-Host ""
        }

        [int]$index = 1
        $results | ForEach-Object {
            $obj = $_

            $Columns | ForEach-Object {

                $params = @{}

                $val = $obj.$_
                # Set row number value
                if ($RowNumbers -and $_ -eq "No") {
                    $val = $index++
                }

                if ($val -eq $null) {
                    $val = ""
                }
                
                $func = "PadRight"
                # Align numbers on the right
                if ($val.GetType().Name -match 'byte|short|int32|long|sbyte|ushort|uint32|ulong|float|double|decimal') {
                    $func = "PadLeft"
                }

                $val = $val.ToString()

                if ($ColumnColors -and $ColumnColors[$_]) {
                    $data = $ColumnColors[$_]
                    $color = $null
                    switch($data.GetType().Name) {
                        "String" { $params["ForegroundColor"] = $data }
                        "Hashtable" { $color = Get-ColorValue $val $data $_ }
                        default { 
                            if ($data -is [System.Array]) {
                                foreach ($rule in $data) {
                                    $color = Get-ColorValue $val $rule $_
                                    if ($color -ne $null) {
                                        break
                                    }
                                }
                            }
                        }
                    }

                    if ($color -ne $null) {
                        $params["ForegroundColor"] = $color
                    }
                }

                $params["Object"] = "$($val.$func($maxSize[$_])) "

                Write-Host -NoNewline @params
            }

            Write-Host ""
        }
        
        Write-Host ""
    }
}