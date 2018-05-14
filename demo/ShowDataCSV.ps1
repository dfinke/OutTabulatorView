cls

ipmo ..\Tabulator.psm1 -Force

$co = $(    
    New-ColumnOption Name #-editor input
    New-ColumnOption age -formatter progress
    New-ColumnOption rating -formatter star #-editor star
    New-ColumnOption driver -formatter tickCross    
)

$to = New-TableOption -layout fitColumns -clipboard -groupBy Gender

Import-Csv .\data.csv | Out-TabulatorView $co $to

return 

ps | where Company | select Company, Name, Handle | Out-TabulatorView -tableOptions (New-TableOption -groupBy Company)

gsv | select DisplayName, Status, StartType | Out-TabulatorView -tableOptions (New-TableOption -groupBy Status)