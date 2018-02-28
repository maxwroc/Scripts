function Format-ColorTable {

    Param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName=$true)][Alias("O", "I")][Object]$Object,
        [Parameter(Mandatory = $false, Position = 1)][string[]]$Columns = @(),
        [Parameter(Mandatory = $false, Position = 2)][hashtable]$ColumnColors,
        [Parameter(Mandatory = $false, Position = 3)][switch]$RowNumbers,
        [Parameter(Mandatory = $false, Position = 4)][switch]$NoHeaders
    )

    Begin {
        [System.Collections.ArrayList]$results = @()
        [hashtable]$maxSize = @{}

        $initColumnsFromObj = $false
        if (-not $Columns -or $Columns.Count -eq 0) {
            $initColumnsFromObj = $true
        }

        if (-not $initColumnsFromObj -and $RowNumbers) {
            $Columns = @("No") + @($Columns)
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

        $index = 1
        $results | ForEach-Object {
            $obj = $_

            $Columns | ForEach-Object {

                $params = @{}

                if ($ColumnColors -and $ColumnColors[$_]) {
                    $params["ForegroundColor"] = $ColumnColors[$_]
                }

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

                $params["Object"] = "$($val.ToString().$func($maxSize[$_])) "

                Write-Host -NoNewline @params
            }

            Write-Host ""
        }
        
        Write-Host ""
    }
}


#Get-Service | select -first 5 | Format-ColorTable -Columns Name, Status -RowNumbers -ColumnColors @{ "No" = "Yellow" }
#Get-Service | select -first 5 | Format-ColorTable -Columns Name, Status -ColumnColors @{ "Status" = "Red" }
#Get-Service | select -first 5 -Property Name, CanStop | Format-ColorTable -RowNumbers
#Get-Service | select -first 5 | Format-ColorTable -RowNumbers -ColumnColors @{ "No" = "Yellow" }