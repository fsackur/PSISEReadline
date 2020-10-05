
Get-ChildItem $PSScriptRoot\Private\*.ps1 | ForEach-Object {. $_.FullName}
Get-ChildItem $PSScriptRoot\Public\*.ps1  | ForEach-Object {. $_.FullName}

Set-Alias bck-i-search Invoke-PSISEReadline

# place text in the input buffer, ready for tab-completion
$Script:ShortcutAction = {bck}

Register-PSISEReadlineSearchCompleter


function global:prompt {"$($PWD.Path)$('>' * ($nestedPromptLevel + 1)) "}

function bck
{
    #$Global:_PSISECurrentPrompt = Get-Item Function:\prompt
    $CurrentPrompt = Get-Command prompt
    
    #Set-Item Function:\Global:prompt {}
    Set-Item Function:\prompt {"`b"}

    $PromptRestore = {
        Unregister-Event -SourceIdentifier PowerShell.OnIdle
        Set-Item Function:\Global:prompt $CurrentPrompt
    }

    $PromptRestoreString = $PromptRestore.ToString() -replace '\$CurrentPrompt', "{$($CurrentPrompt.Definition)}"
    $PromptRestoreAction = ([scriptblock]::Create($PromptRestoreString))

    $null = Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -Action $PromptRestoreAction

    $psISE.CurrentPowerShellTab.ConsolePane.InputText = "bck-i-search "
    #>
}

Register-PSISEReadlineShortcut
