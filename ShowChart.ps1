param(
    [Switch]$NoColumnProperties
)

Import-Module .\OutTabulatorView.psd1 -Force

function New-Record {
    param(
        $Name,
        $Progress,
        $Activity,
        $Gender,
        $Rating,
        $Color,
        $dob,
        $Driver
    )

    [pscustomobject]([ordered]@{} + $PSBoundParameters)
}

$data = $(
    #          Name Progress Activity Gender Rating Color dob Driver
    New-Record "Alan Francis" "90" (4, 17, 11, 7, 6, 12, 14, 13, 11, 10, 9, 6, 11, 12, 0, 5, 12, 14, 18, 11) male 3 blue "07/08/1972" "true"
    New-Record "Brendon Philips" "100" (3, 7, 9, 1, 4, 8, 2, 6, 4, 2, 1, 3, 1, 3, 3, 1, 1, 3, 1, 3) "male" "1" "orange" "01/08/1980" ""
    New-Record "Christine Lobowski" "42" (1, 2, 5, 4, 1, 16, 4, 2, 1, 3, 3, 7, 9, 1, 4, 8, 2, 6, 4, 2) "female" "0" "green" "22/05/1982" "true"
    New-Record "Ed White" "70" (20, 17, 15, 11, 16, 9, 4, 17, 11, 12, 0, 5, 12, 14, 18, 11, 12, 14, 20, 12) "male" "0" "yellow" "19/06/1976" ""
    New-Record "Emily Sykes" "42" (11, 15, 19, 20, 17, 16, 16, 5, 3, 2, 1, 2, 3, 4, 5, 4, 2, 5, 9, 8) "female" "1" "maroon" "11/11/1970" ""
    New-Record "Emma Netwon" "40" (3, 7, 9, 1, 4, 8, 3, 7, 9, 1, 4, 8, 2, 6, 4, 2, 2, 6, 4, 2) "female" "4" "brown" "07/10/1963" "true"
    New-Record "Frank Harbours" "38" (20, 17, 15, 11, 16, 9, 12, 14, 20, 12, 11, 7, 6, 12, 14, 13, 11, 10, 9, 6) "male" "4" "red" "12/05/1966" "1"
    New-Record "Gemma Jane" "60" (4, 17, 11, 12, 0, 5, 12, 14, 18, 11, 11, 15, 19, 20, 17, 16, 16, 5, 3, 2) "female" "0" "red" "22/05/1982" "true"
    New-Record "Hannah Farnsworth" "30" (1, 2, 5, 4, 1, 16, 10, 12, 14, 16, 13, 9, 7, 11, 10, 13, 4, 2, 1, 3) "female" "1" "pink" "11/02/1991" ""
    New-Record "James Newman" "73" (1, 20, 5, 3, 10, 13, 17, 15, 9, 11, 1, 2, 3, 4, 5, 4, 2, 5, 9, 8) "male" "5" "red" "22/03/1998" ""
    New-Record "Jamie Newhart" "23" (11, 7, 6, 12, 14, 13, 11, 10, 9, 6, 4, 17, 11, 12, 0, 5, 12, 14, 18, 11) "male" "3" "green" "14/05/1985" "true"
    New-Record "Jenny Green" "56" (11, 15, 19, 20, 17, 15, 11, 16, 9, 12, 14, 20, 12, 20, 17, 16, 16, 5, 3, 2) "female" "4" "indigo" "12/11/1998" "true"
    New-Record "John Phillips" "80" (11, 7, 6, 12, 14, 1, 20, 5, 3, 10, 13, 17, 15, 9, 1, 13, 11, 10, 9, 6) "male" "1" "green" "24/09/1950" "true"
    New-Record "Margret Marmajuke" "16" (1, 3, 1, 3, 3, 1, 1, 3, 1, 3, 20, 17, 15, 11, 16, 9, 12, 14, 20, 12) "female" "5" "yellow" "31/01/1999" ""
    New-Record "Martin Barryman" "20" (1, 2, 3, 4, 5, 4, 11, 7, 6, 12, 14, 13, 11, 10, 9, 6, 2, 5, 9, 8) "male" "5" "violet" "04/04/2001" ""
    New-Record "Mary May" "1" (10, 12, 14, 16, 13, 9, 7, 11, 10, 13, 1, 2, 5, 4, 1, 16, 4, 2, 1, 3) "female" "2" "blue" "14/05/1982" "true"
    New-Record "Oli Bob" "12" (1, 20, 5, 3, 10, 13, 17, 15, 9, 11, 10, 12, 14, 16, 13, 9, 7, 11, 10, 13) "male" "1" "red" "19/02/1984" "1"
    New-Record "Paul Branderson" "60" (1, 3, 1, 3, 3, 1, 11, 15, 19, 20, 17, 16, 16, 5, 3, 2, 1, 3, 1, 3) "male" "5" "orange" "01/01/1982" ""
    New-Record "Victoria Bath" "20" (10, 12, 14, 16, 13, 9, 7, 1, 2, 3, 4, 5, 4, 2, 5, 9, 8, 11, 10, 13) "female" "2" "purple" "22/03/1986" ""
)

$ColumnProperties = $(
    New-ColumnOption Name -frozen true
    New-ColumnOption Progress -formatter progress
    New-ColumnOption Activity -formatter lineFormatter
    New-ColumnOption Rating -formatter star
    New-ColumnOption Driver -formatter tickCross
    New-ColumnOption dob -title "Date of Birth"
)

if ($NoColumnProperties) { $ColumnProperties = @{} }

$data |
    Out-TabulatorView $ColumnProperties -theme Site `
        -height 250 `
        -layout fitColumns `
        -pagination local `
        -paginationSize 10 `
        -clipboard