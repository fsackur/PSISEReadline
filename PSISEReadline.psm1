
Get-ChildItem $PSScriptRoot\Private\*.ps1 | ForEach-Object {. $_.FullName}
Get-ChildItem $PSScriptRoot\Public\*.ps1  | ForEach-Object {. $_.FullName}

Set-Alias bck-i-search Invoke-PSISEReadline

# place text in the input buffer, ready for tab-completion
$Script:ShortcutAction = {$psISE.CurrentPowerShellTab.ConsolePane.InputText = "bck-i-search "}

Register-PSISEReadlineSearchCompleter
