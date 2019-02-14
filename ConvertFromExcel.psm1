function Get-LineFormatterColumnNames {
    param(
        $targetColumnOptions
    )

    foreach ($co in $targetColumnOptions) {
        if ($co.Values.Values -eq 'lineFormatter') {
            $co.Keys
        }
    }
}

function ConvertFrom-Excel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $ExcelFile,
        $outFile,
        [object[]]$columnOptions,
        $WorksheetName = "Sheet1",
        $GroupBy
    )

    $r = Get-Module -list ImportExcel
    if (!$r) {
        $msg = @"
        The ImportExcel module needs to be installed on your system for this function to work
        Use: Install-Module ImportExcel
"@
        throw $msg
    }

    # $columnOptions = @()
    # $columnOptions += New-ColumnOption Activity -formatter lineFormatter
    # $columnOptions += New-ColumnOption Progress -formatter progress
    # $columnOptions += New-ColumnOption Rating -formatter star
    # $columnOptions += New-ColumnOption Driver -formatter tickCross
    # $columnOptions += New-ColumnOption dob -title "Date of Birth"

    # Import-Excel -Path $ExcelFile -WorksheetName $WorksheetName | out-tabulatorview $columnOptions -groupBy Gender

    $propertyNames = @(Get-LineFormatterColumnNames $columnOptions)
    if ($propertyNames.Count -eq 0 ) {
        Import-Excel -Path $ExcelFile -WorksheetName $WorksheetName | Out-TabulatorView -outFile $outFile -columnOptions $columnOptions -groupBy $GroupBy
    }
    else {
        $data = Import-Excel -Path $ExcelFile -WorksheetName $WorksheetName

        foreach ($record in $data) {
            foreach ($propertyName in $propertyNames) {
                $record.$propertyName = Invoke-Expression $record.$propertyName
            }
        }

        $data | Out-TabulatorView -outFile $outFile -columnOptions $columnOptions -groupBy $GroupBy
    }
}