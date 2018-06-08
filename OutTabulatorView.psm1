function Out-TabulatorView {
    [CmdletBinding()]
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
        [switch]$PassThru,
        [Parameter(ValueFromPipeline)]
        $data
    )

    Begin {
        $htmlFileName = [system.io.path]::GetTempFileName() -replace "\.tmp", ".html"
        $records = @()
        if ($PassThru){
            $exportFileName = [IO.Path]::GetFileNameWithoutExtension([IO.Path]::GetTempFileName()) + '.csv'
        }
    }

    Process {
        $records += @($data)
    }

    End {

        $names = $records[0].psobject.properties.name
        $targetData = $records | ConvertTo-Json -Depth 2 -Compress

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
        $params.Remove('PassThru')
        $params.Remove("data")

        foreach ($entity in $params.GetEnumerator()) {
            $tabulatorColumnOptions.($entity.Key) = $entity.Value
        }
        $headerFilter = $false
        foreach ($column in $tabulatorColumnOptions.columns){
            if ($column.headerFilter){
                $headerFilters = $true
            }
            if ($column.headerFilter -eq 'select'){
                $htFilterParams =@{}
                $records.$($column.field) | Sort-Object -Unique | ForEach-Object{
                    $htFilterParams.Add($_, $_)
                }
                $column.Add('headerFilterParams',$htFilterParams)
            }
        }
        [string]$tabulatorColumnOptions = $tabulatorColumnOptions | ConvertTo-Json -Depth 5

        $tabulatorColumnOptions = $tabulatorColumnOptions.Replace('"lineFormatter"', 'lineFormatter').Replace('"true"', 'true')

        $tabulatorColumnOptions = $tabulatorColumnOptions.Substring(0, $tabulatorColumnOptions.Length - 1)

@"
<script type="text/javascript" src="file:///$PSScriptRoot\js\jquery-3.3.1.min.js"></script>
<script type="text/javascript" src="file:///$PSScriptRoot\js\jquery-ui.min.js"></script>
<script type="text/javascript" src="file:///$PSScriptRoot\js\tabulator.min.js"></script>
<script type="text/javascript" src="file:///$PSScriptRoot\js\jquery.sparkline.min.js"></script>

<link href="file:///$PSScriptRoot\css\tabulator.min.css" rel="stylesheet">
$(
if($theme) {
    "<link href=`"file:///$PSScriptRoot\css\tabulator_$($theme).min.css`" rel=`"stylesheet`">"
}
)
$(
if ($headerFilters){
'<div class="table-controls" style="text-align: center;">
    <button id="clearHeaderFilters" style="position: absolute;font-weight: bold;">Clear Filters</button>
</div>
<br><br>'
}
'<div id="example-table"></div>'
if($PassThru) {
'<br>
<div class="table-controls" style="text-align: center;">
    <button id="download-csv" style="position: absolute;font-weight: bold;">PassThru</button>
</div>'
}
)

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
$(
if($PassThru) {
    '$("#download-csv").click(function(){$("#example-table").tabulator("download", "csv", "' + $exportFileName + '");});'
}
if ($headerFilters){
    '$("#clearHeaderFilters").click(function(){$("#example-table").tabulator("clearHeaderFilter");});'
}
)

</script>
"@ | set-content -Encoding Ascii $htmlFileName
        
        if ($PassThru){
            $htParams=@{}
            $progID = (Get-ItemProperty HKCU:\Software\Microsoft\windows\Shell\Associations\UrlAssociations\http\UserChoice).Progid
            $defaultBrowserDownloadFolder = switch -wildcard ($progID) {
	            *Chrome* {
                    (Get-Content "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences" | ConvertFrom-Json).Download.defaultdirectory
                    $htParams.FilePath = 'chrome'
                    $htParams.ArgumentList = "--new-window $htmlFileName"
                    break
                } 
	            *IE* {
                    (Get-ItemProperty 'HKCU:\Software\Microsoft\Internet Explorer\Main' -ErrorAction SilentlyContinue).'Default Download'
                    $htParams.FilePath = 'iexplore'
                    $htParams.ArgumentList = "$htmlFileName"
                    break
                } 
	            *Firefox* {
                    (Get-Content "$env:APPDATA\Mozilla\Firefox\Profiles\*.default\prefs.js" | Select-String 'browser.download.dir", "(.*)"').Matches.Groups[1].Value
                    $htParams.FilePath = 'firefox'
                    $htParams.ArgumentList = "--new-window $htmlFileName"
                    break
                }
                *AppX* {
                    (Get-ItemProperty 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main' -ErrorAction SilentlyContinue).'Default Download Directory'
                    $htParams.FilePath = "microsoft-edge:$htmlFileName"
                    break
                }
            }
            $browserProcessName = $htParams.FilePath
            if ($htParams.FilePath -like '*edge*'){
                $browserProcessName = 'MicrosoftEdgeCP'
            }
            
            if ($defaultBrowserDownloadFolder){
                $defaultBrowserDownloadFolder = $defaultBrowserDownloadFolder.Replace('\\','\')
            }
            else{
                $defaultBrowserDownloadFolder = "$home\Downloads"
            }
        }
        $before = gps | select Name, Id
        Start-Process @htParams
        #wait browser window to open
        sleep -Seconds 5
        #Start-Process -Passthru does not work
        $after = gps | select Name, Id
        $pid = (diff $before $after -Property Id -PassThru | where {$_.Name -eq $browserProcessName}).Id
        if ($PassThru){
            $htmlFile = [IO.Path]::GetFileName($htmlFileName)
            $dataDownloaded = $false
            $browserWindowClosed = $false
            while ((-not $dataDownloaded) -and ($browserWindowClosed -ne $null)){
                $dataDownloaded = Test-Path "$defaultBrowserDownloadFolder\$exportFileName"
                $browserWindowClosed = Get-Process -Id $pid -ErrorAction SilentlyContinue
            }
            if ($dataDownloaded){
                Import-Csv -Path "$defaultBrowserDownloadFolder\$exportFileName" 
                Remove-Item "$defaultBrowserDownloadFolder\$exportFileName"
            }
            else{
                $records
            }
        }
        Write-Verbose $htmlFileName

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
        [ValidateSet('input', 'number', 'true', 'tick', 'select', 'textarea')]
        $headerFilter,
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