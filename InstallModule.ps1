$target = 'C:\Program Files\WindowsPowerShell\Modules\OutTabulatorView'

robocopy . $target /mir /xf .gitignore /xd .git