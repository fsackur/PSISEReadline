$Script:Action = {

    Unregister-Event -SourceIdentifier PaneChanged

    # $psISE.CurrentPowerShellTab.ConsolePane
    $ConsolePane = $args[0]
    $PaneType = $ConsolePane.GetType()
    $Field = $PaneType.GetField('inputTextBeforeExecution', 'nonpublic,instance')
    $InputTextBeforeExecution = $Field.GetValue($Pane)

    
    $MyModule = Get-Module PSISEReadline | Select-Object -First 1
    $SearchString = & $MyModule {$Script:SearchString}
    if (-not $SearchString)
    {
        $SearchString = $InputTextBeforeExecution
        & $MyModule {$Script:SearchString = $args[0]} $SearchString
    }

    # $Pane.InputText = (Get-History).CommandLine -like "*$SearchString*" | Select -Last 1
    #Write-host ((Get-History).CommandLine -like "*$SearchString*" | Select -Last 1) -ForegroundColor Green
    #$Action.gettype() | Out-String | Write-Host -ForegroundColor Yellow

    
    $SearchString | Write-Host -ForegroundColor Yellow
    
}


function bck-i-search
{
    $null = Register-ObjectEvent -InputObject $psISE.CurrentPowerShellTab.ConsolePane -EventName PropertyChanged -Action $Script:Action -MaxTriggerCount 1 -SourceIdentifier PaneChanged
}
