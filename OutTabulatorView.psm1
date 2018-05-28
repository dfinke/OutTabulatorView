function Out-TabulatorView {
    param(
        $columnOptions,
        $height,
        [ValidateSet('fitColumns')]
        $layout,
        [ValidateSet('Simple', 'Midnight', 'Modern', 'Site')]
        $theme,
        [ValidateSet('local')]
        $pagination,
        $paginationSize,
        $groupBy,
        [switch]$clipboard,
        [Parameter(ValueFromPipeline)]
        $data
    )

    Begin {
        $htmlFileNname = [system.io.path]::GetTempFileName() -replace "\.tmp", ".html"
        $records = @()
    }

    Process {
        $records += @($data)
    }

    End {

        $names = $records[0].psobject.properties.name
        $targetData = $records | ConvertTo-Json -Depth 5

        if ($records.Count -eq $null -or $records.Count -eq 1) {
            $targetData = "[{0}]" -f $targetData
        }

        $tabulatorColumnOptions = @{}
        $tabulatorColumnOptions.columns = @()

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

        $params = @{} + $PSBoundParameters

        $params.Remove("columnOptions")
        $params.Remove("data")

        foreach ($entity in $params.GetEnumerator()) {
            $tabulatorColumnOptions.($entity.Key) = $entity.Value
        }

        [string]$tabulatorColumnOptions = $tabulatorColumnOptions | ConvertTo-Json -Depth 5

        $tabulatorColumnOptions = $tabulatorColumnOptions.Replace('"lineFormatter"', 'lineFormatter')

        $tabulatorColumnOptions = $tabulatorColumnOptions.Substring(0, $tabulatorColumnOptions.Length - 1)
        @"
<script type="text/javascript" src="$PSScriptRoot\js\jquery-3.3.1.min.js"></script>
<script type="text/javascript" src="$PSScriptRoot\js\jquery-ui.min.js"></script>
<script type="text/javascript" src="$PSScriptRoot\js\tabulator.min.js"></script>
<script type="text/javascript" src="$PSScriptRoot\js\jquery.sparkline.min.js"></script>

<link href="$PSScriptRoot\css\tabulator.min.css" rel="stylesheet">
$(
if($theme) {
    "<link href=`"$PSScriptRoot\css\tabulator_$($theme).min.css`" rel=`"stylesheet`">"
}
)

<div id="example-table"></div>

<script type="text/javascript">
    var lineFormatter = function(cell, formatterParams){
        setTimeout(function(){ //give cell enough time to be added to the DOM before calling sparkline formatter
        	cell.getElement().sparkline(cell.getValue(), {width:"100%", type:"line", disableTooltips:true});
        }, 10);
    };

  var tabledata = $($targetData)

  `$("#example-table").tabulator(
        $($tabulatorColumnOptions)
});

`$("#example-table").tabulator("setData", tabledata);

</script>
"@ | set-content -Encoding Ascii $htmlFileNname
        Start-Process $htmlFileNname

    }
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

Set-Alias otv Out-TabulatorView

Export-ModuleMember -Function Out-TabulatorView, New-ColumnOption -Alias otv