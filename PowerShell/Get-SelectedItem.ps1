
. "$PSScriptRoot\Format-ColorTable.ps1"

Function Get-SelectedItem() {
    Param(
        [Parameter(Mandatory=$true, Position=1)]
        [System.Collections.ArrayList]$Items,
        [Parameter(Mandatory=$false, Position=2)]
        [string]$Message = $null,
        [Parameter(Mandatory=$false, Position=3)]
        [string[]]$PropertiesToDisplay = $null,
        [Parameter(Mandatory=$false, Position=4)]
        [switch]$Multiselect = $false

    )

    # If there is only one item then return it
    if ($Items.Count -eq 1) {
        return $Items[0]
    }

    do {
        if ($Message) {
            Write-Host $Message
        }

        if ($PropertiesToDisplay.Count -gt 1) {
            $Items | Format-ColorTable -RowNumbers -ColumnColors @{ "No" = "Yellow" }
        }
        else {
            # Printing list of items
            $number = 1
            $Items | ForEach-Object {
                Write-Host -ForegroundColor Yellow -NoNewline ($number++)
                $name = $_
                if ($PropertiesToDisplay) {
                    $name = $_ | select -ExpandProperty $PropertiesToDisplay[0]
                }

                Write-Host ". $name"
            }

            Write-Host -ForegroundColor Yellow -NoNewline "q"
            Write-Host " to quit"
        }

        $ans = Read-Host "Please select $(("an item", "one or more (comma-separated) items")[[Bool]$Multiselect])"

        if ($Multiselect -and $ans -like "*,*") {
            [int]$result = -1
            $ans = $ans.Split(",") | Where { [int]::TryParse($_, [ref]$result) -and $result -in 1..$($Items.Count) } | select { $_ - 1 } | select -ExpandProperty *
            $isMultiItemAnswer = $ans.Count -gt 0
        }
    }
    while($ans -ne "q" -and -not $isMultiItemAnswer -and -not ($ans -in 1..$($Items.Count)))

    if ($ans -eq "q") {
        return $null
    }

    if ($isMultiItemAnswer) {
        return $Items | Select -Index $ans
    }

    return $Items[$ans - 1]
}

# Collection  of strings
#Get-SelectedItem (Get-Service | select -first 5 -ExpandProperty Name)
# Message
# Get-SelectedItem (Get-Service | select -first 5 -ExpandProperty Name) -Message "Hello chose one of the below"
# Single item
#Get-SelectedItem (Get-Service | select -first 1 -ExpandProperty Name)
# Show property insted of the item
#Get-SelectedItem (Get-Service | select -first 5) -PropertiesToDisplay Name
# Multiselect
#Get-SelectedItem (Get-Service | select -first 5) -PropertiesToDisplay Name -Multiselect
Get-SelectedItem (Get-Service | select -first 5) -PropertiesToDisplay Name, CanStop
