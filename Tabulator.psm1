function Out-TabulatorView {
    param(
        $columnOptions,
        [hashtable]$tableOptions,
        [Parameter(ValueFromPipeline)]
        $data
    )

    Begin {
        $records = @()
    }

    Process {
        $records += $data
    }

    End {

        $names = $records[0].psobject.properties.name
        # $targetData = $records | ConvertTo-Json -Depth 5
        $targetData = $records | ConvertTo-csv | ConvertFrom-Csv | ConvertTo-Json -Depth 5

        $tabulatorColumnOptions = @{}
        if ($tableOptions) {
            $tabulatorColumnOptions += $tableOptions
        }

        $tabulatorColumnOptions.columns = @()
        # $tabulatorColumnOptions.layout = "fitColumns"
        # $tabulatorColumnOptions.height = 205

        # $tabulatorColumnOptions = @{
        #     columns = @()

        #     # addRowPos      = "top"
        #     # layout         = "fitColumns"
        #     # height         = 205
        #     # movableColumns = $true
        #     # history        = $true
        #     # pagination     = "local"
        #     # paginationSize = 10
        #     # clipboard      = $true
        # }


        foreach ($name in $names) {
            $targetColumn = @{field = $name}

            if ($columnOptions.$name) {
                $columnOptions.$name.getenumerator() | ForEach-Object {
                    $targetColumn.($_.key) = $_.value
                }
            }

            if (!$targetColumn.ContainsKey("title")) {
                $targetColumn.title = $name
            }

            $tabulatorColumnOptions.columns += $targetColumn
        }

        [string]$tabulatorColumnOptions = $tabulatorColumnOptions | ConvertTo-Json -Depth 5

        $tabulatorColumnOptions = $tabulatorColumnOptions.Replace('"lineFormatter"', 'lineFormatter')

        $tabulatorColumnOptions = $tabulatorColumnOptions.Substring(0, $tabulatorColumnOptions.Length - 1)

        @"
<script type="text/javascript" src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
<script type="text/javascript" src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/tabulator/3.5.1/js/tabulator.min.js"></script>
<script type="text/javascript" src="https://omnipotent.net/jquery.sparkline/2.1.2/jquery.sparkline.min.js"></script>

<link href="https://cdnjs.cloudflare.com/ajax/libs/tabulator/3.5.1/css/tabulator.min.css" rel="stylesheet">
<!-- <link href="https://cdnjs.cloudflare.com/ajax/libs/tabulator/3.5.1/css/tabulator_midnight.min.css" rel="stylesheet"> --!>

<div id="example-table"></div>

<script type="text/javascript">
    var lineFormatter = function(cell, formatterParams){
        setTimeout(function(){ //give cell enough time to be added to the DOM before calling sparkline formatter
        	cell.getElement().sparkline(cell.getValue(), {width:"100%", type:"line", disableTooltips:true});
        }, 10);
    };

  var tabledata = $($targetData)

  //load sample data into the table
  //create Tabulator on DOM element with id "example-table"
  `$("#example-table").tabulator(
        $($tabulatorColumnOptions)
});

`$("#example-table").tabulator("setData", tabledata);

</script>
"@ | set-content $pwd\testT.html -Encoding Ascii
        Start-Process "$pwd\testT.html"

    }
}


function New-TableOption {
    param(
        $height,
        [ValidateSet('fitColumns')]
        $layout,
        [ValidateSet('local')]
        $pagination,
        $paginationSize,
        $groupBy,
        [switch]$clipboard
    )


    $r = @{} + $PSBoundParameters

    if ($clipboard) {
        $r.Remove('clipboard')
        $r.clipboard = $true
    }

    $r
}

function New-ColumnOption {
    param(
        [Parameter(Mandatory)]
        $ColumnName,
        $title,
        [ValidateSet('plaintext', 'textarea', 'html', 'money', 'image', 'link', 'tick', 'tickCross', 'color', 'star', 'progress', 'lookup', 'buttonTick', 'buttonCross', 'rownum', 'handle', 'lineFormatter')]
        $formatter,
        [ValidateSet('string', 'number', 'alphanum', 'boolean', 'exists', 'date', 'time', 'datetime', 'array')]
        $sorter,
        [ValidateSet('left', 'right', 'center')]
        $align,
        [ValidateSet('input', 'textarea', 'number', 'tick', 'star', 'progress', 'select')]
        [string]$editor,
        [ValidateSet('true', 'false')]
        [string]$headerSort,
        [ValidateSet('true', 'false')]
        [string]$frozen,
        [int]$width
    )

    $cn = $PSBoundParameters.ColumnName
    $null = $PSBoundParameters.Remove("ColumnName")

    @{$cn = @{} + $PSBoundParameters}
}