Param (
    $ModuleName = 'OutTablulatorView',
    $ModulePath = 'C:\Program Files\WindowsPowerShell\Modules'
)

$ModuleName = 'OutTablulatorView'
$ModulePath = 'C:\Program Files\WindowsPowerShell\Modules'

$target = "{0}\{1}" -f $ModulePath, $ModuleName

robocopy . $target /mir /xf .gitignore /xd .git