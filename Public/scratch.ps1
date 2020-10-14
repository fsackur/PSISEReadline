$Script:Action = {

    Unregister-Event -SourceIdentifier PaneChanged

    if (-not $SearchString)
    {
        $ConsolePane = $args[0]
        $PaneType = $ConsolePane.GetType()
        $Field = $PaneType.GetField('inputTextBeforeExecution', 'nonpublic,instance')
        $InputTextBeforeExecution = $Field.GetValue($Pane)
        $SearchString = $InputTextBeforeExecution
    }

    # $Pane.InputText = (Get-History).CommandLine -like "*$SearchString*" | Select -Last 1
    #Write-host ((Get-History).CommandLine -like "*$SearchString*" | Select -Last 1) -ForegroundColor Green
    #$Action.gettype() | Out-String | Write-Host -ForegroundColor Yellow

    $Module = Get-Module PSISEReadline | Select-Object -First 1
    & $Module {$SearchString} | Out-String | Write-Host -ForegroundColor Green

    $SearchString | Write-Host -ForegroundColor Yellow
    
}


function bck-i-search
{
    & $MyInvocation.MyCommand.Module {$Action = $Action.GetNewClosure()}

    $null = Register-ObjectEvent -InputObject $psISE.CurrentPowerShellTab.ConsolePane -EventName PropertyChanged -Action $Action -MaxTriggerCount 1 -SourceIdentifier PaneChanged
}
