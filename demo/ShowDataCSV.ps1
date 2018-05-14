cls

ipmo ..\Tabulator.psm1 -Force


$co = $(
    New-ColumnOption Name -editor true
    New-ColumnOption age -formatter progress
    New-ColumnOption rating -formatter star
    New-ColumnOption driver -formatter tickCross
)

$to = New-TableOption -layout fitColumns -clipboard

Import-Csv .\data.csv | Out-TabulatorView $co $to